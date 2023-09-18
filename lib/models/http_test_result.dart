/// The class represents the result of a single http client test.
/// 
/// The result contains the name of the client and the time it took to complete each iteration of the test.
final class HttpTestResult {
  final String clientName;
  /// The time it took to complete the each iteration of the test.
  /// 
  /// The length of this list is the number of iterations.
  final List<int> iterations;

  const HttpTestResult(this.clientName, this.iterations);
}