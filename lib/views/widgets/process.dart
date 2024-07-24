import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wslconfigurer/windows/sh.dart';

class ProcessText extends StatefulWidget {
  final Process process;
  final bool latest;
  final Encoding codec;
  const ProcessText({
    super.key,
    required this.process,
    this.latest = false,
    this.codec = systemEncoding,
  });

  @override
  State<StatefulWidget> createState() => _ProcessTextState();
}

class _ProcessTextState extends State<ProcessText> {
  List<(bool, String)> span = [];

  @override
  void initState() {
    super.initState();

    var process = widget.process;

    process.stderr.listen(
      (data) => setState(() {
        span.add((true, widget.codec.decode(data).trim()));
      }),
    );
    process.stdout.listen(
      (data) => setState(() {
        span.add((false, widget.codec.decode(data).trim()));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (span.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.latest) {
      return span.lastOrNull == null
          ? const Text("")
          : SelectableText(
              span.last.$2,
              style: span.last.$1 ? const TextStyle(color: Colors.red) : null,
            );
    }

    return Column(
      children: span
          .map((data) => SelectableText(data.$2,
              style: data.$1 ? const TextStyle(color: Colors.red) : null))
          .toList(),
    );
  }
}

class ProcessCommandRunWidget extends StatefulWidget {
  final String executable;
  final Iterable<String> arguments;
  final bool su;
  final bool runInShell;
  final Encoding codec;

  const ProcessCommandRunWidget({
    super.key,
    required this.executable,
    this.arguments = const [],
    this.su = false,
    this.runInShell = false,
    this.codec = systemEncoding,
  });

  @override
  State<StatefulWidget> createState() => _ProcessCommandRunWidgetState();
}

class _ProcessCommandRunWidgetState extends State<ProcessCommandRunWidget> {
  bool confirm = false;
  Process? process;

  @override
  void dispose() {
    super.dispose();
    process?.kill();
  }

  @override
  Widget build(BuildContext context) {
    if (confirm) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                [widget.executable, ...widget.arguments].join(" "),
              ),
              const IconButton(
                onPressed: null,
                icon: Icon(Icons.keyboard_arrow_right_rounded),
              ),
            ],
          ),
          FutureBuilder(
            future: Process.start(
              widget.executable,
              widget.arguments.toList(),
              runInShell: widget.runInShell,
            ),
            builder: (context, snapshot) {
              var proc = snapshot.data;
              if (proc == null) {
                return const CircularProgressIndicator();
              }
              process = proc;

              return ProcessText(
                process: proc,
                codec: widget.codec,
              );
            },
          )
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          [widget.executable, ...widget.arguments].join(" "),
        ),
        IconButton(
          onPressed: () {
            if (widget.su) {
              su(
                  context,
                  () => setState(() {
                        confirm = true;
                      }));
            } else {
              setState(() {
                confirm = true;
              });
            }
          },
          icon: const Icon(Icons.keyboard_arrow_right_rounded),
        ),
      ],
    );
  }
}
