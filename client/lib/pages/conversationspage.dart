import 'package:client/conversation/conversation.dart';
import 'package:client/eventbus.dart';
import 'package:client/pages/chatroompage.dart';
import 'package:client/pages/newconversationpage.dart';
import 'package:client/utils/colortheme.dart';
import 'package:client/utils/navigatortool.dart';
import 'package:flutter/material.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage(this._eventBus, this._conversations, {super.key});

  final MainEventBus _eventBus;
  final List<Conversation> _conversations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autocorrect: false,
                        style: const TextStyle(
                          color: ColorTheme.text,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search...",
                          hintStyle: const TextStyle(color: ColorTheme.text),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: ColorTheme.text,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: ColorTheme.background2,
                          contentPadding: const EdgeInsets.all(10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: ColorTheme.background2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: ColorTheme.background2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    ElevatedButton(
                      onPressed: () {
                        NavigatorTool.push(NewConversationPage(_eventBus));
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          ColorTheme.theme,
                        ),
                        shape: MaterialStateProperty.all(
                          const CircleBorder(),
                        ),
                        fixedSize: MaterialStateProperty.all(
                          const Size(45, 45),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: ColorTheme.title,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _conversations.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "No contacts",
                        style: TextStyle(
                          color: ColorTheme.text,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: List.generate(
                      _conversations.length,
                      (index) {
                        return conversation(_conversations[index]);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget conversation(Conversation conversation) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: () {
        NavigatorTool.push(ChatRoomPage(_eventBus, conversation));
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  conversation.icon == null
                      ? const Icon(
                          Icons.group,
                          color: ColorTheme.title,
                          size: 30,
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(conversation.icon!),
                          maxRadius: 30,
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.theme,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            conversation.users.join(", "),
                            style: const TextStyle(
                              fontSize: 13,
                              color: ColorTheme.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
