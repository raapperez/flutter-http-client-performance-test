import 'package:dio/dio.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

import 'constants.dart';

final dio = Dio();

@pragma('vm:entry-point')
Future<String> dioGet(String url) async {
  final response = await dio.get(url);
  return response.data.toString();
}

Future<String> dioIsolateRequest() => flutterCompute(dioGet, url);
