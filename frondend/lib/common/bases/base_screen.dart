import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nine_pm/screens/introduce/introduce1_screen.dart';
import 'package:rxdart/rxdart.dart';

import 'base_http_exception.dart';

mixin BaseScreen<T extends StatefulWidget> on State<T> {
  final subscriptions = CompositeSubscription();

  bool _firstRun = true;

  bool loading = false;

  void initScreen() {}

  void disposeScreen() {
    subscriptions.dispose();
  }

  void firstRun() {
    if (_firstRun) {
      onFirstRun(context);
      _firstRun = false;
    }
  }

  void onFirstRun(BuildContext context) {}

  void onHandleError(exception) {
    if (exception is MessageException) {
      Fluttertoast.showToast(
        msg: exception.message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: const Color(0xFFF3F3F3),
        textColor: const Color(0xFFFF6868),
        fontSize: 16,
      );
      return;
    }

    if (exception is UnauthorizedException) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Introduce1Screen.routeName,
        (_) => false,
      );
      return;
    }

    Fluttertoast.showToast(
      msg: 'Có lỗi xảy ra. Vui lòng thử lại sau.',
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: const Color(0xFFF3F3F3),
      textColor: const Color(0xFFFF6868),
      fontSize: 16,
    );
  }

  setLoading(bool value) {
    if (mounted) {
      setState(() {
        loading = value;
      });
    }
  }

  Widget _buttonText(String text) {
    return Stack(
      children: [
        Visibility(
          visible: loading,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        Visibility(
          visible: !loading,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
      ],
    );
  }

  Widget ninePmButton({required String text, VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: _buttonText(text),
    );
  }
}
