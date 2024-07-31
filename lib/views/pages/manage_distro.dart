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
import 'package:wslconfigurer/windows/ms_open.dart';
import 'package:wslconfigurer/windows/wsl.dart';

class DistroManagePage extends StatefulWidget {
  final String distro;
  final Function() callback;
  const DistroManagePage(
      {super.key, required this.distro, required this.callback});

  @override
  State<StatefulWidget> createState() => _DistroManagePageState();
}

class _DistroManagePageState extends State<DistroManagePage>
    with RefreshMountedStateMixin {
  late final TextEditingController exec;
  String? user;

  @override
  void initState() {
    super.initState();
    exec = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    exec.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: BackButton(
          onPressed: widget.callback,
        ),
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        title: Text(widget.distro),
        actions: [
          context.i18nText("root"),
          const SizedBox(
            width: 4,
          ),
          Switch(
            value: user != null,
            onChanged: (value) => setState(() {
              user = value ? "root" : null;
            }),
            thumbIcon: const WidgetStatePropertyAll(Icon(Icons.security)),
          )
        ],
      ),
      body: NavigationView(
        backgroundColor: Colors.transparent,
        labelType: NavigationLabelType.selected,
        items: [
          NavigationItem(
            icon: const Icon(Icons.home),
            label: context.i18n.getOrKey("home"),
            page: AnimationLimiter(
              child: ListView(
                children: [
                  Card.filled(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          FilledButton(
                            onPressed: () => WindowsSubSystemLinux.start(
                              distro: widget.distro,
                              user: user,
                            ),
                            child: WidthInfCenterWidget(
                              child: context.i18nText("manage.open_terminal"),
                            ),
                          ),
                          FilledButton(
                            onPressed: () => WindowsSubSystemLinux.terminate(
                              distro: widget.distro,
                            ),
                            child: WidthInfCenterWidget(
                              child: context.i18nText("manage.terminate"),
                            ),
                          ),
                        ].eachPadding(),
                      ),
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
            ),
          ),
          NavigationItem(
              icon: const Icon(Icons.terminal),
              label: context.i18n.getOrKey("manage.terminal"),
              page: _WSLTerminalWidget(
                bind: this,
                distro: widget.distro,
              )),
          NavigationItem(
            icon: const Icon(Icons.folder),
            page: ListView(children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: WSLExplorerWidget(distro: widget.distro),
              ),
            ]),
            label: context.i18n.getOrKey("manage.file"),
          )
        ],
        direction: Axis.horizontal,
      ),
    );
  }
}

class _WSLTerminalWidget extends StatefulWidget {
  final _DistroManagePageState bind;
  final String distro;

  const _WSLTerminalWidget({required this.distro, required this.bind});

  @override
  State<StatefulWidget> createState() => _WSLTerminalWidgetState();
}

class _WSLTerminalWidgetState extends State<_WSLTerminalWidget> {
  List<MapEntry<String, Process>> processList = [];
  late TextEditingController controller;
  Process? current;

  bool available = true;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void runCommand() {
    if (controller.text.trim().isEmpty) {
      return;
    }

    setState(() {
      available = false;
    });

    WindowsSubSystemLinux.exec(
      distro: widget.distro,
      commands: controller.text.split(" ").where((value) => value.isNotEmpty),
      user: widget.bind.user,
    ).then(
      (proc) => setState(() {
        current = proc;
        proc.exitCode.then((_) => setState(() {
              available = true;
            }));
        processList.add(MapEntry(controller.text, proc));
        controller.clear();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: processList
                  .map(
                    (entry) => Column(
                      children: [
                        Card.filled(
                          child: ListTile(
                            title: Text(entry.key),
                          ),
                        ),
                        ProcessText(
                          process: entry.value,
                          codec: utf8,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        TextField(
          onSubmitted: (_) => runCommand(),
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: AnimatedSwitcher(
                duration: Durations.medium4,
                child: available
                    ? IconButton(
                        onPressed: runCommand,
                        icon: const Icon(Icons.send),
                      )
                    : Stack(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(2),
                            child: CircularProgressIndicator(),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                current?.kill();
                                available = true;
                              });
                            },
                            icon: const Icon(Icons.stop),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        )
      ],
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
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    openInExplorer(entity.path);
                  },
                ),
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
