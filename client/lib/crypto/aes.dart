import 'dart:typed_data';

import 'package:client/crypto/dartsecurerandom.dart';
import 'package:pointycastle/export.dart';

class AES {
  static const int _ivLength = 12;

  final Key _secretKey;
  final BlockCipher _cipher;

  AES(this._secretKey) : _cipher = GCMBlockCipher(AESEngine());

  Uint8List encryptBytes(Uint8List bytes) {
    final iv = DartSecureRandom.nextBytes(_ivLength);
    _cipher
      ..reset()
      ..init(
        true,
        AEADParameters(
          KeyParameter(_secretKey._bytes),
          128,
          iv,
          Uint8List.fromList([]),
        ),
      );
    List<int> data = [];
    data.addAll(iv);
    data.addAll(_cipher.process(bytes));
    return Uint8List.fromList(data);
  }

  Uint8List decryptBytes(Uint8List bytes) {
    final iv = bytes.sublist(0, _ivLength);
    _cipher
      ..reset()
      ..init(
        false,
        AEADParameters(
          KeyParameter(_secretKey._bytes),
          128,
          iv,
          Uint8List.fromList([]),
        ),
      );
    return _cipher.process(bytes.sublist(_ivLength));
  }

  Key getKey() {
    return _secretKey;
  }
}

class Key {
  final Uint8List _bytes;

  Key._(this._bytes);

  Uint8List serialize() {
    return _bytes;
  }

  static Key deserialize(Uint8List data) {
    return Key._(data);
  }

  static Key generate() {
    return Key._(DartSecureRandom.nextBytes(32));
  }
}
