import 'package:flutter/material.dart';

import 'common/bases/base_http_clients.dart';
import 'screens/chat/chat_bloc.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/chat/chat_service.dart';
import 'screens/home/home_bloc.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/home_service.dart';
import 'screens/introduce/introduce1_screen.dart';
import 'screens/introduce/introduce2_screen.dart';
import 'screens/login/login_bloc.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/login_service.dart';
import 'screens/otp/otp_bloc.dart';
import 'screens/otp/otp_screen.dart';
import 'screens/otp/otp_service.dart';
import 'screens/splash/splash_bloc.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/splash_service.dart';
import 'screens/send_confirm/send_confirm_bloc.dart';
import 'screens/send_confirm/send_confirm_screen.dart';
import 'screens/send_confirm/send_confirm_service.dart';
import 'screens/send_love_messages/send_love_messages_screen.dart';

class Routes {
  Routes({
    required this.httpClient,
  }) {
    _routes = {
      SplashScreen.routeName: (context) => SplashScreen(
            bloc: SplashBloc(
              service: SplashService(httpClient: httpClient),
            ),
          ),
      Introduce1Screen.routeName: (context) => const Introduce1Screen(),
      Introduce2Screen.routeName: (context) => const Introduce2Screen(),
      LoginScreen.routeName: (context) => LoginScreen(
            bloc: LoginBloc(
              service: LoginService(httpClient: httpClient),
            ),
          ),
      OtpScreen.routeName: (context) => OtpScreen(
            bloc: OtpBloc(
              service: OtpService(httpClient: httpClient),
            ),
          ),
      SendLoveMessagesScreen.routeName: (context) =>
          const SendLoveMessagesScreen(),
      SendConfirmScreen.routeName: (context) => SendConfirmScreen(
            bloc: SendConfirmBloc(
              service: SendConfirmService(httpClient: httpClient),
            ),
          ),
      HomeScreen.routeName: (context) => HomeScreen(
            bloc: HomeBloc(
              service: HomeService(httpClient: httpClient),
            ),
          ),
      ChatScreen.routeName: (context) => ChatScreen(
            bloc: ChatBloc(
              service: ChatService(httpClient: httpClient),
            ),
          ),
    };
  }

  final NinePmHttpClient httpClient;
  late Map<String, WidgetBuilder> _routes;

  Map<String, WidgetBuilder> get routes => _routes;
}
