class ConnectedApp {
  ConnectedApp(
    this.isFlutterApp,
    this.isProfileBuild,
    this.isDartWebApp,
    this.isRunningOnDartVM,
  );

  factory ConnectedApp.fromJson(Map<String, dynamic> json) {
    return ConnectedApp(
      json['isFlutterApp'] as bool,
      json['isProfileBuild'] as bool,
      json['isDartWebApp'] as bool,
      json['isRunningOnDartVM'] as bool,
    );
  }

  final bool isFlutterApp;
  final bool isProfileBuild;
  final bool isDartWebApp;
  final bool isRunningOnDartVM;

  @override
  String toString() {
    return 'ConnectedApp{isFlutterApp: $isFlutterApp, isProfileBuild: $isProfileBuild, isDartWebApp: $isDartWebApp, isRunningOnDartVM: $isRunningOnDartVM}';
  }
}
