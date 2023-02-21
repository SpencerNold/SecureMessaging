import 'package:client/eventbus.dart';
import 'package:client/utils/colortheme.dart';
import 'package:client/utils/errors.dart';
import 'package:client/utils/navigatortool.dart';
import 'package:flutter/material.dart';

class NewConversationPage extends StatefulWidget {
  const NewConversationPage(this._eventBus, {super.key});

  final MainEventBus _eventBus;

  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  final TextEditingController userController = TextEditingController();

  List<String> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 130),
            const Text(
              "New Conversation",
              style: TextStyle(
                color: ColorTheme.title,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 45, right: 45),
              child: _loginTextField(
                nameController,
                false,
                true,
                Icons.dehaze,
                "Name",
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 45, right: 45),
              child: _loginTextField(
                iconController,
                false,
                true,
                Icons.person_add,
                "Icon (optional)",
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 45, right: 45),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(users.length, (index) {
                    return Container(
                      padding: const EdgeInsets.only(left: 25, right: 10),
                      decoration: BoxDecoration(
                        color: ColorTheme.background2,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Text(
                            users[index],
                            style: const TextStyle(
                              color: ColorTheme.title,
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                users.removeAt(index);
                              });
                            },
                            splashRadius: 1,
                            icon: const Icon(
                              Icons.close,
                              color: ColorTheme.title,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 45, right: 45),
              child: _loginTextField(
                userController,
                false,
                true,
                Icons.person_add,
                "Contact",
              ),
            ),
            const SizedBox(height: 20),
            _button(
              name: "Add",
              onPressed: () {
                if (userController.text.isEmpty) {
                  Errors.flashError(
                    "Failed to add user!",
                    "Contact field is empty, please input a user's name",
                  );
                  return;
                }
                setState(() {
                  users.add(userController.text);
                  userController.text = "";
                });
              },
            ),
            const SizedBox(height: 40),
            _button(
              name: "Create",
              onPressed: () {
                if (nameController.text.isEmpty) {
                  Errors.flashError("Error", "Please name this group chat!");
                  return;
                }
                if (users.isEmpty) {
                  Errors.flashError("Error", "Please add users to your group!");
                  return;
                }
                widget._eventBus.sendNewConversation(
                  nameController.text,
                  iconController.text,
                  users,
                );
                nameController.clear();
                iconController.clear();
              },
            ),
            const SizedBox(height: 20),
            _button(
              name: "Back",
              onPressed: () => NavigatorTool.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _button({required String name, required Function() onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ButtonStyle(
      fixedSize: MaterialStateProperty.all(const Size(200, 50)),
      backgroundColor: MaterialStateProperty.all(
        ColorTheme.background2,
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.only(
        top: 15,
        bottom: 15,
        left: 55,
        right: 55,
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: ColorTheme.title,
          fontSize: 16,
        ),
      ),
    ),
  );
}

Widget _loginTextField(TextEditingController? controller, bool obscure,
    bool editable, IconData icon, String placeholder) {
  return TextField(
    keyboardType: TextInputType.text,
    keyboardAppearance: Brightness.dark,
    controller: controller,
    obscureText: obscure,
    autocorrect: false,
    enabled: editable,
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: ColorTheme.background2),
      ),
    ),
  );
}
