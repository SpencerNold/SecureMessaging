import 'package:path_provider/path_provider.dart';

class PathProvider {
  static Future<String> getAppSupportDir() async {
    return (await getApplicationSupportDirectory()).absolute.path;
  }
}
