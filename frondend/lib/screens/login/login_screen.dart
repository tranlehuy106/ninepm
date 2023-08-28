import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nine_pm/common/bases/base_http_exception.dart';
import 'package:nine_pm/common/bases/base_screen.dart';
import 'package:nine_pm/screens/login/login_bloc.dart';
import 'package:nine_pm/screens/otp/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.bloc});

  static const routeName = '/login';
  final LoginBloc bloc;

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with BaseScreen<LoginScreen> {
  static const logoPath = 'assets/login/9pm.svg';
  static const bgPath = 'assets/login/bg.png';
  static const closePath = 'assets/login/close.svg';
  static const warningPath = 'assets/login/warning.svg';

  late LoginBloc bloc;

  TextEditingController textEditingController = TextEditingController();
  bool showCloseIcon = false;

  String phoneNumber = '';
  final phoneNumberPatterns = [
    RegExp(r'^0\d\d\d\d\d\d\d\d\d$'),
    RegExp(r'^\+84\d\d\d\d\d\d\d\d\d$'),
  ];

  String msgError = '';

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
    textEditingController.addListener(updateCloseIconVisibility);
    subscriptions.add(bloc.loginSubject.listen(
      onLogin,
      onError: onHandleError,
    ));
  }

  @override
  void dispose() {
    textEditingController.dispose();
    bloc.dispose();
    super.disposeScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgPath),
            fit: BoxFit.cover,
          ),
        ),
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    SvgPicture.asset(
                      logoPath,
                      alignment: Alignment.center,
                      width: 160,
                      height: 60,
                    ),
                    const SizedBox(height: 8),
                    const Text('Hẹn hò bí mật'),
                    const SizedBox(height: 80),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nhập số điện thoại',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        buildInput(),
                        const SizedBox(height: 2),
                        buildInputError(),
                        const SizedBox(height: 2),
                        buildButtons(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'Bằng việc tiếp tục, bạn đồng ý với các Điều khoản và Chính sách của chúng tôi.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget buildInput() {
    return TextField(
      controller: textEditingController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      maxLength: 15,
      decoration: InputDecoration(
        prefixText: '+84 | ',
        prefixStyle: const TextStyle(color: Colors.white),
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
        fillColor: Colors.white.withOpacity(0.16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        counterText: '',
      ),
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
    );
  }

  Widget buildInputError() {
    return Container(
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
    );
  }

  Widget buildButtons() {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ninePmButton(
        onPressed: isVietnamPhoneNumber(phoneNumber) ? login : null,
        text: 'Đăng nhập',
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
      phoneNumber = normalizeVietnamPhoneNumber(textEditingController.text);
      showCloseIcon = textEditingController.text.isNotEmpty;
    });
  }

  bool isVietnamPhoneNumber(String input) {
    final candidate = input.trim().replaceAll(' ', '');
    for (final pattern in phoneNumberPatterns) {
      final hasMatch = pattern.hasMatch(candidate);
      if (hasMatch) {
        return true;
      }
    }
    return false;
  }

  String normalizeVietnamPhoneNumber(String phoneNumber) {
    final value = phoneNumber.trim().replaceAll(' ', '');
    if (value.isEmpty) {
      return '';
    }
    if (value[0] == '0') {
      return '+84${value.substring(1)}';
    }
    return '+84$value';
  }

  Future<void> login() async {
    final canLogin = isVietnamPhoneNumber(phoneNumber);
    if (!canLogin) {
      return;
    }
    setLoading(true);
    await bloc.login(phoneNumber);
    setLoading(false);
  }

  void onLogin(data) {
    String token = data['token'];
    int otpLength = int.parse(data['otp_length']);
    Navigator.of(context).pushNamed(OtpScreen.routeName, arguments: {
      'phone_number': phoneNumber,
      'token': token,
      'otp_length': otpLength,
    });
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
