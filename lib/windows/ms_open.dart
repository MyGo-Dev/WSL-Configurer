import 'package:url_launcher/url_launcher_string.dart';

void openMSStoreProduct(String productID) {
  launchUrlString("ms-windows-store://pdp?productid=$productID");
}

void openMSSetting(String name) {
  launchUrlString("ms-settings:$name");
}
