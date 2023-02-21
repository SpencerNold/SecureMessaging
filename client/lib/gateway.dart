import 'dart:isolate';

import 'package:client/eventbus.dart';

class Gateway {
  static Future<void> startSocketIsolate() async {
    MainEventBus? eventBus;
    ReceivePort receivePort = ReceivePort();
    Isolate.spawn(_startSocketIsolate, receivePort.sendPort);
    int index = 0;
    await for (final message in receivePort) {
      if (message is SendPort) {
        eventBus = MainEventBus(message);
        continue;
      }
      eventBus!.onMessage(index, message);
      index++;
    }
  }

  static Future<void> _startSocketIsolate(SendPort sendPort) async {
    SocketEventBus eventBus = SocketEventBus(sendPort);
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    int index = 0;
    await for (final message in receivePort) {
      eventBus.onMessage(index, message);
      index++;
    }
  }
}
