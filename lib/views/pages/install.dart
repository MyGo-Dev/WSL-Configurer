import 'package:arche/arche.dart';
import 'package:arche/extensions/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system_info2/system_info2.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/models/config.dart';
import 'package:wslconfigurer/models/distribution.dart';
import 'package:wslconfigurer/views/widgets/basic.dart';
import 'package:wslconfigurer/views/widgets/divider.dart';
import 'package:wslconfigurer/views/widgets/optfeat.dart';
import 'package:wslconfigurer/views/widgets/process.dart';
import 'package:wslconfigurer/windows/ms_open.dart';
import 'package:wslconfigurer/windows/msi.dart';
import 'package:wslconfigurer/windows/utf16.dart';

class InstallPage extends StatefulWidget {
  const InstallPage({super.key});

  @override
  State<StatefulWidget> createState() => _InstallPageState();
}

class _InstallPageState extends State<InstallPage> {
  Widget buildDistributions(Iterable<LinuxDistribution> data) {
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
                            var messager = ScaffoldMessenger.of(context);
                            messager.clearSnackBars();
                            messager.showSnackBar(
                              const SnackBar(
                                content: Text("Copyied!"),
                              ),
                            );

                            Clipboard.setData(ClipboardData(
                                text:
                                    "wsl.exe --install -d ${distro.name} --no-launch"));
                          },
                          icon: const Icon(Icons.copy),
                        ),
                        IconButton(
                          onPressed: () => ComplexDialog.instance
                              .copy(barrierDismissible: false)
                              .text(
                                context: context,
                                content: ProcessCommandRunWidget(
                                  executable: "wsl.exe",
                                  arguments: [
                                    "--install",
                                    "-d",
                                    distro.name,
                                    "--no-launch"
                                  ],
                                  codec: utf16,
                                ),
                              ),
                          icon: const Icon(Icons.terminal),
                        ),
                        IconButton(
                          onPressed: () =>
                              openMSStoreProduct(distro.storeAppId),
                          icon: const Icon(Icons.store),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var distributions = LinuxDistribution.distributions.getValue();

    return CheckOptionalFeatureWidget(
      nextWidget: ScrollableContainer(
        padding: const EdgeInsets.all(8),
        key: const ValueKey(true),
        children: [
          ListTile(
            leading: const Icon(FontAwesomeIcons.section),
            title: context.i18nText("install.upgrade_wsl2_kernel"),
            trailing: Text(SysInfo.rawKernelArchitecture),
          ),
          Card.filled(
            child: Column(
              children: [
                ListTile(
                  title: context.i18nText("install.manual"),
                  trailing: IconButton(
                    onPressed: () => launchUrlString(
                        AppConfigs.wslLinuxKernelUpdateInstallerUrl),
                    icon: const Icon(Icons.open_in_browser),
                  ),
                ),
                ListTile(
                  title: context.i18nText("install.automate"),
                  trailing: IconButton(
                    onPressed: () {
                      ComplexDialog.instance
                          .withContext(context: context)
                          .withChild(
                            DownloadMSIProgressDialog(
                              AppConfigs.wslLinuxKernelUpdateInstallerUrl,
                              logPath: "installer.log",
                            ),
                          )
                          .copy(barrierDismissible: false)
                          .prompt();
                    },
                    icon: const Icon(Icons.install_desktop),
                  ),
                )
              ],
            ),
          ),
          divider8,
          ListTile(
            leading: const Icon(FontAwesomeIcons.section),
            title: context.i18nText("install.install_linux_distro"),
          ),
          Column(
            children: [
              ListTile(
                  title: context.i18nText("install.online"),
                  trailing: IconButton(
                      onPressed: () => LinuxDistribution.distributions
                          .reload()
                          .then((_) => setState(() {})),
                      icon: const Icon(Icons.refresh))),
              distributions is Future<List<LinuxDistribution>>
                  ? FutureBuilder(
                      future: distributions,
                      builder: (context, snapshot) {
                        var data = snapshot.data;
                        if (data == null) {
                          return const CircularProgressIndicator();
                        }
                        return buildDistributions(data);
                      },
                    )
                  : buildDistributions(distributions),
              ListTile(
                title: context.i18nText("install.file"),
                trailing: const Text("TODO"),
              ),
              const Card.filled(
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Import from tar"),
                      trailing: IconButton(
                          onPressed: null, icon: Icon(Icons.file_open)),
                    ),
                    ListTile(
                      title: Text("Import from vhdx"),
                      trailing: IconButton(
                          onPressed: null, icon: Icon(Icons.file_open)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
