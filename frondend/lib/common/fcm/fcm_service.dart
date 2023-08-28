import 'package:nine_pm/common/bases/base_http_clients.dart';
import 'package:nine_pm/common/bases/base_http_service.dart';

class FcmService extends BaseHttpService {
  FcmService({
    required NinePmHttpClient httpClient,
  }) : super(httpClient: httpClient);

  Future<dynamic> registerFcmToken(String token) async {
    const apiPath = '/register-fcm-token';
    final body = {
      'fcm_token': token,
    };
    return await post(apiPath, body: body);
  }
}
