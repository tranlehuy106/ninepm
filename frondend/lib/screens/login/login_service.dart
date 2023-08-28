import 'package:nine_pm/common/bases/base_http_clients.dart';
import 'package:nine_pm/common/bases/base_http_service.dart';

class LoginService extends BaseHttpService {
  LoginService({
    required NinePmHttpClient httpClient,
  }) : super(httpClient: httpClient);

  Future<dynamic> login(String phoneNumber) async {
    const apiPath = '/login-request';
    final body = {
      'phone_number': phoneNumber,
    };
    return await post(apiPath, body: body);
  }
}
