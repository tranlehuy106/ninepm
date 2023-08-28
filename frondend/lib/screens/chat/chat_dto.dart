import 'package:intl/intl.dart';
import 'package:nine_pm/utils/parse_json_data.dart';

enum TypeMessage {
  myMessage,
  yourMessage,
}

class ChatItem {
  ChatItem({
    required this.id,
    required this.type,
    required this.status,
    required this.message,
    required this.startDate,
    required this.startTime,
  });

  TypeMessage type;
  int id;
  String status;
  String message;
  String startDate;
  String startTime;

  static ChatItem fromJson(dynamic item, int receiverId) {
    TypeMessage type = TypeMessage.myMessage;
    if (receiverId != parseInt(item, 'user_of_crush_id')) {
      type = TypeMessage.yourMessage;
    }

    DateTime? startAt = parseDateTime(item, 'start_at');
    String startDate = '';
    String startTime = '';
    if (startAt != null) {
      startDate = DateFormat('dd/MM/yyyy').format(startAt);
      startTime = DateFormat('hh:mm').format(startAt);
    }
    return ChatItem(
      id: parseInt(item, 'id'),
      type: type,
      status: parseStr(item, 'status'),
      message: parseStr(item, 'message'),
      startDate: startDate,
      startTime: startTime,
    );
  }

  static ChatItem fromJsonOfFcm(dynamic item, int receiverId) {
    DateTime? startAt = parseDateTime(item, 'start_at');
    String startDate = '';
    String startTime = '';
    if (startAt != null) {
      startDate = DateFormat('dd/MM/yyyy').format(startAt);
      startTime = DateFormat('hh:mm').format(startAt);
    }
    return ChatItem(
      id: int.parse(parseStr(item, 'id')),
      type: TypeMessage.yourMessage,
      status: parseStr(item, 'status'),
      message: parseStr(item, 'message'),
      startDate: startDate,
      startTime: startTime,
    );
  }
}
