import 'http_test_result.dart';

/// The class represents the whole test process.
/// 
/// It receives the test name and a list of results for each client.
final class HttpTestGroup {
  final String testName;
  final List<HttpTestResult> testClients;

  const HttpTestGroup(this.testName, this.testClients);

  int get iterationsLength => testClients.first.iterations.length;
}