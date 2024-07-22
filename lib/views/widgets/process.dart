import 'dart:io';

import 'package:flutter/material.dart';

class ProcessText extends StatelessWidget {
  final Process process;

  const ProcessText({super.key, required this.process});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: process.stdout,
      builder: (context, snapshot) {
        var data = snapshot.data;
        if (data == null) {
          return const Text("");
        }

        return SelectableText(const SystemEncoding().decode(data));
      },
    );
  }
}
