import 'connected_app.dart';
import 'performance.dart';
import 'trace_event.dart';

class Report {
  Report._(
    this.devToolsSnapshot,
    this.activeScreenId,
    this.devtoolsVersion,
    this.flutterVersion,
    this.connectedApp,
    this.traceEvents,
    this.performance,
  );

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report._(
      json['devToolsSnapshot'] as bool,
      json['activeScreenId'],
      json['devtoolsVersion'],
      json['flutterVersion'],
      ConnectedApp.fromJson(json['connectedApp']),
      (json['traceEvents'] as List<dynamic>)
          .map<TraceEvent>((json) => TraceEvent.fromJson(json))
          .toList(),
      Performance.fromJson(json['performance']),
    );
  }

  final bool devToolsSnapshot;
  final String activeScreenId;
  final String devtoolsVersion;
  final String flutterVersion;
  final ConnectedApp connectedApp;
  final List<TraceEvent> traceEvents;
  final Performance performance;

  @override
  String toString() {
    return 'Report{devToolsSnapshot: $devToolsSnapshot, activeScreenId: $activeScreenId, devtoolsVersion: $devtoolsVersion, flutterVersion: $flutterVersion, connectedApp: $connectedApp, traceEvents: $traceEvents, performance: $performance}';
  }
}
