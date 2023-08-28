import 'package:nine_pm/utils/parse_json_data.dart';
import 'package:rxdart/rxdart.dart';

import 'chat_dto.dart';
import 'chat_service.dart';

class ChatBloc {
  ChatBloc({required this.service});

  final ChatService service;

  final getFetchDataChatSubject = PublishSubject<List<ChatItem>>();
  final sendMessageSubject = PublishSubject<dynamic>();

  bool _waitingGetFetchDataChatResponse = false;
  bool _waitingSendMessageResponse = false;

  void dispose() {
    getFetchDataChatSubject.close();
    sendMessageSubject.close();
  }

  Future<void> getFetchDataChat(int receiverId) async {
    if (_waitingGetFetchDataChatResponse) {
      return;
    }
    _waitingGetFetchDataChatResponse = true;
    try {
      final response = await service.getFetchDataChat(receiverId);
      _waitingGetFetchDataChatResponse = false;

      var items = parseList(response, 'items');
      List<ChatItem> chatItems = [];
      for (final item in items) {
        chatItems.add(ChatItem.fromJson(item, receiverId));
      }
      if (getFetchDataChatSubject.isClosed) {
        return;
      }
      getFetchDataChatSubject.add(chatItems);
    } on Exception catch (exception) {
      _waitingGetFetchDataChatResponse = false;
      if (getFetchDataChatSubject.isClosed) {
        return;
      }
      getFetchDataChatSubject.addError(exception);
      return;
    }
  }

  Future<void> sendMessage(int receiverId, String message) async {
    if (_waitingSendMessageResponse) {
      return;
    }
    _waitingSendMessageResponse = true;
    try {
      final response = await service.sendMessage(receiverId, message);
      _waitingSendMessageResponse = false;
      if (sendMessageSubject.isClosed) {
        return;
      }
      sendMessageSubject.add(response);
    } on Exception catch (exception) {
      _waitingSendMessageResponse = false;
      if (sendMessageSubject.isClosed) {
        return;
      }
      sendMessageSubject.addError(exception);
      return;
    }
  }

  void seenMessage(String chatMessagesId) async {
    if (chatMessagesId.isEmpty) {
      return;
    }
    try {
      service.seenMessage(chatMessagesId);
    } on Exception catch (exception) {
      return;
    }
  }
}
