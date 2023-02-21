import 'package:client/connection/connection.dart';
import 'dart:typed_data';

import 'package:client/connection/packet.dart';
import 'package:client/conversation/conversation.dart';
import 'package:client/utils/bytebuffer.dart';

class UpdateConvosPacket extends Packet {
  final List<Conversation> conversations = [];

  UpdateConvosPacket.write();
  UpdateConvosPacket.read();

  @override
  int getId() {
    return 4;
  }

  @override
  Uint8List write() {
    return Uint8List(0);
  }

  @override
  void read(Uint8List data) {
    conversations.clear();
    ByteBuf buf = ByteBuf.read(data);
    int size = buf.readInt();
    for (int i = 0; i < size; i++) {
      String name = buf.readString();
      bool b = buf.readBoolean();
      String? icon;
      if (b) {
        icon = buf.readString();
      }
      int usize = buf.readInt();
      List<String> users = [];
      for (int i = 0; i < usize; i++) {
        users.add(buf.readString());
      }
      conversations.add(Conversation(name, icon, users));
    }
  }

  @override
  void handle(Connection connection) {
    connection.eventBus.onUpdateConvos(connection, conversations);
  }
}
