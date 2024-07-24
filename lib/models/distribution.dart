import 'dart:convert';
import 'dart:io';

import 'package:arche/arche.dart';
import 'package:wslconfigurer/models/config.dart';

class LinuxDistribution {
  late final String name;
  late final String friendlyName;
  late final String storeAppId;
  late final bool amd64;
  late final bool arm64;
  late final String? amd64PackageUrl;
  late final String? arm64PackageUrl;
  late final String packageFamilyName;

  static FutureLazyDynamicCan<List<LinuxDistribution>> distributions =
      FutureLazyDynamicCan(
    builder: fetch,
  );

  static Future<List<LinuxDistribution>> fetch() async {
    var url = ArcheBus()
        .of<AppConfigs>()
        .distroInfoUrl
        .getOr(AppConfigs.defaultDistroInfoUrl);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    Iterable json = jsonDecode(
        await response.transform(utf8.decoder).join())["Distributions"];

    return json
        .map(
          (distro) => LinuxDistribution()
            ..name = distro["Name"]
            ..friendlyName = distro["FriendlyName"]
            ..storeAppId = distro["StoreAppId"]
            ..amd64 = distro["Amd64"]
            ..arm64 = distro["Arm64"]
            ..amd64PackageUrl = distro["Amd64PackageUrl"]
            ..arm64PackageUrl = distro["Arm64PackageUrl"]
            ..packageFamilyName = distro["PackageFamilyName"],
        )
        .toList();
  }

  @override
  String toString() {
    return "LinuxDistribution: $name";
  }
}
