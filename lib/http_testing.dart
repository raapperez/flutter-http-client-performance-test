import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'dio_isolate.dart';
import 'dio_isolate_service.dart';

typedef AsyncFunc = Future<void> Function();

final dio = Dio();
final client = HttpClient();
final httpClient = http.Client();

const url = 'http://192.0.0.2:8080/';
final uri = Uri.parse(url);
const platform = MethodChannel('com.dio_performance/get');

Future<void> measure(Stopwatch stopwatch, AsyncFunc asyncFunc) async {
  stopwatch.reset();
  stopwatch.start();
  await asyncFunc();
  stopwatch.stop();
}

Future<List<int>> repeat(
  AsyncFunc asyncFunc,
  int iterations,
  Duration waitDuration,
) async {
  final microseconds = <int>[];
  final stopwatch = Stopwatch();
  for (int i = 0; i < iterations; i++) {
    await Future.delayed(waitDuration);
    await measure(stopwatch, asyncFunc);
    microseconds.add(stopwatch.elapsedMicroseconds);
  }

  return microseconds;
}

Future<void> dioRequest() => dio.get(url);

Future<void> httpClientRequest() async {
  final request = await client.getUrl(uri);
  await request.close();
}

Future<void> httpRequest() => httpClient.get(uri);

Future<void> nativeRequest() =>
    platform.invokeMethod('get', {'url': url, 'headers': {}});

Future<String?> nativeConstantString() =>
    platform.invokeMethod<String>('constantString');

Future<void> fullTest(
  String name, {
  int iterations = 100,
  Duration waitDuration = const Duration(milliseconds: 500),
}) async {
  print('start $name');
  try {
    // final httpClientTime =
    //     await repeat(httpClientRequest, iterations, waitDuration);
    // print('httpClientTime');
    final dioTime = await repeat(dioRequest, iterations, waitDuration);
    print('dioTime');
    // final httpTime = await repeat(httpRequest, iterations, waitDuration);
    // print('httpTime');
    // final nativeTime = await repeat(nativeRequest, iterations, waitDuration);
    // print('nativeTime');
    // final dioIsolateTime =
    //     await repeat(dioIsolateRequest, iterations, waitDuration);
    // print('dioIsolateTime');
    // final dioIsolateServiceTime =
    //     await repeat(dioIsolateServiceRequest, iterations, waitDuration);
    // print('dioIsolateServiceTime');

    print('----- $name');
    print('httpClient;dio;http;native;dioIsolate;dioIsolateService');
    for (int i = 0; i < iterations; i++) {
      // print(
      //     '${httpClientTime[i]};${dioTime[i]};${httpTime[i]};${nativeTime[i]};${dioIsolateTime[i]};${dioIsolateServiceTime[i]}');

      print('${dioTime[i]}');
      await Future.delayed(const Duration(milliseconds: 1));
    }
    print('-----');
  } catch (e) {
    print('error: $e');
  }
}

Future<void> nativeConstantStringTest(
  String name, {
  int iterations = 1000,
  Duration waitDuration = const Duration(milliseconds: 500),
}) async {
  print('start $name');
  try {
    final nativeConstantStringTime =
        await repeat(nativeConstantString, iterations, waitDuration);

    print('----- $name');
    print('nativeConstantString');
    for (var i = 0; i < iterations; i++) {
      print('${nativeConstantStringTime[i]}');
      await Future.delayed(const Duration(milliseconds: 1));
    }
    print('-----');
  } catch (e) {
    print('error: $e');
  }
}
