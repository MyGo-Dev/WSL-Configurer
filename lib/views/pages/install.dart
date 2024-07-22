import 'package:arche/arche.dart';
import 'package:arche/extensions/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rinf/rinf.dart';
import 'package:wslconfigurer/views/widgets/process.dart';
import 'package:wslconfigurer/windows/ms_open.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/messages/windows.pb.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/widgets/divider.dart';
import 'package:wslconfigurer/windows/sh.dart';

class InstallPage extends StatefulWidget {
  const InstallPage({super.key});

  @override
  State<StatefulWidget> createState() => _InstallPageState();
}

class _InstallPageState extends State<InstallPage> {
  @override
  void initState() {
    super.initState();

    QueryOptionalFeature().sendSignalToRust();
  }

  Widget buildWidget(BuildContext context,
      AsyncSnapshot<RustSignal<OptionFeatures>> snapshot) {
    var message = snapshot.data;
    if (message == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    var features = message.message.features;

    if (features.fold(0, (state, feat) => state + feat.installState) != 2) {
      return ScrollableContainer(
        key: const ValueKey("prepare"),
        children: [
          ListTile(
            leading: IconButton(
              onPressed: () {
                ComplexDialog.instance.text(
                  context: context,
                  content: Wrap(
                    spacing: 8,
                    direction: Axis.vertical,
                    children: [
                      context.i18nMarkdown("optional_features.md", true),
                      FilledButton(
                        onPressed: () {
                          openMSSetting("optionalfeatures");
                        },
                        child: context.i18nText("optional_features"),
                      )
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.help),
            ),
            title: Row(
              children: [
                Text(
                    "${context.i18n.getOrKey("configure")} ${context.i18n.getOrKey("optional_features")}"),
              ],
            ),
            trailing: IconButton(
              onPressed: () => setState(() {
                QueryOptionalFeature().sendSignalToRust();
              }),
              icon: const Icon(Icons.refresh),
            ),
          ),
          ...features.map(
            (feat) => ListTile(
              title: Text(feat.caption),
              subtitle: Text(feat.name),
              trailing: feat.installState == 1
                  ? const Icon(
                      Icons.check,
                      color: Colors.green,
                    )
                  : IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        su(
                          context,
                          () => enableFeature(feat.name).then(
                            (process) => ComplexDialog.instance
                                .text(
                                  context: context,
                                  title: context.i18nText("output"),
                                  content: SingleChildScrollView(
                                    child: ProcessText(
                                      process: process,
                                    ),
                                  ),
                                )
                                .then(
                                  (_) => setState(() {
                                    QueryOptionalFeature().sendSignalToRust();
                                  }),
                                ),
                          ),
                        );
                      },
                    ),
            ),
          )
        ],
      );
    }

    return ScrollableContainer(
      key: const ValueKey("install"),
      children: [
        ListTile(
          leading: const Icon(FontAwesomeIcons.section),
          title: context.i18nText("Install Linux Distribution"),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card.filled(
            child: Column(
              children: [
                ListTile(
                  title: const Text("Ubuntu"),
                  trailing: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.open_in_new)),
                ),
                ListTile(
                  title: const Text("ArchLinux"),
                  trailing: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.open_in_new)),
                )
              ],
            ),
          ),
        ),
        divider8,
        ListTile(
          leading: const Icon(FontAwesomeIcons.section),
          title: context.i18nText("Install Essential Packages(Optional)"),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card.filled(
            child: Column(
              children: [
                ListTile(
                  title: const Text("C (GCC)"),
                  trailing: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.copy)),
                ),
                ListTile(
                  title: const Text("C (Clang)"),
                  trailing: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.copy)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: OptionFeatures.rustSignalStream,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: Durations.medium4,
          child: buildWidget(context, snapshot),
        );
      },
    );
  }
}
