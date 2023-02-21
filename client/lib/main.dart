import 'package:client/gateway.dart';
import 'package:client/pages/loadingpage.dart';
import 'package:client/utils/navigatortool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Add push notifications in the future
  runApp(const App());
  Gateway.startSocketIsolate();
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      navigatorKey: NavigatorTool.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const LoadingPage(),
    );
  }
}
