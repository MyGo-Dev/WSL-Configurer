import 'package:arche/arche.dart';
import 'package:flutter/material.dart';
import 'package:system_fonts/system_fonts.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/models/config.dart';
import 'package:wslconfigurer/models/key.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/widgets/divider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var configs = ArcheBus.bus.of<AppConfigs>();
    return ScrollableContainer(
      children: [
        ListTile(
          title: context.i18nText("language"),
          trailing: PopupMenuButton(
            initialValue: configs.locale.getOr("en_US"),
            onSelected: (value) async {
              configs.locale.write(value);
              var i18n = I18n();
              await i18n.init(value);
              ArcheBus.bus.replace<I18n>(i18n);
              rootKey.currentState?.setState(() {});
              setState(() {});
            },
            itemBuilder: (context) => context.i18n.avaiableLanguages.entries
                .map((entry) => PopupMenuItem(
                      value: entry.value,
                      child: Text(entry.key),
                    ))
                .toList(),
          ),
        ),
        divider8,
        ListTile(
          title: context.i18nText("font"),
          trailing: SystemFontSelector(
            initial: configs.font.tryGet(),
            onFontSelected: (value) {
              configs.font.write(value);
              setState(() {});
              appKey.currentState?.refreshMounted();
            },
          ),
        )
      ],
    );
  }
}
