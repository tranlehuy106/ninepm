import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'introduce2_screen.dart';

class Introduce1Screen extends StatefulWidget {
  static const routeName = '/introduce1';

  const Introduce1Screen({super.key});

  @override
  State<StatefulWidget> createState() => _Introduce1ScreenState();
}

class _Introduce1ScreenState extends State<Introduce1Screen> {
  static const logoPath = 'assets/introduce/9pm.svg';
  static const illustrativePath = 'assets/introduce/illustrative.svg';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 64, bottom: 32),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        logoPath,
                        alignment: Alignment.center,
                        width: 40,
                        height: 15,
                      ),
                      const SizedBox(height: 24),
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Gửi Thông Điệp Tình\nYêu '),
                            TextSpan(
                              text: 'Bí mật',
                              style: TextStyle(color: Color(0xFF8551F5)),
                            ),
                            TextSpan(text: ' Đến Người\nMình Thích'),
                          ],
                        ),
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SvgPicture.asset(
                        illustrativePath,
                        alignment: Alignment.center,
                        width: 327,
                        height: 266,
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Bạn đang thích một đồng nghiệp, một người bạn học,'
                        ' hay thậm chí là chưa quên người yêu cũ? ',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '9PM sẽ giúp bạn hẹn hò với người ta '
                        'một cách âm thầm và kín đáo.',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Introduce2Screen.routeName);
                  },
                  child: const Text('Tiếp tục'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
