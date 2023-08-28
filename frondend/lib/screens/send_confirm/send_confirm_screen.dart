import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nine_pm/common/bases/base_screen.dart';
import 'package:nine_pm/screens/home/home_screen.dart';
import 'package:nine_pm/screens/send_confirm/send_confirm_bloc.dart';

class SendConfirmScreen extends StatefulWidget {
  const SendConfirmScreen({super.key, required this.bloc});

  static const routeName = 'send_confirm';
  final SendConfirmBloc bloc;

  @override
  State<StatefulWidget> createState() => _SendConfirmScreenState();
}

class _SendConfirmScreenState extends State<SendConfirmScreen>
    with BaseScreen<SendConfirmScreen> {
  static const logoPath = 'assets/send_confirm/9pm.svg';
  static const arrowPath = 'assets/send_confirm/arrow.svg';
  static const closePath = 'assets/send_confirm/close.svg';

  late SendConfirmBloc bloc;

  String reminiscentName = 'em gái tên Linh';
  String phoneNumberOfCrush = '';

  TextEditingController textEditingController = TextEditingController();
  bool canSelect = false;

  late Function(void Function()) setStateBottomSheet;

  static const storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    preload();

    bloc = widget.bloc;
    textEditingController.addListener(updateCloseIconVisibility);

    subscriptions.add(bloc.sendLoveMessagesSubject.listen(
      onSendLoveMessages,
      onError: onHandleError,
    ));
  }

  @override
  void dispose() {
    textEditingController.dispose();
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
      phoneNumberOfCrush = item['phone_number'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: Padding(
        padding: const EdgeInsets.only(top: 64, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAppbar(),
            buildBody(),
            const SizedBox(height: 32),
            buildButtons(),
          ],
        ),
      ),
    );
  }

  TextSpan buildReminiscentName() {
    return TextSpan(
      text: reminiscentName,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF7E4DE7),
      ),
    );
  }

  Widget buildAppbar() {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(84, 84, 88, 0.36),
            width: 1.0,
          ),
        ),
      ),
      child: Stack(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              CupertinoIcons.left_chevron,
              color: Colors.white,
            ),
          ),
          const Center(
            child: Text(
              'Gửi Thông Điệp Tình Yêu',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Đang gửi tin nhắn đến '),
                    TextSpan(
                      text: phoneNumberOfCrush,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Người ấy sẽ nhận được tin nhắn với nội dung như sau:',
              ),
              const SizedBox(height: 24),
              Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: 35,
                    child: SvgPicture.asset(
                      arrowPath,
                      width: 35,
                      height: 32,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF3E3E40),
                    ),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(logoPath, width: 80, height: 30),
                        const SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Chào bạn, có một '),
                              buildReminiscentName(),
                              const TextSpan(
                                  text: ' muốn hẹn hò với bạn.\n\n'
                                      'Tin nhắn này được gửi từ một người có số điện thoại của bạn. '),
                              const TextSpan(
                                text: '9PM',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(
                                  text:
                                      ' là ứng dụng hẹn hò dành cho những người đã quen biết nhau.\n\n'
                                      'Vì một lý do nào đó, '),
                              buildReminiscentName(),
                              const TextSpan(
                                  text:
                                      ' cảm thấy khó ngỏ lời trực tiếp, nên '),
                              const TextSpan(
                                text: '9PM',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(
                                  text:
                                      ' là cầu nối để 2 bạn có thể tìm thấy nhau.\n\n'
                                      'Download 9PM tại đây!'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: showSelectName,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF3E3E40),
                  ),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Thay đổi “'),
                          buildReminiscentName(),
                          const TextSpan(text: '”'),
                        ],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ninePmButton(
        onPressed: () async {
          storage.write(
            key: 'ninepm_reminiscent_name',
            value: reminiscentName,
          );
          setLoading(true);
          await bloc.sendLoveMessages(phoneNumberOfCrush, reminiscentName);
          setLoading(false);
        },
        text: 'Xác nhận gửi tin nhắn',
      ),
    );
  }

  Future showSelectName() async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          setStateBottomSheet = setState;
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: IntrinsicHeight(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 150,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 61,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromRGBO(84, 84, 88, 0.36),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Vui lòng chọn',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildNameOption('Đồng nghiệp'),
                              buildNameOption('Đồng nghiệp cũ'),
                              buildNameOption('Em gái'),
                              buildNameOption('Anh trai'),
                              buildNameOption('Bạn cùng lớp'),
                              buildNameOption('Người bí mật'),
                              buildNameOption('Người thầm thương trộm nhớ'),
                              buildNameOption('Fan hâm mộ'),
                              const SizedBox(height: 20),
                              const Text(
                                  'Không thích các lựa chọn trên? Viết gợi nhớ của riêng bạn:'),
                              const SizedBox(height: 12),
                              nameField(),
                              const SizedBox(height: 8),
                              const Text(
                                'Đừng viết lộ quá nhé, hãy để người kia phải đoán xem bạn là ai!',
                                style: TextStyle(color: Color(0x99FFFFFF)),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNameOption(String name) {
    return GestureDetector(
      onTap: () {
        setState(() {
          reminiscentName = name;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2C2C2E),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        child: Text(name),
      ),
    );
  }

  Widget nameField() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              controller: textEditingController,
              maxLength: 127,
              decoration: InputDecoration(
                suffixIcon: Visibility(
                  visible: canSelect,
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
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: const Color(0xFF3E3E40),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                counterText: '',
                hintText: 'Nhập tên gợi nhớ',
                hintStyle: const TextStyle(color: Color(0x99EBEBF5)),
              ),
              style: const TextStyle(color: Color(0x99EBEBF5)),
              cursorColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: canSelect
                ? () {
                    setState(() {
                      reminiscentName = textEditingController.text;
                    });
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Chọn'),
          ),
        )
      ],
    );
  }

  void clearText() {
    textEditingController.clear();
  }

  void updateCloseIconVisibility() {
    setStateBottomSheet(() {
      canSelect = textEditingController.text.isNotEmpty;
    });
  }

  void onSendLoveMessages(data) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      HomeScreen.routeName,
      (_) => false,
    );
  }

  Future<void> preload() async {
    var name = await storage.read(key: 'ninepm_reminiscent_name');
    if (name != null) {
      reminiscentName = name;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
