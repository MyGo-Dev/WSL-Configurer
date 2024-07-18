import 'dart:async';

import 'package:arche/arche.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    _fields =
        _load(await rootBundle.loadString(i18nLanguageFields(this.locale)));
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
}
