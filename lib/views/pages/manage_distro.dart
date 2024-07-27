import 'package:arche/extensions/iter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:wslconfigurer/windows/wsl.dart';

class DistroManagePage extends StatefulWidget {
  final String distro;
  const DistroManagePage({super.key, required this.distro});

  @override
  State<StatefulWidget> createState() => _DistroManagePageState();
}

class _DistroManagePageState extends State<DistroManagePage> {
  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView(
        children: [
          FilledButton(
              onPressed: () =>
                  WindowsSubSystemLinux.start(distro: widget.distro),
              child: const Text(
                "Login As `User`",
              )),
          FilledButton(
              onPressed: () => WindowsSubSystemLinux.start(
                    distro: widget.distro,
                    user: "root",
                  ),
              child: const Text("Login As `Root`")),
        ].enumerate(
          (index, widget) => AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
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
