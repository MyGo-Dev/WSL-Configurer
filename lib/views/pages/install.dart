import 'package:arche/arche.dart';
import 'package:arche/extensions/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/models/distribution.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/widgets/divider.dart';
import 'package:wslconfigurer/views/widgets/optfeat.dart';
import 'package:wslconfigurer/windows/ms_open.dart';

class InstallPage extends StatefulWidget {
  const InstallPage({super.key});

  @override
  State<StatefulWidget> createState() => _InstallPageState();
}

class _InstallPageState extends State<InstallPage> {
  @override
  Widget build(BuildContext context) {
    return CheckOptionalFeatureWidget(
      nextWidget: ScrollableContainer(
        key: const ValueKey(true),
        children: [
          ListTile(
            leading: const Icon(FontAwesomeIcons.section),
            title: context.i18nText("install.install_linux_distro"),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                FutureBuilder(
                  future: LinuxDistribution.fetch(),
                  builder: (context, snapshot) {
                    var data = snapshot.data;
                    if (data == null) {
                      return const CircularProgressIndicator();
                    }

                    return Card.filled(
                      child: AnimationLimiter(
                        child: Column(
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: data
                                .map(
                                  (distro) => ListTile(
                                      title: Text(distro.friendlyName),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              var messager =
                                                  ScaffoldMessenger.of(context);
                                              messager.clearSnackBars();
                                              messager.showSnackBar(
                                                const SnackBar(
                                                  content: Text("Copyied!"),
                                                ),
                                              );

                                              Clipboard.setData(ClipboardData(
                                                  text:
                                                      "wsl.exe --install -d ${distro.name}"));
                                            },
                                            icon: const Icon(Icons.copy),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              ComplexDialog.instance.text(
                                                context: context,
                                              );
                                            },
                                            icon: const Icon(Icons.terminal),
                                          ),
                                          IconButton(
                                            onPressed: () => openMSStoreProduct(
                                                distro.storeAppId),
                                            icon: const Icon(Icons.store),
                                          ),
                                        ],
                                      )),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const ListTile(
                  title: Text("Install from File"),
                  trailing: Text("TODO"),
                ),
                const ListTile(
                  title: Text("Upgrade to WSL2"),
                  trailing: Text("TODO"),
                ),
              ],
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
      ),
    );
  }
}
