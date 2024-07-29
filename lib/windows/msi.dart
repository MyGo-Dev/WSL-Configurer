import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/windows/utf16.dart';

enum RestartMode {
  norestart,
  promptrestart,
  forcerestart,
}

enum DisplayMode {
  quiet,
  passive,
  qn,
  qb,
  qr,
  qf,
}

Future<ProcessResult> msiexec(
  String path, {
  Iterable<String> arguments = const [],
  String? logPath,
  DisplayMode displayMode = DisplayMode.quiet,
  RestartMode restartMode = RestartMode.norestart,
}) async {
  return await Process.run(
    "msiexec",
    [
      "/i",
      path,
      "/${restartMode.name}",
      "/${displayMode.name}",
      ...arguments,
      ...logPath != null ? ["/log", logPath] : []
    ],
  );
}

void downloadMSIexec(
  String url, {
  String filePath = "installer.msi",
  Iterable<String> arguments = const [],
  String? logPath,
  DisplayMode displayMode = DisplayMode.quiet,
  RestartMode restartMode = RestartMode.norestart,
  Function(int total, int current)? onData,
  Function()? onDone,
  Function()? afterInstall,
}) async {
  var request = await HttpClient().getUrl(Uri.parse(url));
  var response = await request.close();
  var file = File(filePath);
  var total = response.contentLength;
  var io = file.openWrite();
  var current = 0;

  response.listen((data) {
    io.add(data);
    current += data.length;
    if (onData != null) {
      onData(total, current);
    }
  }, onDone: () async {
    await io.flush();
    await io.close();

    if (onDone != null) {
      onDone();
    }

    msiexec(
      filePath,
      arguments: arguments,
      logPath: logPath,
      displayMode: displayMode,
      restartMode: restartMode,
    ).then((_) {
      if (afterInstall != null) {
        afterInstall();
      }
    });
  });
}

class DownloadMSIProgressDialog extends StatefulWidget {
  final String url;
  final String filePath;
  final Iterable<String> arguments;
  final String? logPath;
  final DisplayMode displayMode;
  final RestartMode restartMode;
  final Function()? afterInstall;
  const DownloadMSIProgressDialog(
    this.url, {
    super.key,
    this.filePath = "installer.msi",
    this.arguments = const [],
    this.logPath,
    this.displayMode = DisplayMode.quiet,
    this.restartMode = RestartMode.norestart,
    this.afterInstall,
  });

  @override
  State<StatefulWidget> createState() => DownloadMSIProgressDialogState();
}

class DownloadMSIProgressDialogState extends State<DownloadMSIProgressDialog> {
  bool afterInstall = false;
  String text = "Waiting...";
  double? progress;
  @override
  void initState() {
    super.initState();
    downloadMSIexec(
      widget.url,
      logPath: widget.logPath,
      arguments: widget.arguments,
      displayMode: widget.displayMode,
      restartMode: widget.restartMode,
      onData: (total, current) {
        setState(() {
          progress = current / total;
          text = "$current / $total";
        });
      },
      onDone: () {
        setState(() {
          progress = null;
          text = context.i18n.getOrKey("install.automate");
        });
      },
      afterInstall: () {
        setState(() {
          afterInstall = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: context.i18nText("install"),
      content: afterInstall
          ? FutureBuilder(
              future: Future(() async {
                var log = File("installer.log");
                if (!await log.exists()) {
                  return "Failed to load log.";
                }
                return await log.readAsString(encoding: utf16);
              }),
              builder: (context, snapshot) {
                var data = snapshot.data;
                if (data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return SingleChildScrollView(
                  child: SelectableText(data),
                );
              },
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: progress,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(text),
                )
              ],
            ),
      actions: [
        TextButton(
          onPressed: afterInstall ? Navigator.of(context).pop : null,
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        )
      ],
    );
  }
}
