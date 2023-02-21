import 'dart:io';

import 'package:client/utils/navigatortool.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Errors {
  static void flashError(String title, String message) {
    final context = NavigatorTool.navigatorKey.currentContext!;
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.all(16),
        height: 90,
        decoration: const BoxDecoration(
          color: Color(0xffc72c41),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void displayError(
    String title,
    String content,
    String message,
    Function() action,
  ) async {
    final context = NavigatorTool.navigatorKey.currentContext!;

    final wtitle = Text(title);
    final wcontent = SingleChildScrollView(
      child: ListBody(
        children: [
          Text(content),
        ],
      ),
    );
    final wactions = [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          action();
        },
        child: Text(message),
      ),
    ];

    final dialog = Platform.isIOS
        ? CupertinoAlertDialog(
            title: wtitle,
            content: wcontent,
            actions: wactions,
          )
        : AlertDialog(
            title: wtitle,
            content: wcontent,
            actions: wactions,
          );

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return dialog;
      },
    );
  }
}
