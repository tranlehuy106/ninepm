import 'package:nine_pm/common/bases/base_http_clients.dart';
import 'package:nine_pm/common/bases/base_http_service.dart';

class SplashService extends BaseHttpService {
  SplashService({
    required NinePmHttpClient httpClient,
  }) : super(httpClient: httpClient);

  Future<void> loginStatus() async {
    const apiPath = '/login-status';
    await get(apiPath);
  }
}
