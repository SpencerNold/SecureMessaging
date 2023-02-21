import 'package:client/connection/connection.dart';
import 'package:client/connection/impl/sessionkeypacket.dart';
import 'dart:typed_data';

import 'package:client/connection/packet.dart';
import 'package:client/crypto/aes.dart';
import 'package:client/crypto/rsa.dart';

class PublicKeyPacket extends Packet {
  PublicKey? _publicKey;

  PublicKeyPacket.write(this._publicKey);
  PublicKeyPacket.read() : _publicKey = null;

  @override
  int getId() {
    return 0;
  }

  @override
  Uint8List write() {
    return _publicKey!.serialize();
  }

  @override
  void read(Uint8List data) {
    _publicKey = PublicKey.deserialize(data);
  }

  @override
  void handle(Connection connection) {
    connection.setServerKey(_publicKey!);
    connection.setState(1);
    Key key = Key.generate();
    connection.setEncryptionCipher(AES(key));
    connection.send(SessionKeyPacket.write(key));
  }
}
