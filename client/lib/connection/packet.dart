import 'dart:typed_data';

import 'package:client/connection/connection.dart';

abstract class Packet {
  int getId();
  Uint8List write();
  void read(Uint8List data);
  void handle(Connection connection);
}
