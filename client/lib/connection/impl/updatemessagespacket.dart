import 'package:client/connection/connection.dart';
import 'dart:typed_data';

import 'package:client/connection/packet.dart';
import 'package:client/utils/bytebuffer.dart';

class UpdateMessagesPacket extends Packet {
  String? convo;
  int? startIndex;
  int? endIndex;

  Map<int, int>? manifest;
  int? code;

  UpdateMessagesPacket.write(this.convo, this.startIndex, this.endIndex);
  UpdateMessagesPacket.read();

  @override
  int getId() {
    return 6;
  }

  @override
  Uint8List write() {
    ByteBuf buf = ByteBuf.write();
    buf.writeString(convo!);
    buf.writeInt(startIndex!);
    buf.writeInt(endIndex!);
    return buf.toByteArray();
  }

  @override
  void read(Uint8List data) {
    code = data[0];
  }

  @override
  void handle(Connection connection) {}
}
