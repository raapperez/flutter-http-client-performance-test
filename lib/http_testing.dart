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

Future<void> fullTest(
  String name, {
  int iterations = 1000,
  Duration waitDuration = const Duration(milliseconds: 500),
}) async {
  print('start $name');
  try {
    final httpClientTime =
        await repeat(httpClientRequest, iterations, waitDuration);
    print('httpClientTime');
    final dioTime = await repeat(dioRequest, iterations, waitDuration);
    print('dioTime');
    final httpTime = await repeat(httpRequest, iterations, waitDuration);
    print('httpTime');
    final nativeTime = await repeat(nativeRequest, iterations, waitDuration);
    print('nativeTime');
    final dioIsolateTime =
        await repeat(dioIsolateRequest, iterations, waitDuration);
    print('dioIsolateTime');
    final dioIsolateServiceTime =
        await repeat(dioIsolateServiceRequest, iterations, waitDuration);
    print('dioIsolateServiceTime');

    print('----- $name');
    print('httpClient;dio;http;native;dioIsolate;dioIsolateService');
    for (int i = 0; i < iterations; i++) {
      print(
          '${httpClientTime[i]};${dioTime[i]};${httpTime[i]};${nativeTime[i]};${dioIsolateTime[i]};${dioIsolateServiceTime[i]}');
      await Future.delayed(const Duration(milliseconds: 1));
    }
    print('-----');
  } catch (e) {
    print('error: $e');
  }
}

Future<void> idleTimeoutTest(
  String name, {
  int iterations = 20,
}) async {
  try {
    print('start');
    const waitDurations = [
      // Duration(milliseconds: 500),
      // Duration(milliseconds: 2900),
      // Duration(milliseconds: 3100),

      // Duration(milliseconds: 2400),
      // Duration(milliseconds: 2600),
      // Duration(milliseconds: 2800),
      // Duration(milliseconds: 3000),
      // Duration(milliseconds: 3200),
      // Duration(milliseconds: 3400),
      // Duration(milliseconds: 3600),

      Duration(milliseconds: 1400),
      Duration(milliseconds: 1600),
      Duration(milliseconds: 1800),
      Duration(milliseconds: 2000),
      Duration(milliseconds: 2200),
      Duration(milliseconds: 2400),
      Duration(milliseconds: 2600),
    ];

    final results = <List<int>>[];

    for (var waitDuration in waitDurations) {
      print('starting $waitDuration');
      results.add(await repeat(dioRequest, iterations, waitDuration));
    }

    print(waitDurations
        .map((waitDuration) => waitDuration.inMilliseconds)
        .join(';'));

    for (var i = 0; i < iterations; i++) {
      print(results.map((result) => result[i]).join(';'));
      await Future.delayed(const Duration(milliseconds: 1));
    }
    print('-----');
  } catch (e) {
    print('error: $e');
  }
}
