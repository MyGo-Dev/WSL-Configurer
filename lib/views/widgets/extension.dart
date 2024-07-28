import 'package:flutter/material.dart';

extension EachPadding<T extends Widget> on List<T> {
  List<Widget> eachPadding({EdgeInsetsGeometry? padding}) {
    return map(
      (child) => Padding(
        padding: padding ?? const EdgeInsets.all(4),
        child: child,
      ),
    ).toList();
  }
}
