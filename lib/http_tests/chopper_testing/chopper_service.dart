import 'package:chopper/chopper.dart';

part 'chopper_service.chopper.dart';


@ChopperApi()
abstract class LocalServerService extends ChopperService {

  // A helper method that helps instantiating the service. You can omit this method and use the generated class directly instead.
  static LocalServerService create([ChopperClient? client]) => 
      _$LocalServerService(client);

  @Get()
  Future<Response<String>> get();
}