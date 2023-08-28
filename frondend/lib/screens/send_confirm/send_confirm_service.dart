import 'package:nine_pm/common/bases/base_http_clients.dart';
import 'package:nine_pm/common/bases/base_http_service.dart';

class SendConfirmService extends BaseHttpService {
  SendConfirmService({
    required NinePmHttpClient httpClient,
  }) : super(httpClient: httpClient);

  Future<dynamic> sendLoveMessages(
    String phoneNumberOfCrush,
    String reminiscentName,
  ) async {
    const apiPath = '/send-love-messages';
    final body = {
      'phone_number_of_crush': phoneNumberOfCrush,
      'reminiscent_name': reminiscentName,
    };
    return await post(apiPath, body: body);
  }
}
