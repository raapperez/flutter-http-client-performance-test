import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../settings.dart' as settings;
import '../models/http_test_result.dart';
import 'chopper_testing/chopper_testing.dart';
import 'dio_isolate.dart';
import 'dio_isolate_service.dart';

final dio = Dio();
final client = HttpClient();
final httpClient = http.Client();

const platform = MethodChannel('com.dio_performance/get');

typedef AsyncFunc = Future<String?> Function();

Future<void> measure(Stopwatch stopwatch, AsyncFunc asyncFunc) async {
  stopwatch.reset();
  stopwatch.start();
  await asyncFunc();
  stopwatch.stop();
}

Future<List<int>> repeat(AsyncFunc asyncFunc) async {
  final microseconds = <int>[];
  final stopwatch = Stopwatch();
  for (int i = 0; i < settings.iterations; i++) {
    await Future.delayed(settings.waitDuration);
    await measure(stopwatch, asyncFunc);
    microseconds.add(stopwatch.elapsedMicroseconds);
  }

  return microseconds;
}

Future<String?> dioRequest() async {
  final response = await dio.get<String>(settings.url);
  return response.data;
}

Future<String> httpClientRequest() async {
  final request = await client.getUrl(Uri.parse(settings.url));
  final response = await request.close();
  return await response.transform(utf8.decoder).join();
}

Future<String> httpRequest() async {
  final response = await httpClient.get(Uri.parse(settings.url));
  return response.body;
}

Future<String?> nativeRequest() => platform.invokeMethod<String>('get', {'url': settings.url, 'headers': {}});

Future<List<HttpTestResult>> fullTest(String name) async {
  debugPrint('start $name');
  try {
    final results = <HttpTestResult>[];

    results.add(HttpTestResult('httpClientTime', await repeat(httpClientRequest)));
    debugPrint('httpClientTime');

    results.add(HttpTestResult('dioTime', await repeat(dioRequest)));
    debugPrint('dioTime');

    results.add(HttpTestResult('httpTime', await repeat(httpRequest)));
    debugPrint('httpTime');

    results.add(HttpTestResult('nativeTime', await repeat(nativeRequest)));
    debugPrint('nativeTime');

    results.add(HttpTestResult('dioIsolateTime', await repeat(dioIsolateRequest)));
    debugPrint('dioIsolateTime');

    results.add(HttpTestResult('dioIsolateServiceTime', await repeat(dioIsolateServiceRequest)));
    debugPrint('dioIsolateServiceTime');

    results.add(HttpTestResult('Chopper', await repeat(chopperRequest)));
    debugPrint('dioIsolateServiceTime');

    debugPrint('----- $name');
    debugPrint('httpClient;dio;http;native;dioIsolate;dioIsolateService;chopper');

    for (int i = 0; i < settings.iterations; i++) {
      final buffer = StringBuffer();
      for (final result in results) {
        buffer.write('${result.iterations[i]};');
      }
      debugPrint(buffer.toString());
    }
    return results;
  } catch (e) {
    debugPrint('error: $e');
  }
  return [];
}
