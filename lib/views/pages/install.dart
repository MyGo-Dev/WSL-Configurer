import 'package:arche/arche.dart';
import 'package:arche/extensions/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wslconfigurer/controllers/ms_open.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/messages/windows.pb.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/widgets/divider.dart';

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: OptionFeatures.rustSignalStream,
      builder: (context, snapshot) {
        var message = snapshot.data;
        if (message == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        var features = message.message.features;

        if (features.fold(0, (state, feat) => state + feat.installState) == 2) {
          var children = <Widget>[
            ListTile(
              leading: IconButton(
                onPressed: () {
                  ComplexDialog.instance.text(
                    context: context,
                    content: Wrap(
                      direction: Axis.vertical,
                      children: [
                        const Text(
                            "Optional Features -> WSL/VirtualMachinePlatform"),
                        FilledButton(
                          onPressed: () {
                            openMSSetting("optionalfeatures");
                          },
                          child: Text("Open"),
                        )
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.help),
              ),
              title: Row(
                children: [
                  context.i18nText("Open Windows Features"),
                ],
              ),
              trailing: IconButton(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
              ),
            )
          ];
          for (var feat in features) {
            children.add(
              ListTile(
                title: Text(feat.caption),
                subtitle: Text(feat.name),
                trailing: feat.installState == 1
                    ? const Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.warning,
                        color: Colors.amber,
                      ),
              ),
            );
          }

          children.add(
            Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                    onPressed: () {
                      //TODO
                    },
                    child: context.i18nText("install.auto_install")),
              ),
            ),
          );

          return ScrollableContainer(
            children: children,
          );
        }

        return ScrollableContainer(
          children: [
            ListTile(
              leading: const Icon(FontAwesomeIcons.section),
              title: context.i18nText("install.prepare"),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Card.filled(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text("HyperV"),
                      trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_right_rounded)),
                    ),
                    const ListTile(
                      title: Text("WSL"),
                      trailing: Icon(Icons.check),
                    )
                  ],
                ),
              ),
            ),
            divider8,
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
                          onPressed: () {},
                          icon: const Icon(Icons.open_in_new)),
                    ),
                    ListTile(
                      title: const Text("ArchLinux"),
                      trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.open_in_new)),
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
      },
    );
  }
}
