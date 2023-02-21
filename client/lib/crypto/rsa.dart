import 'package:client/crypto/dartsecurerandom.dart';
import 'package:client/utils/serializer.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

const _publicExponent = 65537;

class RSA {
  final AsymmetricBlockCipher _cipher;

  RSA() : _cipher = OAEPEncoding.withSHA256(RSAEngine());

  Uint8List encrypt(PublicKey key, Uint8List bytes) {
    _cipher
      ..reset()
      ..init(true, PublicKeyParameter<RSAPublicKey>(key.publicKey));
    return _cipher.process(bytes);
  }

  Uint8List decrypt(PrivateKey key, Uint8List bytes) {
    _cipher
      ..reset()
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(key.privateKey));
    return _cipher.process(bytes);
  }
}

class PublicKey {
  final RSAPublicKey publicKey;

  PublicKey(this.publicKey);

  BigInt modulus() {
    return publicKey.modulus!;
  }

  Uint8List serialize() {
    BigInt modulus = publicKey.modulus!;
    Uint8List data = Uint8List((modulus.bitLength / 8).ceil() + 1);
    for (var i = data.length - 1; i >= 0; i--) {
      data[i] = modulus.toUnsigned(8).toInt();
      modulus >>= 8;
    }
    return data;
  }

  static PublicKey deserialize(Uint8List array) {
    array = array.sublist(1);
    BigInt modulus = Serializer.bytesToBigInt(array);
    return PublicKey(
        RSAPublicKey(modulus, BigInt.parse(_publicExponent.toString())));
  }
}

class PrivateKey {
  final RSAPrivateKey privateKey;

  PrivateKey(this.privateKey);

  Uint8List serialize() {
    List<int> data = [];
    data.addAll(Serializer.bigIntToBytes(privateKey.modulus!));
    data.addAll(Serializer.bigIntToBytes(privateKey.privateExponent!));
    data.addAll(Serializer.bigIntToBytes(privateKey.p!));
    data.addAll(Serializer.bigIntToBytes(privateKey.q!));
    return Uint8List.fromList(data);
  }

  static PrivateKey deserialize(Uint8List bytes) {
    final modulus = Serializer.bytesToBigInt(bytes.sublist(0, 513));
    final privateExponent = Serializer.bytesToBigInt(bytes.sublist(513, 1026));
    final p = Serializer.bytesToBigInt(bytes.sublist(1026, 1283));
    final q = Serializer.bytesToBigInt(bytes.sublist(1283, 1540));
    return PrivateKey(RSAPrivateKey(modulus, privateExponent, p, q));
  }
}

class KeyPair {
  PublicKey publicKey;
  PrivateKey privateKey;

  KeyPair(this.publicKey, this.privateKey);

  static KeyPair generate() {
    final generator = RSAKeyGenerator();
    generator.init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(
            BigInt.parse(_publicExponent.toString()), 4096, 64),
        SecureRandom("Fortuna")
          ..seed(KeyParameter(DartSecureRandom.nextBytes(32))),
      ),
    );
    final pair = generator.generateKeyPair();
    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;
    return KeyPair(
      PublicKey(publicKey),
      PrivateKey(privateKey),
    );
  }

  Uint8List serialize() {
    List<int> data = [];
    data.addAll(publicKey.serialize());
    data.addAll(privateKey.serialize());
    return Uint8List.fromList(data);
  }

  static KeyPair deserialize(Uint8List data) {
    PublicKey publicKey = PublicKey.deserialize(data.sublist(0, 513));
    PrivateKey privateKey = PrivateKey.deserialize(data.sublist(513, 2053));
    return KeyPair(publicKey, privateKey);
  }
}
