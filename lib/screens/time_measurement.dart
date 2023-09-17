import 'dart:math';

import 'package:flutter/material.dart';

Future<void> heavyOperation() async {
  await Future.delayed(const Duration(milliseconds: 2));

  final numbers = <int>[];
  final random = Random();
  for(int i = 0; i < 1000000; i++) {
    numbers.add(random.nextInt(10000000));
  }
  numbers.sort();
}

Future<void> lightOperation() async {
  await Future.delayed(const Duration(milliseconds: 1));
}

Future<void> doTest() async {
  final startHeavy = DateTime.now();
  final heavyFuture = heavyOperation();

  final startLight = DateTime.now();
  await lightOperation();
  final endLight = DateTime.now();

  await heavyFuture;
  final endHeavy = DateTime.now();

  debugPrint('lightTime: ${endLight.difference(startLight).inMilliseconds}');
  debugPrint('heavyTime: ${endHeavy.difference(startHeavy).inMilliseconds}');
}

class TimeMeasurement extends StatelessWidget {
  const TimeMeasurement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeMeasurement'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: doTest,
                child: Text('do test')),
          ],
        ),
      ),
    );
  }
}
