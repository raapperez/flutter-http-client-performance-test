class TraceEvent {
  TraceEvent._(
    this.name,
    this.cat,
    this.tid,
    this.pid,
    this.ts,
    this.tts,
    this.ph,
    this.id,
    this.args,
  );

  factory TraceEvent.fromJson(Map<String, dynamic> json) {
    return TraceEvent._(
      json['name'] as String,
      json['cat'] as String,
      json['tid'] as int,
      json['pid'] as int,
      json['ts'] as int,
      json['tts'] as int?,
      json['ph'] as String,
      json['id'] as String?,
      json['args'] as Map<String, dynamic>,
    );
  }

  final String name;
  final String cat;
  final int tid;
  final int pid;
  final int ts;
  final int? tts;
  final String ph;
  final String? id;
  final Map<String, dynamic> args;

  @override
  String toString() {
    return 'TraceEvent{name: $name, cat: $cat, tid: $tid, pid: $pid, ts: $ts, ph: $ph, id: $id, args: $args}';
  }
}
