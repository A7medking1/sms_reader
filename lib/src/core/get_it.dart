import 'package:get_it/get_it.dart';
import 'package:reading_sms/src/repository/sms_repository.dart';
import 'package:reading_sms/src/services/sms_platform_service.dart';

final sl = GetIt.instance;

void setupGetIt() {
  sl.registerLazySingleton<SmsPlatformService>(() => SmsPlatformService());
  sl.registerLazySingleton<SmsRepository>(() => SmsRepository(sl()));
}
