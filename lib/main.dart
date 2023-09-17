import 'package:dio_performance/screens/http_time_performance.dart';
import 'package:flutter/material.dart';

void main() async {
  debugPrint('main');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time performance',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: const TimeMeasurement(),
      home: const HttpTimePerformance(),
    );
  }
}
