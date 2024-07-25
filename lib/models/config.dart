import 'package:arche/arche.dart';
import 'package:flutter/material.dart';
import 'package:system_info2/system_info2.dart';

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
  static String wslLinuxKernelUpdateInstallerUrl = SysInfo.kernelArchitecture ==
          ProcessorArchitecture.arm
      ? "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_arm64.msi"
      : "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi";
}
