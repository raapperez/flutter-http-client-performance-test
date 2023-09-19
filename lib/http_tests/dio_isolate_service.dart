import 'dart:isolate';

import 'package:async/async.dart';
import 'package:dio/dio.dart';

import '../settings.dart';


final port = ReceivePort();

Isolate? isolate;
SendPort? sendPort;
StreamQueue<dynamic>? streamQueue;

@pragma('vm:entry-point')
Future<String> dioService(SendPort sendPort) async {
  final dio = Dio();
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  await for (final url in receivePort) {
    final response = await dio.get(url);
    sendPort.send(response.data);
  }

  Isolate.exit();
}

Future<String> dioIsolateServiceRequest() async {
  if (isolate == null) {
    isolate = await Isolate.spawn(dioService, port.sendPort);
    streamQueue = StreamQueue<dynamic>(port);
    sendPort = await streamQueue!.next;
  }

  sendPort!.send(url);
  return await streamQueue!.next;
}
