import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:client/connection/connection.dart';
import 'package:client/connection/impl/authpacket.dart';
import 'package:client/connection/impl/messagepacket.dart';
import 'package:client/connection/impl/newconversationpacket.dart';
import 'package:client/connection/impl/updateconvospacket.dart';
import 'package:client/connection/impl/updatemessagespacket.dart';
import 'package:client/connection/packetregistry.dart';
import 'package:client/conversation/conversation.dart';
import 'package:client/conversation/message.dart';
import 'package:client/crypto/rsa.dart';
import 'package:client/crypto/signer.dart';
import 'package:client/data/pathprovider.dart';
import 'package:client/data/clientstorage.dart';
import 'package:client/pages/chatroompage.dart';
import 'package:client/pages/conversationspage.dart';
import 'package:client/pages/loadingpage.dart';
import 'package:client/pages/registerpage.dart';
import 'package:client/utils/bytebuffer.dart';
import 'package:client/utils/errors.dart';
import 'package:client/utils/navigatortool.dart';

class MainEventBus {
  final SendPort _sendPort;

  MainEventBus(this._sendPort) {
    _sendApplicationSupportDirectory();
  }

  void onMessage(int index, Object message) {
    if (message is! List<dynamic>) return;
    if (message[0] == "push_register") {
      NavigatorTool.push(RegisterPage(this));
      if (message[1]) {
        Errors.flashError("Authentication Failed", message[2]);
      }
    } else if (message[0] == "update_convos") {
      List<Conversation> convos = message[1] as List<Conversation>;
      if (!ChatRoomPage.isOpen()) {
        NavigatorTool.push(ConversationPage(this, convos));
      }
    } else if (message[0] == "add_message") {
      String? openConvoName = ChatRoomPage.getCurrentConvoName();
      if (openConvoName == null) {
        return;
      }
      if (openConvoName != message[1]) {
        return;
      }
      ChatRoomPage.setMessage(message[1], message[2]);
    } else if (message[0] == "set_message") {
      String? openConvoName = ChatRoomPage.getCurrentConvoName();
      if (openConvoName == null) {
        return;
      }
      if (openConvoName != message[1]) {
        return;
      }
      ChatRoomPage.setMessage(message[1], message[2]);
    } else if (message[0] == "send_image_state_update") {
      if (message[1]) {
        ChatRoomPage.incrementSendingImages();
      } else {
        ChatRoomPage.decrementSendingImages();
      }
    } else if (message[0] == "socket_exception") {
      Errors.displayError(
        "Connection error",
        "Unable to connect with the server, please check your internet connection and try again.",
        "Try Again",
        () {
          NavigatorTool.pushAll(const LoadingPage());
          _sendApplicationSupportDirectory();
        },
      );
    } else if (message[0] == "error") {
      Errors.flashError(message[1], message[2]);
    }
  }

  void _send(List<dynamic> data) {
    _sendPort.send(data);
  }

  Future<void> _sendApplicationSupportDirectory() async {
    String dir = await PathProvider.getAppSupportDir();
    _send(["init", dir]);
  }

  void sendAuth(String username, String password, bool register) {
    _send(["send_auth", username, password, register]);
  }

  void sendNewConversation(String name, String icon, List<String> users) {
    _send(["send_new_convo", name, icon, users]);
  }

  void sendUpdateMessages(Conversation conversation) {
    _send(["update_messages", conversation]);
  }

  void sendMessage(String convo, int type, Uint8List message) {
    _send(["send_message", convo, type, message]);
  }
}

class SocketEventBus {
  final SendPort _sendPort;

  Connection? _connection;
  ClientStorage? _clientStorage;
  Header? _header;
  KeyPair? _keyPair;
  List<Conversation> conversations = [];

  SocketEventBus(this._sendPort);

