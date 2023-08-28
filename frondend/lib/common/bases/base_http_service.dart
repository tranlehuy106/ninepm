import 'dart:async' as async;
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nine_pm/common/api_response.dart';
import 'package:nine_pm/settings/environment_settings.dart';
import 'base_http_clients.dart';
import 'base_http_exception.dart';

abstract class BaseHttpService extends BaseHttpException {
  final NinePmHttpClient httpClient;

  BaseHttpService({required this.httpClient});

  Future<dynamic> get(apiPath, {Map<String, String>? headers}) async {
    final url = EnvironmentSettings.apiBaseUrl + apiPath;

    late http.Response response;

    try {
      response = await httpClient.get(
        Uri.parse(url),
        headers: headers,
      );
    } on SocketException {
      throw const InternetDisconnectedException();
    } on async.TimeoutException {
      throw TimeoutException();
    }

    if (response.statusCode != 200) {
      ///Hàm httpHandler bắt buộc phải throw
      httpHandler(response.statusCode);
    }

    ApiResponse apiResponse = ApiResponse.fromJson(
      HashMap<String, dynamic>.from(json.decode(response.body)),
    );

    if (!apiResponse.success) {
      if (apiResponse.responseCode == 'ERROR') {
        throw MessageException(message: apiResponse.messages);
      }
    }

    return apiResponse.data;
  }

  Future<dynamic> post(
    apiPath, {
    Map<String, String>? headers,
    body,
    Encoding? encoding,
  }) async {
    final url = EnvironmentSettings.apiBaseUrl + apiPath;

    late http.Response response;

    try {
      response = await httpClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
        encoding: encoding,
      );
    } on SocketException {
      throw const InternetDisconnectedException();
    } on async.TimeoutException {
      throw TimeoutException();
    }

    if (response.statusCode != 200) {
      ///Hàm httpHandler bắt buộc phải throw
      httpHandler(response.statusCode);
    }

    ApiResponse apiResponse = ApiResponse.fromJson(
      HashMap<String, dynamic>.from(json.decode(response.body)),
    );

    if (!apiResponse.success) {
      if (apiResponse.responseCode == 'ERROR') {
        throw MessageException(message: apiResponse.messages);
      }
    }

    return apiResponse.data;
  }
}
