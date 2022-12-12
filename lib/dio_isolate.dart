import 'package:dio/dio.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

final dio = Dio();
const url = 'http://192.0.0.2:8080/';

@pragma('vm:entry-point')
Future<String> dioGet(String url) async {
  final response = await dio.get(url);
  return response.data.toString();
}

Future<String> dioIsolateRequest() => flutterCompute(dioGet, url);
