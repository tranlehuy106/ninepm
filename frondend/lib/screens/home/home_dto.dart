import 'package:intl/intl.dart';
import 'package:nine_pm/utils/parse_json_data.dart';

class HomeCrushItem {
  HomeCrushItem({
    required this.phoneNumberOfCrush,
    required this.startAt,
  });

  String phoneNumberOfCrush;
  String startAt;

  static HomeCrushItem fromJson(dynamic item) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    String phoneNumberOfCrush = parseStr(item, 'phone_number_of_crush');
    if (phoneNumberOfCrush.length > 3) {
      phoneNumberOfCrush =
          phoneNumberOfCrush.substring(phoneNumberOfCrush.length - 3);
    }

    String formattedDate = '';

    DateTime? startAt = parseDateTime(item, 'start_at');
    if (startAt != null) {
      DateTime startDate = DateTime(startAt.year, startAt.month, startAt.day);
      Duration difference = today.difference(startDate);
      switch (difference.inDays) {
        case 0:
          formattedDate = 'Hôm nay';
          break;
        case 1:
          formattedDate = '1d';
          break;
        case 2:
          formattedDate = '2d';
          break;
        default:
          formattedDate = DateFormat('dd/MM/yyyy').format(startDate);
          break;
      }
    }

    return HomeCrushItem(
      phoneNumberOfCrush: phoneNumberOfCrush,
      startAt: formattedDate,
    );
  }
}

class HomeLoverItem {
  HomeLoverItem({
    required this.crushUserId,
    required this.phoneNumberOfCrush,
  });

  int crushUserId;
  String phoneNumberOfCrush;

  static HomeLoverItem fromJson(dynamic item) {
    return HomeLoverItem(
      crushUserId: parseInt(item, 'crush_user_id'),
      phoneNumberOfCrush: parseStr(item, 'phone_number_of_crush'),
    );
  }
}

class ChatLoverItem {
  ChatLoverItem({
    required this.crushUserId,
    required this.phoneNumberOfCrush,
    required this.message,
    required this.status,
    required this.startAt,
  });

  int crushUserId;
  String phoneNumberOfCrush;
  String message;
  String status;
  String startAt;

  static ChatLoverItem fromJson(dynamic item) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    String phoneNumberOfCrush = parseStr(item, 'phone_number_of_crush');
    if (phoneNumberOfCrush.length > 3) {
      phoneNumberOfCrush =
          phoneNumberOfCrush.substring(phoneNumberOfCrush.length - 3);
    }

    DateTime startAt = parseDateTime(item, 'start_at')!;
    DateTime startDate = DateTime(startAt.year, startAt.month, startAt.day);
    Duration difference = today.difference(startDate);
    String formattedDate = '';
    switch (difference.inDays) {
      case 0:
        formattedDate = DateFormat('HH:mm').format(startAt);
        break;
      case 1:
        formattedDate = '1d';
        break;
      case 2:
        formattedDate = '2d';
        break;
      default:
        formattedDate = DateFormat('dd/MM/yyyy').format(startDate);
        break;
    }

    String message = parseStr(item, 'message');
    if (message.isEmpty) {
      message = 'Trò chuyện ngay nào.';
    }

    return ChatLoverItem(
      crushUserId: parseInt(item, 'crush_user_id'),
      phoneNumberOfCrush: phoneNumberOfCrush,
      message: message,
      status: parseStr(item, 'status'),
      startAt: formattedDate,
    );
  }
}
