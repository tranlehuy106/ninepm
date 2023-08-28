import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nine_pm/screens/login/login_screen.dart';

class Introduce2Screen extends StatefulWidget {
  static const routeName = '/introduce2';

  const Introduce2Screen({super.key});

  @override
  State<StatefulWidget> createState() => _Introduce2ScreenState();
}

class _Introduce2ScreenState extends State<Introduce2Screen> {
  static const avatarExamplePath = 'assets/introduce/avatar_example.png';
  static const checkPath = 'assets/introduce/check.svg';
  static const heartPath = 'assets/introduce/heart.svg';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cách Thức Hoạt Động',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          step1(),
                          step2(),
                          step3(),
                          step4(),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: SvgPicture.asset(
                        heartPath,
                        alignment: Alignment.center,
                        width: 68,
                        height: 48,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginScreen.routeName,
                      (_) => false,
                    );
                  },
                  child: const Text('Thử ngay nào'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Quay lại'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget step1() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              numberCircle('1'),
              const SizedBox(height: 4),
              Expanded(
                child: Container(
                  width: 1,
                  color: const Color(0xFF7E4DE7),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Từ danh bạ của bạn, chọn người mà bạn muốn hẹn hò.',
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF474152),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            alignment: Alignment.topLeft,
                            child: Image.asset(
                              avatarExamplePath,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nụ Cười Ngọt Ngào 🥰',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'My Crush',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color:
                                      const Color(0xFFFFFFFF).withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          checkPath,
                          alignment: Alignment.center,
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget step2() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              numberCircle('2'),
              const SizedBox(height: 4),
              Expanded(
                child: Container(
                  width: 1,
                  color: const Color(0xFF7E4DE7),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                const Text(
                  '9PM sẽ gửi tin nhắn đến người đó với nội dung soạn sẵn.',
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF474152),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      '“Đêm về nghe lòng thương anh mất rồi, ngại vì mình con gái, phải làm sao...”',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget step3() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              numberCircle('3'),
              const SizedBox(height: 4),
              Expanded(
                child: Container(
                  width: 1,
                  color: const Color(0xFF7E4DE7),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Người đó nhận tin nhắn nhưng không biết là ai gửi. Bạn ấy cũng sẽ phải download và tâm sự với 9PM là bạn ấy thích ai.',
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget step4() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              numberCircle('4'),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Nếu người đó cũng chọn bạn để hẹn hò, thì 9PM sẽ kết nối 2 bạn với nhau.',
                ),
                SizedBox(height: 10),
                Text(
                  'Nếu không, thì ai về nhà nấy. Người kia sẽ không bao giờ biết bạn “crush” người ta.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget numberCircle(String numberText) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF7E4DE7),
          width: 1.0,
        ),
      ),
      width: 24,
      height: 24,
      child: Center(
        child: Text(
          numberText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
