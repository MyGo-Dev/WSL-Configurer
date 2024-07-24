import 'package:arche/arche.dart';
import 'package:flutter/material.dart';

class AppConfigs {
  final ConfigEntryGenerator _generator;
  AppConfigs(ArcheConfig config, [bool generateMap = true])
      : _generator = ConfigEntry.withConfig(
          config,
          generateMap: generateMap,
        );

  ConfigEntry<String> get locale => _generator("locale");
  ConfigEntry<String> get font => _generator("font");
  ConfigEntry<String> get distroInfoUrl => _generator("distro_info_url");
  ConfigEntryConverter<int, ThemeMode> get themeMode => ConfigEntryConverter(
        _generator("theme"),
        forward: ThemeMode.values.elementAt,
        reverse: ThemeMode.values.indexOf,
      );

  static const defaultDistroInfoUrl =
      "https://raw.githubusercontent.com/microsoft/WSL/master/distributions/DistributionInfo.json";
}
