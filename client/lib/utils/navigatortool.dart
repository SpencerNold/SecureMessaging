import 'package:flutter/material.dart';

class NavigatorTool {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  static void push(Widget page) {
    navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) {
      return page;
    }));
  }

  static void pop() {
    navigatorKey.currentState!.pop();
  }

  static void pushAll(Widget page) {
    navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
      return page;
    }), (route) => false);
  }
}
