import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'package:client/crypto/rsa.dart' as rsa;

class RSASigner {
  final Signer _signer;

  RSASigner() : _signer = Signer("SHA-256/RSA");

  Uint8List sign(rsa.PrivateKey privateKey, Uint8List data) {
    _signer.init(
        true, PrivateKeyParameter<RSAPrivateKey>(privateKey.privateKey));
    return (_signer.generateSignature(data) as RSASignature).bytes;
  }

  bool verify(rsa.PublicKey publicKey, Uint8List data, Uint8List signature) {
    _signer.init(false, PublicKeyParameter<RSAPublicKey>(publicKey.publicKey));
    return _signer.verifySignature(data, RSASignature(signature));
  }
}
