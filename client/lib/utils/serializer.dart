import 'dart:typed_data';

class Serializer {
  static Uint8List shortToBytesBE(int i) {
    return Uint8List(2)..buffer.asByteData().setInt16(0, i, Endian.big);
  }

  static Uint8List intToBytesBE(int i) {
    return Uint8List(4)..buffer.asByteData().setInt32(0, i, Endian.big);
  }

  static Uint8List longToBytesBE(int i) {
    return Uint8List(8)..buffer.asByteData().setInt64(0, i, Endian.big);
  }

  static int bytesToShortBE(Uint8List bytes) {
    return bytes.buffer.asByteData().getInt16(0, Endian.big);
  }

  static int bytesToIntBE(Uint8List bytes) {
    return bytes.buffer.asByteData().getInt32(0, Endian.big);
  }

  static int bytesToLongBE(Uint8List bytes) {
    return bytes.buffer.asByteData().getInt64(0, Endian.big);
  }

  static int floatBitsToInt(double d) {
    return (ByteData(4)..setFloat32(0, d)).getInt32(0);
  }

  static int doubleBitsToLong(double d) {
    return (ByteData(8)..setFloat64(0, d)).getInt64(0);
  }

  static double intBitsToFloat(int i) {
    return (ByteData(4)..setInt32(0, i)).getFloat32(0);
  }

  static double longBitsToDouble(int i) {
    return (ByteData(8)..setInt64(0, i)).getFloat64(0);
  }

  static Uint8List bigIntToBytes(BigInt bigInt) {
    Uint8List data = Uint8List((bigInt.bitLength / 8).ceil() + 1);
    for (var i = data.length - 1; i >= 0; i--) {
      data[i] = bigInt.toUnsigned(8).toInt();
      bigInt >>= 8;
    }
    return data;
  }

  static BigInt bytesToBigInt(Uint8List bytes) {
    BigInt modulus = BigInt.zero;
    for (var i = 0; i < bytes.length; i++) {
      modulus <<= 8;
      modulus |= BigInt.from(bytes[i]);
    }
    return modulus;
  }
}
