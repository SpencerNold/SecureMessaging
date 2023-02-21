import 'package:client/connection/connection.dart';
import 'dart:typed_data';

import 'package:client/connection/packet.dart';
import 'package:client/crypto/rsa.dart';
import 'package:client/utils/bytebuffer.dart';

class AuthPacket extends Packet {
  final String? _username;
  final String? _password;
  final PublicKey? _publicKey;
  final bool? _register;

  int? _code;

  AuthPacket.write(
    this._username,
    this._password,
    this._publicKey,
    this._register,
  );

  AuthPacket.read()
      : _username = null,
        _password = null,
        _publicKey = null,
        _register = null;

  @override
  int getId() {
    return 2;
  }

  @override
  Uint8List write() {
    final buf = ByteBuf.write();
    buf.writeString(_username!);
    buf.writeString(_password!);
    buf.writeBoolean(_register!);
    buf.writeBytes(_publicKey!.serialize());
    return buf.toByteArray();
  }

  @override
  void read(Uint8List data) {
    _code = data[0];
  }

  @override
  void handle(Connection connection) {
    connection.eventBus.onUserAthenticationResponse(connection, _code!);
  }
}
