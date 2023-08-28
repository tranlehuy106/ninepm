import 'package:rxdart/rxdart.dart';

import 'send_confirm_service.dart';

class SendConfirmBloc {
  SendConfirmBloc({required this.service});

  final SendConfirmService service;

  final sendLoveMessagesSubject = PublishSubject<dynamic>();

  bool _waitingResponse = false;

  void dispose() {
    sendLoveMessagesSubject.close();
  }

  Future<void> sendLoveMessages(
    String phoneNumberOfCrush,
    String reminiscentName,
  ) async {
    if (_waitingResponse) {
      return;
    }
    _waitingResponse = true;
    try {
      final response = await service.sendLoveMessages(
        phoneNumberOfCrush,
        reminiscentName,
      );
      _waitingResponse = false;
      if (sendLoveMessagesSubject.isClosed) {
        return;
      }
      sendLoveMessagesSubject.add(response);
    } on Exception catch (exception) {
      _waitingResponse = false;
      if (sendLoveMessagesSubject.isClosed) {
        return;
      }
      sendLoveMessagesSubject.addError(exception);
      return;
    }
  }
}
