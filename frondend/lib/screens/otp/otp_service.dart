import 'package:nine_pm/common/bases/base_http_clients.dart';
import 'package:nine_pm/common/bases/base_http_service.dart';

class OtpService extends BaseHttpService {
  OtpService({
    required NinePmHttpClient httpClient,
  }) : super(httpClient: httpClient);

  Future<dynamic> validateLoginOtp(String token, String otp) async {
    const apiPath = '/validate-login-otp';
    final body = {
      'token': token,
      'otp': otp,
    };
    return await post(apiPath, body: body);
  }

  Future<dynamic> sendOtpAgain(String token) async {
    const apiPath = '/send-otp-again';
    final body = {
      'token': token,
    };
    return await post(apiPath, body: body);
  }
}
