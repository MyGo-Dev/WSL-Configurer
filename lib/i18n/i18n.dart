import 'dart:async';

import 'package:arche/arche.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wslconfigurer/i18n/constants.dart';
import 'package:yaml/yaml.dart';

class I18n {
  late final Map<String, String> _fields;
  late final Map<String, String> avaiableLanguages;
  String locale = "en_US";

  Map<K, V> _load<K, V>(String data) => Map.from(loadYaml(data));

  FutureOr<void> init([String? locale]) async {
    avaiableLanguages = _load(await rootBundle.loadString(i18nLanguages));
    if (locale != null) {
      this.locale = locale;
    }

    _fields = _load(await rootBundle.loadString(fileName("fields.yaml")));
  }

  String fileName(String fileName) => i18nLanguageFile(locale, fileName);

  Future<String> loadString(String fileName) async {
    return await rootBundle.loadString(this.fileName(fileName));
  }

  String getOrKey(String translateKey) {
    if (_fields.containsKey(translateKey)) {
      return _fields[translateKey]!;
    }

    return translateKey;
  }
}

extension I18nEx on BuildContext {
  I18n get i18n => ArcheBus.bus.of();

  Text i18nText(String translateKey) {
    return Text(ArcheBus.bus.of<I18n>().getOrKey(translateKey));
  }

  Text i18nTextBuilder(
      String translateKey, Text Function(String text) builder) {
    return builder(ArcheBus.bus.of<I18n>().getOrKey(translateKey));
  }

  T i18nBuilder<T>(String translateKey, T Function(String text) builder) {
    return builder(ArcheBus.bus.of<I18n>().getOrKey(translateKey));
  }

  Widget i18nMarkdown(String fileName, [bool shrinkWrap = true]) {
    return FutureBuilder(
      future: ArcheBus.bus.of<I18n>().loadString(fileName),
      builder: (context, snapshot) {
        var data = snapshot.data;
        if (data == null) {
          return const CircularProgressIndicator();
        }

        return MarkdownBody(
          data: data,
          shrinkWrap: shrinkWrap,
          onTapLink: (text, href, title) => launchUrlString(href.toString()),
        );
      },
    );
  }
}
