import 'dart:convert';
import 'dart:io';

import 'package:client/connection/impl/publickeypacket.dart';
import 'package:client/connection/packet.dart';
import 'package:client/connection/packetregistry.dart';
import 'package:client/crypto/rsa.dart';
import 'package:client/crypto/aes.dart';
import 'package:client/eventbus.dart';
import 'package:flutter/foundation.dart';

class Connection {
  final Socket _socket;
  final ClientData _clientData;
  final SocketEventBus eventBus;

  Connection(this._socket, this._clientData, this.eventBus);

  void send(Packet packet) async {
    List<int> bytes = [packet.getId()];
    bytes.addAll(packet.write());
    if (_clientData.state == 1) {
      bytes = _clientData.encryptRSA(Uint8List.fromList(bytes));
    } else if (_clientData.state == 2) {
      bytes = _clientData.encryptAES(Uint8List.fromList(bytes));
    }
    _socket.add(utf8.encode("|${base64Encode(bytes)}|\n"));
  }

  Future<void> _listen() async {
    int lastOpenIndex = -1;
    List<int> open = [];
    await for (final line in _socket) {
      for (int i = 0; i < line.length; i++) {
        if (line[i] == 124) {
          if (open.isNotEmpty) {
            open.addAll(line.sublist(0, i));
            _handlePacket(Uint8List.fromList(open));
            open.clear();
            lastOpenIndex = -1;
          } else if (lastOpenIndex != -1) {
            _handlePacket(line.sublist(lastOpenIndex + 1, i));
            lastOpenIndex = -1;
          } else {
            lastOpenIndex = i;
          }
        }
      }
      if (lastOpenIndex != -1) {
        open.addAll(line.sublist(lastOpenIndex + (open.isEmpty ? 1 : 0)));
      }
    }
    eventBus.onConnectionFailure();
  }

  Future<void> _handlePacket(Uint8List bytes) async {
    bytes = base64Decode(utf8.decode(bytes));
    if (_clientData.state == 1) {
      bytes = _clientData.decryptRSA(Uint8List.fromList(bytes));
    } else if (_clientData.state == 2) {
      //bytes = _clientData.decryptAES(Uint8List.fromList(bytes));
      bytes = await compute(_clientData.decryptAES, bytes);
    }
    Packet? packet = PacketRegistry.read(bytes[0], bytes.sublist(1));
    if (packet != null) {
      packet.handle(this);
    }
  }

  void close() {
    _socket.close();
  }

  static Future<Connection?> open(
    SocketEventBus eventBus,
    String host,
    int port,
  ) async {
    KeyPair clientKeys = KeyPair.generate();
    Socket? socket;
    try {
      socket = await Socket.connect(host, port);
    } on SocketException {
      eventBus.onConnectionFailure();
      return null;
    }
    Connection connection = Connection(
      socket,
      ClientData(clientKeys),
      eventBus,
    );
    PublicKeyPacket packet = PublicKeyPacket.write(clientKeys.publicKey);
    connection.send(packet);
    connection._listen();
    return connection;
  }

  void setState(int state) {
    _clientData.state = state;
  }

  void setServerKey(PublicKey publicKey) {
    _clientData.serverKey = publicKey;
  }

  void setEncryptionCipher(AES aes) {
    _clientData.ecipher = aes;
  }

  void setDecryptionCipher(AES aes) {
    _clientData.dcipher = aes;
  }
}

class ClientData {
  final KeyPair clientKeys;
  PublicKey? serverKey;
  AES? ecipher;
  AES? dcipher;
  int state = 0;

  ClientData(this.clientKeys);

  Uint8List encryptRSA(Uint8List bytes) {
    return RSA().encrypt(serverKey!, bytes);
  }

  Uint8List decryptRSA(Uint8List bytes) {
    return RSA().decrypt(clientKeys.privateKey, bytes);
  }

  Uint8List encryptAES(Uint8List bytes) {
    return ecipher!.encryptBytes(bytes);
  }

  Uint8List decryptAES(Uint8List bytes) {
    return dcipher!.decryptBytes(bytes);
  }
}
