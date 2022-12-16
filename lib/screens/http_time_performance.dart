import 'dart:async';

import 'package:flutter/material.dart';

import '../http_testing.dart';

class _HttpTimePerformanceState extends State<HttpTimePerformance> {
  int _counter = 0;
  Timer? _timer;

  void startHeavyJob() {
    stopHeavyJob();
    _counter = 0;
    _timer = Timer.periodic(
        const Duration(milliseconds: 200), (timer) {
      setState(() {
        _counter++;
      });
    });
  }

  void stopHeavyJob() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP time performance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
                onPressed: () {
                  fullTest('light');
                },
                child: const Text('run light test')),
            ElevatedButton(
                onPressed: () async {
                  startHeavyJob();
                  await fullTest('heavy');
                  stopHeavyJob();
                },
                child: const Text('run heavy test')),
            ElevatedButton(
                onPressed: () async {
                  await fullTest('light');

                  startHeavyJob();
                  await fullTest('heavy');
                  stopHeavyJob();
                },
                child: const Text('run both')),
            ElevatedButton(
                onPressed: () async {
                  await idleTimeoutTest('idleTimeoutTest');
                },
                child: const Text('idleTimeoutTest')),

          ],
        ),
      ),
    );
  }
}

class HttpTimePerformance extends StatefulWidget {
  const HttpTimePerformance({Key? key}) : super(key: key);

  @override
  State<HttpTimePerformance> createState() => _HttpTimePerformanceState();
}
