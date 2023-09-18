import 'dart:async';

import 'package:flutter/material.dart';

import '../http_tests/http_testing.dart';
import '../models/http_test_group.dart';
import 'show_http_test_result_modal.dart';

class HttpTimePerformance extends StatefulWidget {
  const HttpTimePerformance({Key? key}) : super(key: key);

  @override
  State<HttpTimePerformance> createState() => _HttpTimePerformanceState();
}

class _HttpTimePerformanceState extends State<HttpTimePerformance> {
  int _counter = 0;
  Timer? _timer;

  bool _isTesting = false;

  /// Each item in the list represents a whole test process.
  ///
  /// Each test contains a list of results for each client.
  List<HttpTestGroup> _testGroups = [];

  /// Wraps the callback to prevent multiple tests running at the same time.
  ///
  /// If a test is already running, returns null and block the buttons.
  VoidCallback? _testCallbackWrapper(Future<List<HttpTestGroup>> Function() fn) {
    if (_isTesting) {
      return null;
    }

    return () async {
      setState(() {
        _isTesting = true;
      });
      _testGroups = await fn.call();
      setState(() {
        _isTesting = false;
      });
    };
  }

  void startHeavyJob() {
    stopHeavyJob();
    _counter = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
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
  void dispose() {
    stopHeavyJob();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HTTP time performance')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _testCallbackWrapper(() async => [HttpTestGroup('light', await fullTest('light'))]),
                child: const Text('run light test'),
              ),
              ElevatedButton(
                onPressed: _testCallbackWrapper(
                  () async {
                    startHeavyJob();
                    final res = await fullTest('heavy');
                    stopHeavyJob();
                    return [HttpTestGroup('heavy', res)];
                  },
                ),
                child: const Text('run heavy test'),
              ),
              ElevatedButton(
                onPressed: _testCallbackWrapper(
                  () async {
                    final lightTest = await fullTest('light');
                    startHeavyJob();
                    final heavyTest = await fullTest('heavy');
                    stopHeavyJob();
                    return [HttpTestGroup('lightTest', lightTest), HttpTestGroup('heavyTest', heavyTest)];
                  },
                ),
                child: const Text('run both'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_testGroups.isEmpty) {
            const snack = SnackBar(content: Text('No results to show at this moment. Try run one of the tests.'));
            ScaffoldMessenger.of(context).showSnackBar(snack);
            return;
          }
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            showDragHandle: true,
            useSafeArea: true,
            builder: (_) => ShowHttpTestResultModal(testGroups: _testGroups),
          );
        },
        label: const Text('View latest results'),
      ),
    );
  }
}
