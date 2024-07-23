import 'package:arche/arche.dart';
import 'package:arche/extensions/dialogs.dart';
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
          subtitle: Text(
              context.i18n.avaiableLanguages[context.i18n.locale] ?? "Error"),
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
                .map(
                  (entry) => PopupMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
          ),
        ),
        divider8,
        ListTile(
          title: context.i18nText("font"),
          subtitle: Text(configs.font.tryGet() ?? "Default"),
          trailing: PopupMenuButton(
            initialValue: configs.font.tryGet(),
            onSelected: (value) async {
              await SystemFonts().loadFont(value);
              configs.font.write(value);
              setState(() {});
              appKey.currentState?.refreshMounted();
            },
            itemBuilder: (BuildContext context) {
              var fonts = SystemFonts().getFontList();
              fonts.sort();
              return fonts
                  .map(
                    (fontName) => PopupMenuItem(
                        value: fontName,
                        child: FutureBuilder(
                          future: SystemFonts().loadFont(fontName),
                          builder: (context, snapshot) {
                            var data = snapshot.data;

                            if (data == null) {
                              return Text(fontName);
                            }
                            return Text(
                              data,
                              style: TextStyle(fontFamily: fontName),
                            );
                          },
                        )),
                  )
                  .toList();
            },
          ),
        ),
        divider8,
        ListTile(
          title: context.i18nText("distro_info_url"),
          subtitle: Text(
              configs.distroInfoUrl.getOr(AppConfigs.defaultDistroInfoUrl)),
          trailing: IconButton(
              onPressed: () {
                ComplexDialog.instance
                    .input(
                      controller: TextEditingController(
                          text: configs.distroInfoUrl
                              .getOr(AppConfigs.defaultDistroInfoUrl)),
                      context: context,
                      title: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: IconButton(
                              onPressed: Navigator.of(context).pop,
                              icon: const Icon(Icons.restore),
                            ),
                          ),
                          const Text("Input")
                        ],
                      ),
                    )
                    .then(
                      (url) => setState(() {
                        configs.distroInfoUrl
                            .write(url ?? AppConfigs.defaultDistroInfoUrl);
                      }),
                    );
              },
              icon: const Icon(Icons.edit)),
        ),
      ],
    );
  }
}
