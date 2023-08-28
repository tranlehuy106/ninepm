import 'package:rxdart/rxdart.dart';

import 'login_service.dart';

class LoginBloc {
  LoginBloc({required this.service});

  final LoginService service;

  final loginSubject = PublishSubject<dynamic>();

  bool _waitingResponse = false;

  void dispose() {
    loginSubject.close();
  }

  Future<void> login(String phoneNumber) async {
    if (_waitingResponse) {
      return;
    }
    _waitingResponse = true;
    try {
      final response = await service.login(phoneNumber);
      _waitingResponse = false;
      if (loginSubject.isClosed) {
        return;
      }
      loginSubject.add(response);
    } on Exception catch (exception) {
      _waitingResponse = false;
      if (loginSubject.isClosed) {
        return;
      }
      loginSubject.addError(exception);
      return;
    }
  }
}
