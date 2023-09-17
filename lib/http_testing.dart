import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'dio_isolate.dart';
import 'dio_isolate_service.dart';

typedef AsyncFunc = Future<String?> Function();

final dio = Dio();
final client = HttpClient();
final httpClient = http.Client();

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

Future<String?> dioRequest() async {
  final response = await dio.get<String>(url);
  return response.data;
}

Future<String> httpClientRequest() async {
  final request = await client.getUrl(uri);
  final response = await request.close();
  return await response.transform(utf8.decoder).join();
}

Future<String> httpRequest() async {
  final response = await httpClient.get(uri);
  return response.body;
}

Future<String?> nativeRequest() =>
    platform.invokeMethod<String>('get', {'url': url, 'headers': {}});

Future<void> fullTest(
  String name, {
  int iterations = 1,
  Duration waitDuration = const Duration(milliseconds: 100),
}) async {
  debugPrint('start $name');
  try {
    final httpClientTime =
        await repeat(httpClientRequest, iterations, waitDuration);
    debugPrint('httpClientTime');
    final dioTime = await repeat(dioRequest, iterations, waitDuration);
    debugPrint('dioTime');
    final httpTime = await repeat(httpRequest, iterations, waitDuration);
    debugPrint('httpTime');
    final nativeTime = await repeat(nativeRequest, iterations, waitDuration);
    debugPrint('nativeTime');
    final dioIsolateTime =
        await repeat(dioIsolateRequest, iterations, waitDuration);
    debugPrint('dioIsolateTime');
    final dioIsolateServiceTime =
        await repeat(dioIsolateServiceRequest, iterations, waitDuration);
    debugPrint('dioIsolateServiceTime');

    debugPrint('----- $name');
    debugPrint('httpClient;dio;http;native;dioIsolate;dioIsolateService');
    for (int i = 0; i < iterations; i++) {
      debugPrint(
          '${httpClientTime[i]};${dioTime[i]};${httpTime[i]};${nativeTime[i]};${dioIsolateTime[i]};${dioIsolateServiceTime[i]}');
      await Future.delayed(const Duration(milliseconds: 1));
    }
    debugPrint('-----');
  } catch (e) {
    debugPrint('error: $e');
  }
}
