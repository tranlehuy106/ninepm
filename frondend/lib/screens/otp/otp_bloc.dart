import 'package:rxdart/rxdart.dart';

import 'otp_service.dart';

class OtpBloc {
  OtpBloc({required this.service});

  final OtpService service;

  final validateLoginOtpSubject = PublishSubject<dynamic>();
  final sendOtpAgainSubject = PublishSubject<dynamic>();

  bool _waitingValidateLoginOtpResponse = false;
  bool _waitingSendOtpAgainResponse = false;

  void dispose() {
    validateLoginOtpSubject.close();
    sendOtpAgainSubject.close();
  }

  Future<void> validateLoginOtp(String token, String otp) async {
    if (_waitingValidateLoginOtpResponse) {
      return;
    }
    _waitingValidateLoginOtpResponse = true;
    try {
      final response = await service.validateLoginOtp(token, otp);
      _waitingValidateLoginOtpResponse = false;
      if (validateLoginOtpSubject.isClosed) {
        return;
      }
      validateLoginOtpSubject.add(response);
    } on Exception catch (exception) {
      _waitingValidateLoginOtpResponse = false;
      if (validateLoginOtpSubject.isClosed) {
        return;
      }
      validateLoginOtpSubject.addError(exception);
      return;
    }
  }

  Future<void> sendOtpAgain(String token) async {
    if (_waitingSendOtpAgainResponse) {
      return;
    }
    _waitingSendOtpAgainResponse = true;
    try {
      final response = await service.sendOtpAgain(token);
      _waitingSendOtpAgainResponse = false;
      if (sendOtpAgainSubject.isClosed) {
        return;
      }
      sendOtpAgainSubject.add(response);
    } on Exception catch (exception) {
      _waitingSendOtpAgainResponse = false;
      if (sendOtpAgainSubject.isClosed) {
        return;
      }
      sendOtpAgainSubject.addError(exception);
      return;
    }
  }
}
