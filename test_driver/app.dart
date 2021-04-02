import 'package:flutter_driver/driver_extension.dart';
import 'package:cartas/main.dart' as app;
import 'package:get_storage/get_storage.dart';

void main() async {
  enableFlutterDriverExtension();
  var box = GetStorage();
  await box.erase();
  // Call the `main()` function of the app, or call `runApp` with
  // any widget you are interested in testing.
  app.main();
}
