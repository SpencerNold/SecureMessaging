import 'package:client/connection/connection.dart';
import 'dart:typed_data';

import 'package:client/connection/packet.dart';
import 'package:client/conversation/conversation.dart';
import 'package:client/utils/bytebuffer.dart';
import 'package:client/utils/serializer.dart';

class NewConversationPacket extends Packet {
  Conversation? _conversation;

  int? code;

  NewConversationPacket.write(this._conversation);
  NewConversationPacket.read();

  @override
  int getId() {
    return 3;
  }

  @override
  Uint8List write() {
    ByteBuf buf = ByteBuf.write();
    buf.writeString(_conversation!.name);
    bool b = _conversation!.icon != null;
    buf.writeBoolean(b);
    if (b) {
      buf.writeString(_conversation!.icon!);
    }
    buf.writeInt(_conversation!.users.length);
    for (String s in _conversation!.users) {
      buf.writeString(s);
    }
    return buf.toByteArray();
  }

  @override
  void read(Uint8List data) {
    code = Serializer.bytesToIntBE(data);
  }

  @override
  void handle(Connection connection) {
    connection.eventBus.onConvoCreated(connection, code!);
  }
}
