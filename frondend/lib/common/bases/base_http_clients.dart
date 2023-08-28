import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nine_pm/settings/environment_settings.dart';

class NinePmHttpClient extends http.BaseClient {
  final String _authTokenName = EnvironmentSettings.authTokenHeader;
  final String _clientVersionName = EnvironmentSettings.clientVersionHeader;
  final String _deviceTokenHeaderName =
      EnvironmentSettings.deviceTokenHeaderName;
  String? _authTokenValue;
  String? _clientVersionValue;
  String? _deviceTokenValue;
  final http.Client _httpClient = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    /// HEADERS
    /// Add Content-Type if not exists
    request.headers.putIfAbsent(
        HttpHeaders.contentTypeHeader, () => ContentType.json.toString());

    /// Add authorization_token if exists
    if (_authTokenName.isEmpty) return _httpClient.send(request);

    request.headers.remove(_authTokenName);
    if (_authTokenValue != null && _authTokenValue!.isNotEmpty) {
      request.headers[_authTokenName] = _authTokenValue!;
    }

    /// Add authorization_version if exists
    if (_clientVersionName.isEmpty) return _httpClient.send(request);

    request.headers.remove(_clientVersionName);
    if (_clientVersionValue != null && _clientVersionValue!.isNotEmpty) {
      request.headers[_clientVersionName] = _clientVersionValue!;
    }

    if (_deviceTokenValue != null && _deviceTokenValue!.isNotEmpty) {
      request.headers[_deviceTokenHeaderName] = _deviceTokenValue!;
    }

    return _httpClient.send(request);
  }

  set authTokenValue(String? token) {
    _authTokenValue = token;
  }

  String? get getAuthTokenValue => _authTokenValue;

  String get getAuthTokenName => _authTokenName;

  String? get getClientVersionValue => _clientVersionValue;

  set clientVersionValue(String version) {
    _clientVersionValue = version;
  }

  String get getClientVersionName => _clientVersionName;

  set deviceTokenValue(String? token) {
    _deviceTokenValue = token;
  }

  String? get getDeviceTokenValue => _deviceTokenValue;
}
