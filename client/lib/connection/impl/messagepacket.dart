import 'dart:convert';

import 'dart:typed_data';

import 'package:client/connection/connection.dart';
import 'package:client/connection/packet.dart';
import 'package:client/utils/bytebuffer.dart';

class MessagePacket extends Packet {
  String? convo;
  String? from;
  int? index;
  int? type;
  Uint8List? message;
  Uint8List? signature;

  MessagePacket.write(
    this.convo,
    this.from,
    this.type,
    this.message,
    this.signature,
  );
  MessagePacket.read();

  @override
  int getId() {
    return 5;
  }

  @override
  Uint8List write() {
    ByteBuf buf = ByteBuf.write();
    buf.writeString(convo!);
    buf.writeString(from!);
    buf.writeByte(type!);
    buf.writeString(base64Encode(message!));
    buf.writeString(base64Encode(signature!));
    return buf.toByteArray();
  }

  @override
  void read(Uint8List data) {
    ByteBuf buf = ByteBuf.read(data);
    convo = buf.readString();
    from = buf.readString();
    index = buf.readInt();
    type = buf.readByte();
    message = base64Decode(buf.readString());
    signature = base64Decode(buf.readString());
  }

  @override
  void handle(Connection connection) {
    connection.eventBus.onMessageReceived(
      convo!,
      from!,
      index!,
      type!,
      message!,
      signature!,
    );
  }
}
