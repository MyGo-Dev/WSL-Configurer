import 'package:arche/arche.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wslconfigurer/i18n/i18n.dart';
import 'package:wslconfigurer/models/config.dart';
import 'package:wslconfigurer/windows/msi.dart';

class UpdateKernel extends StatelessWidget {
  const UpdateKernel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: context.i18nText("install.manual"),
          trailing: IconButton(
            onPressed: () =>
                launchUrlString(AppConfigs.wslLinuxKernelUpdateInstallerUrl),
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
    );
  }
}
