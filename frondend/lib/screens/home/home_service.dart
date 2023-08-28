import 'package:nine_pm/common/bases/base_http_clients.dart';
import 'package:nine_pm/common/bases/base_http_service.dart';

class HomeService extends BaseHttpService {
  HomeService({
    required NinePmHttpClient httpClient,
  }) : super(httpClient: httpClient);

  Future<dynamic> getListCrush() async {
    const apiPath = '/get-list-crush';
    return await get(apiPath);
  }

  Future<dynamic> getListLover() async {
    const apiPath = '/get-list-lover';
    return await get(apiPath);
  }
}
