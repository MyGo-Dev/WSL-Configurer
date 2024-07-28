import 'dart:convert';
import 'dart:io';

import 'package:arche/arche.dart';
import 'package:arche/extensions/iter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView(
        children: [
          FilledButton(
            onPressed: () => WindowsSubSystemLinux.start(distro: widget.distro),
            child: const Text(
              "Login As `User`",
            ),
          ),
          FilledButton(
            onPressed: () => WindowsSubSystemLinux.start(
              distro: widget.distro,
              user: "root",
            ),
            child: const Text("Login As `root`"),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: FilledButton(
                      onPressed: () => WindowsSubSystemLinux.exec(
                        distro: widget.distro,
                        commands: exec.text.split(" "),
                      ).then(
                        (value) => refreshMountedFn(() => process = value),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text("Exec"),
                        ),
                      ),
                    ),
                  ),
                  process != null
                      ? Row(
                          children: [
                            ProcessText(
                              key: ValueKey(process),
                              process: process!,
                              codec: utf8,
                            )
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
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
    );
  }
}
