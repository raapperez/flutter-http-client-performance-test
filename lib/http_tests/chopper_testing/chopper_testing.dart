import 'package:chopper/chopper.dart';
import 'package:dio_performance/http_tests/chopper_testing/chopper_service.dart';

import '../../settings.dart' as settings;

Future<String> chopperRequest() async {
  final chopper = ChopperClient(
    baseUrl: Uri.parse(settings.url),
    services: [LocalServerService.create()],
  );
  final service = chopper.getService<LocalServerService>();
  final response = await service.get();
  return response.body!;
}
