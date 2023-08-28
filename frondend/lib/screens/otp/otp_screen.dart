import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nine_pm/common/bases/base_http_clients.dart';
import 'package:nine_pm/common/bases/base_http_exception.dart';
import 'package:nine_pm/common/bases/base_screen.dart';
import 'package:nine_pm/screens/home/home_screen.dart';
import 'package:nine_pm/screens/send_love_messages/send_love_messages_screen.dart';
import 'package:nine_pm/settings/environment_settings.dart';
import 'package:nine_pm/utils/parse_json_data.dart';
import 'package:provider/provider.dart';

import 'otp_bloc.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.bloc});

  static const routeName = '/otp';
  final OtpBloc bloc;

  @override
  State<StatefulWidget> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with BaseScreen<OtpScreen> {
  static const closePath = 'assets/otp/close.svg';
  static const warningPath = 'assets/otp/warning.svg';

  late OtpBloc bloc;

  TextEditingController textEditingController = TextEditingController();
  bool showCloseIcon = false;

  int countdown = EnvironmentSettings.resendOTPIntervalInSeconds;

  Timer? debounceTimer;
  late Timer timer;

  bool canResendOTP = false;

  String phoneNumber = '';
  String token = '';
  int otpLength = -1;

  String msgError = '';

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;

    textEditingController.addListener(updateCloseIconVisibility);

    const duration = Duration(seconds: 1);

    timer = Timer.periodic(duration, (Timer timer) {
      if (countdown > 0) {
        countdown--;
        if (countdown == 0) {
          canResendOTP = true;
        }
        setState(() {});
      }
    });

    subscriptions.add(bloc.validateLoginOtpSubject.listen(
      onValidateLoginOtp,
      onError: onHandleError,
    ));

    subscriptions.add(bloc.sendOtpAgainSubject.listen(
      onSendOtpAgain,
      onError: onHandleError,
    ));
  }

  @override
  void dispose() {
    textEditingController.dispose();
    if (timer.isActive) {
      timer.cancel();
    }
    if (debounceTimer?.isActive ?? false) {
      debounceTimer!.cancel();
    }
    bloc.dispose();
    super.disposeScreen();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    firstRun();
  }

  @override
  void onFirstRun(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      final item = args as dynamic;
      phoneNumber = item['phone_number'];
      token = item['token'];
      otpLength = item['otp_length'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 64, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập OTP',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            Text(
              'Một mã xác thực gồm 6 chữ số đã được gửi tới số điện thoại $phoneNumber',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: textEditingController,
              onChanged: handleDebouncedInput,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              maxLength: 10,
              decoration: InputDecoration(
                suffixIcon: Visibility(
                  visible: showCloseIcon,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                      onTap: clearText,
                      child: SvgPicture.asset(
                        closePath,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: const Color(0xFF3E3E40),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                counterText: '',
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
            const SizedBox(height: 2),
            Container(
              constraints: const BoxConstraints(minHeight: 20),
              child: Visibility(
                visible: msgError.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        warningPath,
                        alignment: Alignment.center,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          msgError,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFCB2027),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Không nhận được mã?',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Visibility(
              visible: !canResendOTP,
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  'Gửi lại sau ${timeToString(countdown)}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: canResendOTP,
              child: InkWell(
                onTap: sendOtpAgain,
                child: const Text(
                  'Gửi lại mã OTP',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8551F5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clearText() {
    msgError = '';
    textEditingController.clear();
  }

  void updateCloseIconVisibility() {
    setState(() {
      msgError = '';
      showCloseIcon = textEditingController.text.isNotEmpty;
    });
  }

  String timeToString(int timeInSeconds) {
    final seconds = timeInSeconds % 60;
    final timeInMinutes = timeInSeconds ~/ 60;
    final minutes = timeInMinutes % 60;
    final timeInHours = timeInMinutes ~/ 60;
    final strHour =
        timeInHours > 0 ? '${timeInHours.toString().padLeft(2, '0')}:' : '';
    return '$strHour${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void sendOtpAgain() {
    setState(() {
      countdown = EnvironmentSettings.resendOTPIntervalInSeconds;
      canResendOTP = false;
    });
    bloc.sendOtpAgain(token);
  }

  void handleDebouncedInput(String input) {
    const debounceTime = Duration(milliseconds: 500);
    if (debounceTimer?.isActive ?? false) {
      debounceTimer!.cancel();
    }
    debounceTimer = Timer(debounceTime, () {
      if (input.length == otpLength) {
        bloc.validateLoginOtp(token, input);
      }
    });
  }

  onValidateLoginOtp(data) {
    var item = parseDynamic(data, 'item');
    var isCrushExists = parseDynamic(data, 'is_crush_exists');
    String token = parseStr(item, 'token');

    const secureStorage = FlutterSecureStorage();
    secureStorage.write(key: 'ninepm_auth_token', value: token);
    var httpClient = Provider.of<NinePmHttpClient>(context, listen: false);
    httpClient.authTokenValue = token;

    if (!mounted) {
      return;
    }

    if (isCrushExists) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeScreen.routeName,
        (_) => false,
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        SendLoveMessagesScreen.routeName,
        (_) => false,
      );
    }
  }

  onSendOtpAgain(data) {
    otpLength = int.parse(data['otp_length']);
  }

  @override
  void onHandleError(exception) {
    if (exception is MessageException) {
      setState(() {
        msgError = exception.message;
      });
      return;
    }

    super.onHandleError(exception);
  }
}
