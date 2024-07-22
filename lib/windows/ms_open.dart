import 'dart:io';

import 'package:url_launcher/url_launcher_string.dart';

void openMSStoreProduct(String productID) {
  launchUrlString("ms-windows-store://pdp?productid=$productID");
}

void openMSSetting(String name) {
  launchUrlString("ms-settings:$name");
}

void openInExplorer(String path) async {
  await Process.run("explorer.exe", [path]);
}

void openWSLDirExplorer() async => openInExplorer("C:\\Program Files\\WSL");