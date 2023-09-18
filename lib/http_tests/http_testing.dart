import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_performance/models/http_test_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
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

Future<List<HttpTestResult>> fullTest(
  String name, {
  int iterations = 100,
  Duration waitDuration = const Duration(milliseconds: 50),
}) async {
  debugPrint('start $name');
  try {
    final results = <HttpTestResult>[];

    results.add(HttpTestResult('httpClientTime', await repeat(httpClientRequest, iterations, waitDuration)));
    debugPrint('httpClientTime');
    
    results.add(HttpTestResult('dioTime', await repeat(dioRequest, iterations, waitDuration)));
    debugPrint('dioTime');
    
    results.add(HttpTestResult('httpTime', await repeat(httpRequest, iterations, waitDuration)));
    debugPrint('httpTime');
    
    results.add(HttpTestResult('nativeTime', await repeat(nativeRequest, iterations, waitDuration)));
    debugPrint('nativeTime');
    
    results.add(HttpTestResult('dioIsolateTime', await repeat(dioIsolateRequest, iterations, waitDuration)));
    debugPrint('dioIsolateTime');
    
    results.add(HttpTestResult('dioIsolateServiceTime', await repeat(dioIsolateServiceRequest, iterations, waitDuration)));
    debugPrint('dioIsolateServiceTime');

    debugPrint('----- $name');
    debugPrint('httpClient;dio;http;native;dioIsolate;dioIsolateService');

    for (int i = 0; i < iterations; i++) {
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
