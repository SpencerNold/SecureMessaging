import 'dart:io';

import 'package:client/crypto/rsa.dart';
import 'package:client/utils/bytebuffer.dart';

class ClientStorage {
  final String dir;

  late final File file;
  late final RandomAccessFile database;
  bool initialized = false;

  ClientStorage(this.dir);

  void _lateInit() {
    if (initialized) return;
    initialized = true;
    file = File("$dir/client_storage.dbh");
    final db = File("$dir/client_storage.dbd");
    {
      if (file.existsSync()) {
        file.deleteSync();
      }
      if (db.existsSync()) {
        db.deleteSync();
      }
    }
    if (!db.existsSync()) {
      db.createSync();
    }
    database = db.openSync(mode: FileMode.append);
  }

  Header? load() {
    _lateInit();
    if (!file.existsSync()) {
      return null;
    }
    ByteBuf buf = ByteBuf.read(file.readAsBytesSync());
    String username = buf.readString();
    String password = buf.readString();
    KeyPair keyPair = KeyPair.deserialize(buf.readBytes(2053));
    return Header(username, password, keyPair);
  }

  void save(Header header) {
    if (file.existsSync()) {
      file.createSync();
    }
    ByteBuf buf = ByteBuf.write();
    buf.writeString(header.username);
    buf.writeString(header.password);
    buf.writeBytes(header.keyPair.serialize());
    file.writeAsBytesSync(buf.toByteArray());
  }
}

class Header {
  final String username;
  final String password;
  final KeyPair keyPair;

  Header(this.username, this.password, this.keyPair);
}
