import 'dart:convert';
import 'dart:io';

import 'package:arche/arche.dart';
import 'package:arche/extensions/iter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/widgets/extension.dart';
import 'package:wslconfigurer/views/widgets/process.dart';
import 'package:wslconfigurer/windows/wsl.dart';

class DistroManagePage extends StatefulWidget {
  final String distro;
  const DistroManagePage({super.key, required this.distro});

  @override
  State<StatefulWidget> createState() => _DistroManagePageState();
}

class _DistroManagePageState extends State<DistroManagePage>
    with RefreshMountedStateMixin {
  Process? process;

  late final TextEditingController exec;
  @override
  void initState() {
    super.initState();
    exec = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    process?.kill();
    exec.dispose();
  }

  @override
  void refreshMountedFn(Function() fn) {
    process?.kill();

    super.refreshMountedFn(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView(
        children: [
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () =>
                        WindowsSubSystemLinux.start(distro: widget.distro),
                    child: WidthInfCenterWidget(
                      child: context.i18nText("manage.terminal"),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => WindowsSubSystemLinux.start(
                      distro: widget.distro,
                      user: "root",
                    ),
                    child: WidthInfCenterWidget(
                      child: Text(context.i18n.getOrKey("manage.terminal") +
                          context.i18n.getOrKey("manage.root")),
                    ),
                  )
                ].eachPadding(),
              ),
            ),
          ),
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  TextField(
                    controller: exec,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                  FilledButton(
                    onPressed: () => WindowsSubSystemLinux.exec(
                      distro: widget.distro,
                      commands: exec.text.split(" "),
                    ).then(
                      (value) => refreshMountedFn(() => process = value),
                    ),
                    child: WidthInfCenterWidget(
                      child: context.i18nText("manage.execute"),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => WindowsSubSystemLinux.exec(
                      distro: widget.distro,
                      commands: exec.text.split(" "),
                    ).then(
                      (value) => refreshMountedFn(() => process = value),
                    ),
                    child: WidthInfCenterWidget(
                      child: Text(context.i18n.getOrKey("manage.execute") +
                          context.i18n.getOrKey("manage.root")),
                    ),
                  ),
                  process != null
                      ? ProcessText(
                          key: ValueKey(process),
                          process: process!,
                          codec: utf8,
                        )
                      : const SizedBox.shrink(),
                ].eachPadding(),
              ),
            ),
          ),
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: WSLExplorerWidget(distro: widget.distro),
            ),
          ),
        ].enumerate(
          (index, widget) => AnimationConfiguration.staggeredList(
            position: index,
            child: SlideAnimation(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: widget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WSLExplorerWidget extends StatefulWidget {
  final String distro;
  const WSLExplorerWidget({super.key, required this.distro});

  @override
  State<StatefulWidget> createState() => _WSLExplorerWidgetState();
}

class _WSLExplorerWidgetState extends State<WSLExplorerWidget>
    with RefreshMountedStateMixin {
  late WSLExplorer explorer;
  List<FileSystemEntity> current = [];
  @override
  void initState() {
    super.initState();

    explorer = WSLExplorer(widget.distro);
    listExplorer();
  }

  void listExplorer() {
    current.clear();

    explorer.list().listen((data) => refreshMountedFn(() => current.add(data)),
        onDone: () => refreshMountedFn(
            () => current.sort((a, b) => a.path.compareTo(b.path))));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey(explorer.current),
      children: [
        ...explorer.isRoot
            ? []
            : [
                ListTile(
                    title: const Text(".."),
                    onTap: () {
                      explorer.parent();
                      listExplorer();
                    },
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))))
              ],
        ...current.map<Widget>((entity) {
          var entityBaseName = basename(entity.path);
          var friendlyName =
              entity.path.replaceFirst(explorer.root, "").replaceAll("\\", "/");
          return FutureBuilder(
            future: entity.stat(),
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (data == null) {
                return ListTile(
                  leading: const Icon(Icons.question_mark),
                  title: Text(entityBaseName),
                  subtitle: Text(friendlyName),
                );
              }

              IconData icon;
              Function()? onTap;

              switch (data.type) {
                case FileSystemEntityType.file:
                  icon = FontAwesomeIcons.file;
                  break;
                case FileSystemEntityType.directory:
                  icon = Icons.folder;
                  onTap = () async {
                    await explorer.move(entity.path);
                    listExplorer();
                  };
                  break;
                case FileSystemEntityType.link:
                  icon = Icons.link;
                  break;
                case FileSystemEntityType.notFound:
                  icon = Icons.security;
                default:
                  icon = Icons.question_mark;
              }

              return ListTile(
                leading: Icon(icon),
                title: Text(entityBaseName),
                subtitle: Text(friendlyName),
                onTap: onTap,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              );
            },
          );
        }),
      ],
    );
  }
}
