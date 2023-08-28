//#region http exception

class BadRequestException implements Exception {}

class UnauthorizedException implements Exception {}

class ForbiddenErrorException implements Exception {}

class PageNotFoundException implements Exception {}

class MethodNotAllowedException implements Exception {}

class ServerErrorException implements Exception {}

class ServiceUnavailableException implements Exception {}

class InternetDisconnectedException implements Exception {
  ///params dùng để lưu lại thông số của từng hàm. Gọi lại params khi nhấn nút thử lại
  final List? params;

  const InternetDisconnectedException({
    this.params,
  });
}

class TimeoutException implements Exception {}

class NotImplementedException implements Exception {}

class UnknownException implements Exception {}

class MessageException implements Exception {
  final String message;

  const MessageException({
    required this.message,
  });
}

// #endregion

class BaseHttpException {
  ///Hàm httpHandler bắt buộc phải throw
  void httpHandler(int statusCode) {
    switch (statusCode) {
      case 400:
        return http400Exception();
      case 401:
        return http401Exception();
      case 403:
        return http403Exception();
      case 404:
        return http404Exception();
      case 405:
        return http405Exception();
      case 500:
        return http500Exception();
      case 503:
        return http503Exception();
      case 504:
        return http504Exception();
      default:
        return httpNotImplementedException();
    }
  }

  void http400Exception() {
    throw BadRequestException();
  }

  void http401Exception() {
    throw UnauthorizedException();
  }

  void http403Exception() {
    throw ForbiddenErrorException();
  }

  void http404Exception() {
    throw PageNotFoundException();
  }

  void http405Exception() {
    throw MethodNotAllowedException();
  }

  void http500Exception() {
    throw ServerErrorException();
  }

  void http503Exception() {
    throw ServiceUnavailableException();
  }

  void http504Exception() {
    throw TimeoutException();
  }

  void httpNotImplementedException() {
    throw NotImplementedException();
  }
}
