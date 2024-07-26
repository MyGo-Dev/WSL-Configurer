import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DistroManagePage extends StatefulWidget {
  final String distro;
  const DistroManagePage({super.key, required this.distro});

  @override
  State<StatefulWidget> createState() => _DistroManagePageState();
}

class _DistroManagePageState extends State<DistroManagePage> {
  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(child: Text(widget.distro));
  }
}
