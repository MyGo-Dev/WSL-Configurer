import 'package:arche/arche.dart';

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
  static const defaultDistroInfoUrl =
      "https://raw.githubusercontent.com/microsoft/WSL/master/distributions/DistributionInfo.json";
}