  void onMessage(int index, Object message) {
    if (message is! List<dynamic>) return;
    if (message[0] == "init") {
      _clientStorage = ClientStorage(message[1]);
      _header = _clientStorage!.load();
      _keyPair = KeyPair.generate();
      PacketRegistry.init();
      _asyncConnect();
    } else if (message[0] == "send_auth") {
      KeyPair keyPair = _header == null ? _keyPair! : _header!.keyPair;
      _connection!.send(AuthPacket.write(
        message[1],
        message[2],
        keyPair.publicKey,
        message[3],
      ));
      _header = Header(message[1], message[2], keyPair);
    } else if (message[0] == "update_messages") {
      Conversation convo = message[1] as Conversation;
      _connection!.send(UpdateMessagesPacket.write(convo.name, -25, -1));
    } else if (message[0] == "send_message") {
      _send(["send_image_state_update", true]);
      Uint8List bytes = message[3];
      RSASigner signer = RSASigner();
      Uint8List signature = signer.sign(_header!.keyPair.privateKey, bytes);
      _connection!.send(MessagePacket.write(
        message[1],
        _header!.username,
        message[2],
        bytes,
        signature,
      ));
      _send(["send_image_state_update", false]);
    } else if (message[0] == "send_new_convo") {
      String? icon = message[2].isEmpty ? null : message[2];
      List<String> users = message[3];
      if (!users.contains(_header!.username)) {
        users.add(_header!.username);
      }
      Conversation convo = Conversation(message[1], icon, users);
      _connection!.send(NewConversationPacket.write(convo));
    }
  }

  void _asyncConnect() async {
    _connection = await Connection.open(this, "127.0.0.1", 8192);
  }

  void _send(List<dynamic> data) {
    _sendPort.send(data);
  }

  void onConnectionFailure() {
    _send(["socket_exception"]);
  }

  void onSecureConnectionEstablished(Connection connection) {
    if (_header == null) {
      _send(["push_register", false]);
    } else {
      connection.send(AuthPacket.write(
        _header!.username,
        _header!.password,
        _header!.keyPair.publicKey,
        false,
      ));
    }
  }

  void onUserAthenticationResponse(Connection connection, int code) {
    if (code == 0) {
      connection.send(UpdateConvosPacket.write());
      _clientStorage!.save(_header!);
    } else {
      _send(["push_register", true, "User with this name already exists!"]);
    }
  }

  void onConvoCreated(Connection connection, int code) {
    if (code == 0) {
      _connection!.send(UpdateConvosPacket.write());
    } else {
      String message = "";
      if (code == 1) {
        message = "System error, please try again!";
      } else if (code == 2) {
        // implement this error in the future, it really doesn't matter
      } else if (code == 3) {
        message = "Invalid users, please remove and try again!";
      }
      _send([
        "error",
        "Convo creation failed",
        message,
      ]);
    }
  }

  void onUpdateConvos(Connection connection, List<Conversation> convos) {
    conversations = convos;
    _send(["update_convos", convos]);
  }

  void onMessageReceived(
    String convo,
    String from,
    int index,
    int type,
    Uint8List message,
    Uint8List signature,
  ) {
    bool sent = from == _header!.username;
    if (type == 0) {
      TextMessage textMessage = TextMessage(
        index,
        sent,
        from,
        utf8.decode(message),
      );
      _send(["add_message", convo, textMessage]);
    } else if (type == 1) {
      ByteBuf buf = ByteBuf.read(message);
      double width = buf.readDouble();
      double height = buf.readDouble();
      Uint8List bytes = buf.toByteArray();
      ImageMessage imageMessage = ImageMessage(
        index,
        sent,
        from,
        width,
        height,
        bytes,
      );
      _send(["add_message", convo, imageMessage]);
    } else if (type == 2) {
      PlaceholderImageMessage placeholderImageMessage = PlaceholderImageMessage(
        index,
        sent,
        from,
      );
      _send(["add_message", convo, placeholderImageMessage]);
    } else if (type == 3) {
      ByteBuf buf = ByteBuf.read(message);
      double width = buf.readDouble();
      double height = buf.readDouble();
      Uint8List bytes = buf.toByteArray();
      ImageMessage imageMessage = ImageMessage(
        index,
        sent,
        from,
        width,
        height,
        bytes,
      );
      _send(["set_message", convo, imageMessage]);
    }
  }
}
