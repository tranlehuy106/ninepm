import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nine_pm/common/bases/base_screen.dart';
import 'package:nine_pm/screens/home/home_screen.dart';

import 'splash_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.bloc});

  static const routeName = '/splash';
  final SplashBloc bloc;

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with BaseScreen<SplashScreen>, WidgetsBindingObserver {
  static const logoPath = 'assets/splash/9pm.svg';

  late SplashBloc bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    bloc = widget.bloc;
    bloc.loginStatus();
    subscriptions.add(bloc.loginStatusSubject.listen(
      onLoginStatus,
      onError: onHandleError,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    bloc.dispose();
    super.disposeScreen();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      bloc.loginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            colors: [
              Color(0xFF2B1A4F),
              Color(0xFF171717),
            ],
            transform: GradientRotation(225 * 3.1415927 / 180),
          ),
        ),
        child: buildBody(),
      ),
    );
  }

  Widget buildBody(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            logoPath,
            alignment: Alignment.center,
            width: 160,
            height: 60,
          ),
          const SizedBox(height: 8),
          const Text('Hẹn hò bí mật')
        ],
      ),
    );
  }

  onLoginStatus(data) async {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      HomeScreen.routeName,
      (_) => false,
    );
  }
}
