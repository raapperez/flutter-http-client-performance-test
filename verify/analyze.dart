import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'models/report.dart';

final interestEventNames = {
  'full_measure_start',
  'single_measure_start',
  'HTTP CLIENT GET',
  'Connection established',
  'Request sent',
  'Waiting (TTFB)',
  'HTTP CLIENT response of GET',
  'Content Download',
  'single_measure_end',
  'full_measure_end',
  'heavy_start',
  'heavy_end',
};

void main() {
  final input = File('./verify/data/heavy_native_data6.json').readAsStringSync();

  final json = jsonDecode(input);

  final report = Report.fromJson(json);

  final traceEvents = report.traceEvents;

  final httpEvents =
      traceEvents.where((e) => e.name.toLowerCase().contains('http'));

  final nonHttpEvents = traceEvents.where((e) =>
      !e.name.toLowerCase().contains('http') &&
      !e.name.startsWith('full_measure') &&
      !e.name.startsWith('single_measure'));

  final minTs = traceEvents
      .where((e) => e.name == 'full_measure_start')
      .map((e) => e.ts)
      .reduce(min);

  final maxTs = traceEvents
      .where((e) => e.name == 'full_measure_end')
      .map((e) => e.ts)
      .reduce(max);

  final tids = httpEvents.map((e) => e.tid).toSet();

  print(
      'minTs: $minTs, maxTs: $maxTs duration: ${Duration(microseconds: maxTs - minTs)}, tids: $tids');

  final nonHttpEventsInHttpPeriod = nonHttpEvents
      .where((e) => e.ts >= minTs && e.ts <= maxTs && tids.contains(e.tid));

  final names = nonHttpEventsInHttpPeriod.map((e) => e.name).toList();

  final map = <String, int>{};

  for (var name in names) {
    if (!map.containsKey(name)) {
      map[name] = 1;
    } else {
      map[name] = (map[name] as int) + 1;
    }
  }

  print(map);

  print('nonHttpEventsInHttpPeriod: ${nonHttpEventsInHttpPeriod.length}');

  print('-----');

  final interestEvents = traceEvents
      .where((e) => interestEventNames.contains(e.name))
      .toList();

  print('interestEvents: ${interestEvents.map((e) => e.name).toList()}');

  print(interestEvents.map((e) {
    if (e.ph == 'b' || e.ph == 'e') {
      return '${e.name} (${e.ph})';
    }
    return e.name;
  }).join('\n'));

  var last = 0;
  print(interestEvents.map((e) {
    if (last == 0) {
      last = e.ts;
      return 0;
    }
    final result = e.ts - last;
    last = e.ts;
    return result;
  }).join('\n'));
}
