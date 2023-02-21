import 'dart:convert';
import 'dart:typed_data';

import 'package:client/utils/serializer.dart';

class ByteBuf {
  List<int> _data;

  ByteBuf.read(this._data);

  ByteBuf.write() : _data = [];

  void writeBytes(List<int> bytes) {
    _data.addAll(bytes);
  }

  void writeByte(int i) {
    writeBytes([i]);
  }

  void writeBoolean(bool b) {
    writeByte(b ? 1 : 0);
  }

  void writeShort(int i) {
    writeBytes(Serializer.shortToBytesBE(i));
  }

  void writeInt(int i) {
    writeBytes(Serializer.intToBytesBE(i));
  }

  void writeLong(int i) {
    writeBytes(Serializer.longToBytesBE(i));
  }

  void writeFloat(double d) {
    writeInt(Serializer.floatBitsToInt(d));
  }

  void writeDouble(double d) {
    writeLong(Serializer.doubleBitsToLong(d));
  }

  void writeString(String s) {
    writeInt(s.length);
    writeBytes(utf8.encode(s));
  }

  Uint8List readBytes(int n) {
    List<int> bytes = _data.sublist(0, n);
    _data = _data.sublist(n);
    return Uint8List.fromList(bytes);
  }

  int readByte() {
    return readBytes(1)[0];
  }

  bool readBoolean() {
    return readByte() == 1;
  }

  int readShort() {
    return Serializer.bytesToShortBE(readBytes(2));
  }

  int readInt() {
    return Serializer.bytesToIntBE(readBytes(4));
  }

  int readLong() {
    return Serializer.bytesToLongBE(readBytes(8));
  }

  double readFloat() {
    return Serializer.intBitsToFloat(readInt());
  }

  double readDouble() {
    return Serializer.longBitsToDouble(readLong());
  }

  String readString() {
    int size = readInt();
    return utf8.decode(readBytes(size));
  }

  Uint8List toByteArray() {
    return Uint8List.fromList(_data);
  }

  bool hasMoreData() {
    return _data.isNotEmpty;
  }

  int bytes() {
    return _data.length;
  }
}
