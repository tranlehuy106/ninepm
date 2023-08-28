import 'package:nine_pm/utils/parse_json_data.dart';

class ApiResponse {
  final bool success;
  final String responseCode;
  final String messages;
  final dynamic errors;
  final dynamic data;

  ApiResponse({
    required this.success,
    required this.responseCode,
    required this.messages,
    this.errors,
    this.data,
  });

  static ApiResponse fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: parseBool(json, 'success'),
      responseCode: parseStr(json, 'response_code'),
      messages: parseStr(json, 'messages'),
      errors: parseDynamic(json, 'errors'),
      data: parseDynamic(json, 'data'),
    );
  }
}
