import 'package:nine_pm/common/bases/base_http_clients.dart';
import 'package:nine_pm/common/bases/base_http_service.dart';

class ChatService extends BaseHttpService {
  ChatService({
    required NinePmHttpClient httpClient,
  }) : super(httpClient: httpClient);

  Future<dynamic> getFetchDataChat(int receiverId) async {
    const apiPath = '/get-fetch-data-chat';
    final body = {
      'receiver_id': receiverId.toString(),
    };
    return await post(apiPath, body: body);
  }

  Future<dynamic> sendMessage(int receiverId, String message) async {
    const apiPath = '/send-message';
    final body = {
      'receiver_id': receiverId.toString(),
      'message': message,
    };
    return await post(apiPath, body: body);
  }

  Future<dynamic> seenMessage(String chatMessagesId) async {
    const apiPath = '/seen-message';
    final body = {
      'chat_messages_id': chatMessagesId,
    };
    return await post(apiPath, body: body);
  }
}
