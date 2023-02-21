import 'package:client/eventbus.dart';
import 'package:client/utils/colortheme.dart';
import 'package:client/utils/errors.dart';
import 'package:client/utils/navigatortool.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage(this._eventBus, {super.key});
  final MainEventBus _eventBus;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.background,
      body: Column(
        children: [
          const SizedBox(height: 130),
          const Text(
            "Secure+ Login",
            style: TextStyle(
              color: ColorTheme.title,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 45, right: 45),
            child: loginTextField(
              usernameController,
              false,
              Icons.person,
              "Username",
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 45, right: 45),
            child: loginTextField(
              passwordController,
              true,
              Icons.key,
              "Password",
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (usernameController.text.isEmpty) {
                Errors.flashError("Login Error", "Username field is blank!");
                return;
              }
              if (passwordController.text.isEmpty) {
                Errors.flashError("Login Error", "Password field is blank!");
                return;
              }
              _eventBus.sendAuth(
                usernameController.text,
                passwordController.text,
                false,
              );
              usernameController.clear();
              passwordController.clear();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                ColorTheme.background2,
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(
                top: 15,
                bottom: 15,
                left: 55,
                right: 55,
              ),
              child: Text(
                "Login",
                style: TextStyle(
                  color: ColorTheme.title,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 70, right: 70),
            child: InkWell(
              onTap: () {
                NavigatorTool.pop();
              },
              child: const Text(
                "Don't have an account? Register",
                style: TextStyle(
                  color: ColorTheme.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget loginTextField(TextEditingController controller, bool obscure,
    IconData icon, String placeholder) {
  return TextField(
    keyboardAppearance: Brightness.dark,
    controller: controller,
    obscureText: obscure,
    autocorrect: false,
    style: const TextStyle(
      color: ColorTheme.text,
      fontSize: 16,
    ),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: ColorTheme.text,
      ),
      hintText: placeholder,
      hintStyle: const TextStyle(color: ColorTheme.text),
      fillColor: ColorTheme.background2,
      filled: true,
      contentPadding: const EdgeInsets.all(10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: ColorTheme.background2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: ColorTheme.background2),
      ),
    ),
  );
}
