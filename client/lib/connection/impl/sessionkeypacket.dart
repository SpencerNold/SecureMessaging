import 'dart:typed_data';

import 'package:client/connection/connection.dart';
import 'package:client/connection/packet.dart';
import 'package:client/crypto/aes.dart';

class SessionKeyPacket extends Packet {
  Key? _key;

  SessionKeyPacket.write(this._key);
  SessionKeyPacket.read() : _key = null;

  @override
  int getId() {
    return 1;
  }

  @override
  Uint8List write() {
    return _key!.serialize();
  }

  @override
  void read(Uint8List data) {
    _key = Key.deserialize(data);
  }

  @override
  void handle(Connection connection) {
    connection.setDecryptionCipher(AES(_key!));
    connection.setState(2);
    connection.eventBus.onSecureConnectionEstablished(connection);
  }
}
