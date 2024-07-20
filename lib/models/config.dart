import 'package:arche/arche.dart';

class AppConfigs {
  final ConfigEntry<T> Function<T>(String configKey) _generator;
  AppConfigs(ArcheConfig config)
      : _generator = ConfigEntry.withConfig(config, generateMap: true);

  ConfigEntry<String> get locale => _generator("locale");
  ConfigEntry<String> get font => _generator("font");
}
