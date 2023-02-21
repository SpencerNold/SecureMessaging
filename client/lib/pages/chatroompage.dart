import 'dart:convert';
import 'dart:typed_data';

import 'package:client/conversation/conversation.dart';
import 'package:client/conversation/message.dart';
import 'package:client/eventbus.dart';
import 'package:client/pages/imagepicker.dart';
import 'package:client/utils/colortheme.dart';
import 'package:client/utils/navigatortool.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage(this._eventBus, this._conversation, {super.key});

  final MainEventBus _eventBus;
  final Conversation _conversation;

  static _ChatRoomPageState? _currentOpenState;

  static void setMessage(String convo, Message message) {
    if (_currentOpenState != null) {
      if (_currentOpenState!.widget._conversation.name == convo) {
        _currentOpenState!.setMessage(message);
      }
    }
  }

  static void incrementSendingImages() {
    if (_currentOpenState != null) {
      _currentOpenState!.setSendingImages(_currentOpenState!._sending + 1);
    }
  }

  static void decrementSendingImages() {
    if (_currentOpenState != null) {
      _currentOpenState!.setSendingImages(_currentOpenState!._sending - 1);
    }
  }

  static bool isOpen() {
    return _currentOpenState != null;
  }

  static String? getCurrentConvoName() {
    if (_currentOpenState == null) {
      return null;
    }
    return _currentOpenState!.widget._conversation.name;
  }

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();

  final List<Message?> messages = [];
  int _sending = 0;

  @override
  void initState() {
    ChatRoomPage._currentOpenState = this;
    widget._eventBus.sendUpdateMessages(widget._conversation);
    super.initState();
  }

  @override
  void dispose() {
    ChatRoomPage._currentOpenState = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorTheme.banner,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    NavigatorTool.pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: ColorTheme.title,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.group,
                  color: ColorTheme.title,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget._conversation.name,
                        style: const TextStyle(
                          color: ColorTheme.title,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget._conversation.users.join(", "),
                        style: const TextStyle(
                          color: ColorTheme.text,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            reverse: true,
            child: Column(
              children: List.generate(
                messages.length,
                (index) {
                  if (messages[index] == null) {
                    return Container();
                  }
                  bool sent = messages[index]!.sent;
                  return Container(
                    padding: EdgeInsets.only(
                      left: sent ? 65 : 10,
                      right: sent ? 10 : 65,
                      top: 3,
                      bottom: 3,
                    ),
                    child: Align(
                      alignment: sent ? Alignment.topRight : Alignment.topLeft,
                      child: messages[index]!.getWidget(context),
                    ),
                  );
                },
              )
                ..add(
                  _sending == 0
                      ? Container()
                      : Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, right: 25),
                            child: Text(
                              "Sending $_sending image(s)...",
                              style: const TextStyle(color: ColorTheme.text),
                            ),
                          ),
                        ),
                )
                ..add(const SizedBox(height: 75)),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      NavigatorTool.push(ImagePicker(
                        widget._eventBus,
                        widget._conversation,
                      ));
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(const Size(45, 45)),
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      backgroundColor:
                          MaterialStateProperty.all(ColorTheme.theme),
                    ),
                    child: const Icon(
                      Icons.upload,
                      color: ColorTheme.title,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) {
                        if (messageController.text.isEmpty) return;
                        widget._eventBus.sendMessage(
                          widget._conversation.name,
                          0,
                          Uint8List.fromList(
                            utf8.encode(messageController.text),
                          ),
                        );
                        messageController.clear();
                        messageFocusNode.requestFocus();
                      },
                      controller: messageController,
                      focusNode: messageFocusNode,
                      style: const TextStyle(color: ColorTheme.text),
                      decoration: InputDecoration(
                        hintText: "Message...",
                        hintStyle: const TextStyle(
                          color: ColorTheme.text,
                          fontSize: 18,
                        ),
                        fillColor: ColorTheme.background3,
                        contentPadding: const EdgeInsets.all(10),
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: ColorTheme.background3,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: ColorTheme.background3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (messageController.text.isEmpty) return;
                      widget._eventBus.sendMessage(
                        widget._conversation.name,
                        0,
                        Uint8List.fromList(utf8.encode(messageController.text)),
                      );
                      messageController.clear();
                      messageFocusNode.requestFocus();
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(const Size(45, 45)),
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      backgroundColor:
                          MaterialStateProperty.all(ColorTheme.theme),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: ColorTheme.title,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addMessage(Message message) {
    setState(() {
      messages.add(message);
    });
  }

  void setMessage(Message message) {
    setState(() {
      if (message.index >= messages.length) {
        int diff = message.index - messages.length + 1;
        for (int i = 0; i < diff; i++) {
          messages.add(null);
        }
      }
      messages[message.index] = message;
    });
  }

  void setSendingImages(int sending) {
    setState(() {
      _sending = sending;
    });
  }
}
