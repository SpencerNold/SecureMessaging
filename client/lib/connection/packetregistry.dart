import 'dart:typed_data';

import 'package:client/connection/impl/authpacket.dart';
import 'package:client/connection/impl/messagepacket.dart';
import 'package:client/connection/impl/newconversationpacket.dart';
import 'package:client/connection/impl/publickeypacket.dart';
import 'package:client/connection/impl/sessionkeypacket.dart';
import 'package:client/connection/impl/updateconvospacket.dart';
import 'package:client/connection/impl/updatemessagespacket.dart';
import 'package:client/connection/packet.dart';

class PacketRegistry {
  static final Map<int, Packet Function()> _registeredPackets = {};

  static void init() {
    _registeredPackets.clear();
    // Handshake
    _register(0, () => PublicKeyPacket.read());
    _register(1, () => SessionKeyPacket.read());
    // Auth
    _register(2, () => AuthPacket.read());
    // Functional
    _register(3, () => NewConversationPacket.read());
    _register(4, () => UpdateConvosPacket.read());
    _register(5, () => MessagePacket.read());
    _register(6, () => UpdateMessagesPacket.read());
  }

  static void _register(int id, Packet Function() function) {
    _registeredPackets[id] = function;
  }

  static Packet? read(int id, Uint8List data) {
    Packet Function()? func = _registeredPackets[id];
    if (func == null) {
      return null;
    }
    Packet packet = func();
    packet.read(data);
    return packet;
  }
}
