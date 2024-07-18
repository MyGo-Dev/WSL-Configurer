import 'package:url_launcher/url_launcher_string.dart';

void openStoreProduct(String productID) {
  launchUrlString("ms-windows-store://pdp?productid=$productID");
}
