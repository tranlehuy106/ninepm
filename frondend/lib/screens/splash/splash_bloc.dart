import 'package:rxdart/rxdart.dart';

import 'splash_service.dart';

class SplashBloc {
  SplashBloc({required this.service});

  final SplashService service;

  final loginStatusSubject = PublishSubject<void>();

  bool _waitingResponse = false;

  void dispose() {
    loginStatusSubject.close();
  }

  Future<void> loginStatus() async {
    if (_waitingResponse) {
      return;
    }

    _waitingResponse = true;

    try {
      await service.loginStatus();
      _waitingResponse = false;
      if (loginStatusSubject.isClosed) {
        return;
      }
      loginStatusSubject.add(null);
    } on Exception catch (exception) {
      _waitingResponse = false;
      if (loginStatusSubject.isClosed) {
        return;
      }
      loginStatusSubject.addError(exception);
      return;
    }
  }
}
