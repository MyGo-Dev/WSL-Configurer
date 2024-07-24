import 'dart:io';

import 'package:arche/arche.dart';
import 'package:arche/extensions/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:superuser/superuser.dart';
import 'package:wslconfigurer/i18n/i18n.dart';

void su(
  BuildContext context,
  Function() run,
) {
  if (Superuser.isSuperuser) {
    run();
  } else {
    ComplexDialog.instance.text(
      context: context,
      title: context.i18nText("error"),
      content: context.i18nText("need_admin_permission"),
    );
  }
}

Future<Process> enableFeature(String featurename) async {
  return await Process.start("dism", [
    "/online",
    "/enable-feature",
    "/featurename:$featurename",
    "/all",
    "/norestart"
  ]);
}
