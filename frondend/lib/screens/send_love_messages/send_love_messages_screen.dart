import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nine_pm/screens/send_confirm/send_confirm_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:grouped_list/grouped_list.dart';

class ContactItem {
  ContactItem({
    this.index = 0,
    required this.phone,
    required this.title,
    required this.group,
    this.isLast = false,
  });

  int index;
  String phone, title, group;
  bool isLast;
}

class SendLoveMessagesScreen extends StatefulWidget {
  static const routeName = '/send_love_messages';

  const SendLoveMessagesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SendLoveMessagesScreenState();
}

class _SendLoveMessagesScreenState extends State<SendLoveMessagesScreen>
    with WidgetsBindingObserver {
  static const closePath = 'assets/send_love_messages/close.svg';
  static const warningPath = 'assets/send_love_messages/warning.svg';
  static const contactPath = 'assets/send_love_messages/contact.svg';
  static const searchPath = 'assets/send_love_messages/search.svg';
  static const questionsPath = 'assets/send_love_messages/questions.svg';
  static const avatarPath = 'assets/send_love_messages/avatar.png';
  static const avatarExamplePath =
      'assets/send_love_messages/avatar_example.png';
  static const checkPath = 'assets/send_love_messages/check.svg';

  TextEditingController textEditingController = TextEditingController();
  TextEditingController textContactEditingController = TextEditingController();
  bool showCloseIcon = false;

  String phoneNumber = '';
  final phoneNumberPatterns = [
    RegExp(r'^0\d\d\d\d\d\d\d\d\d$'),
    RegExp(r'^\+84\d\d\d\d\d\d\d\d\d$'),
  ];

  final searchPhonePatterns =
      RegExp(r'^[+]*[(]{0,1}[+]*[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');

  late PermissionStatus permissionStatus;
  bool isOpenAppSettings = false;

  bool isFetchContacts = false;
  late List<Contact> sortedContacts;

  List<ContactItem> contactsValue = [];
  List<ContactItem> contactsDisplay = [];

  String groupFirst = '';

  StateSetter? setStateBottomSheet;
  bool loadingBottomSheet = false;

  Timer? debounce;

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(updateCloseIconVisibility);
  }

  @override
  void dispose() {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }
    textEditingController.dispose();
    textContactEditingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isOpenAppSettings) {
        isOpenAppSettings = false;
        getContactPermission();
      }
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
            buildButtons(),
          ],
        ),
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
          Visibility(
            visible: Navigator.of(context).canPop(),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                CupertinoIcons.left_chevron,
                color: Colors.white,
              ),
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
            children: [
              const SizedBox(height: 40),
              const Text(
                'Ngay lúc này, bạn đang nghĩ đến ai, nhập số của người đó nhé:',
              ),
              const SizedBox(height: 32),
              TextField(
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
                  fillColor: const Color(0xFF3E3E40),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  counterText: '',
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 20,
                child: Visibility(
                  visible: false,
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
                        const Text(
                          'Số điện thoại bạn nhập chưa chính xác.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFCB2027),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Hoặc',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  await getContactPermission();
                  showContact();
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF3E3E40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        contactPath,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Chọn từ danh bạ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: [
          InkWell(
            onTap: showTutorial,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(questionsPath, width: 16, height: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Cách Thức Hoạt Động',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isVietnamPhoneNumber(phoneNumber) ? onNext : null,
              child: const Text('Tiếp tục'),
            ),
          ),
        ],
      ),
    );
  }

  void clearText() {
    textEditingController.clear();
  }

  void updateCloseIconVisibility() {
    setState(() {
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
    if (value.length < 10) {
      return value;
    }
    if (value.substring(0, 3) == '+84') {
      return value;
    }
    return '+84$value';
  }

  void onNext() {
    final canNext = isVietnamPhoneNumber(phoneNumber);
    if (!canNext) {
      return;
    }
    Navigator.of(context).pushNamed(
      SendConfirmScreen.routeName,
      arguments: {'phone_number': phoneNumber},
    );
  }

  Future showTutorial() async {
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
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      'Cách thức hoạt động',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 21,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          step1(),
                          step2(),
                          step3(),
                          step4(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

  Future showContact() async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: IntrinsicHeight(
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
                    'Chọn từ danh bạ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                setStateBottomSheet = setState;
                return Column(
                  children: [
                    Visibility(
                      visible: loadingBottomSheet,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 150,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    buildContacts(),
                    buildAskForPermission(),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContacts() {
    var viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    double height = MediaQuery.of(context).size.height - 150;
    if (viewInsetsBottom > 0) {
      height = MediaQuery.of(context).size.height -
          MediaQuery.of(context).viewInsets.bottom -
          61;
    }
    return Visibility(
      visible: permissionStatus.isGranted && !loadingBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
        height: height,
        child: Column(
          children: [
            buildSearchField(),
            const SizedBox(height: 24),
            Expanded(
              child: GroupedListView<dynamic, String>(
                elements: contactsDisplay,
                groupBy: (element) => element.group,
                itemComparator: (item1, item2) =>
                    item1.index.compareTo(item2.index),
                groupSeparatorBuilder: (String value) =>
                    buildContactGroup(value),
                itemBuilder: (context, element) {
                  if (element.index == 0) {
                    return buildContactItemFirst(element);
                  }
                  return buildContactItem(element);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAskForPermission() {
    return Visibility(
      visible: !permissionStatus.isGranted && !loadingBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
        height: MediaQuery.of(context).size.height - 150,
        child: Column(
          children: [
            Image.asset(
              avatarPath,
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            const Opacity(
              opacity: 0.6,
              child: Text(
                'Vui lòng cho phép 9pm truy cập danh bạ để 9pm có thể giúp bạn chọn người mình thích nhanh và chính xác hơn.\n\n'
                '9pm KHÔNG lưu thông tin danh bạ của bạn.\n\n'
                'Bạn có thể bật/tắt quyền truy cập danh bạ bất cứ lúc nào bằng cách chọn app 9pm trong cài đặt của máy và bật/tắt quyền truy cập danh bạ.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => requestPermissionContact(),
                child: Text(
                  isOpenAppSettings ? 'Mở cài đặt' : 'Cho phép truy cập',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSearchField() {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: textContactEditingController,
        onChanged: onSearchContacts,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: SvgPicture.asset(
              searchPath,
              width: 16,
              height: 16,
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: const Color(0x3D767680),
          contentPadding: EdgeInsets.zero,
          counterText: '',
          hintText: 'Tìm kiếm',
          hintStyle: const TextStyle(color: Color(0x99EBEBF5)),
        ),
        style: const TextStyle(color: Color(0x99EBEBF5)),
        cursorColor: Colors.white,
      ),
    );
  }

  Widget buildContactGroup(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: label != groupFirst,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              color: Color(0xFF2C2C2E),
            ),
            height: 8,
            margin: const EdgeInsets.only(bottom: 24),
          ),
        ),
        Opacity(
          opacity: 0.6,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            color: Color(0xFF2C2C2E),
          ),
          height: 9,
        )
      ],
    );
  }

  Widget buildContactItemFirst(ContactItem item) {
    return GestureDetector(
      onTap: () => onSelectContact(item),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2E),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset(
                  avatarPath,
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Opacity(
                        opacity: 0.6,
                        child: Text(item.phone),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: item.isLast,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
                color: Color(0xFF2C2C2E),
              ),
              height: 8,
              margin: const EdgeInsets.only(bottom: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContactItem(ContactItem item) {
    return GestureDetector(
      onTap: () => onSelectContact(item),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2E),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Image.asset(
                    avatarPath,
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromRGBO(84, 84, 88, 0.36),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Opacity(
                        opacity: 0.6,
                        child: Text(item.phone),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: item.isLast,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
                color: Color(0xFF2C2C2E),
              ),
              height: 8,
              margin: const EdgeInsets.only(bottom: 24),
            ),
          ),
        ],
      ),
    );
  }

  void onSelectContact(ContactItem item) {
    final canNext = isVietnamPhoneNumber(item.phone);
    if (!canNext) {
      Fluttertoast.showToast(
        msg: '9PM chỉ hỗ trợ số điện thoại ở VIỆT NAM',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: const Color(0xFFF3F3F3),
        textColor: const Color(0xFFFF6868),
        fontSize: 16,
      );
      return;
    }
    String phone = normalizeVietnamPhoneNumber(item.phone);
    Navigator.of(context).pushNamed(
      SendConfirmScreen.routeName,
      arguments: {'phone_number': phone},
    );
  }

  Future<void> getContactPermission() async {
    permissionStatus = await Permission.contacts.status;

    switch (permissionStatus) {
      case PermissionStatus.granted:
        fetchContacts();
        break;
      case PermissionStatus.permanentlyDenied:
        isOpenAppSettings = true;
        break;
      default:
        break;
    }
  }

  Future<void> requestPermissionContact() async {
    if (isOpenAppSettings) {
      openAppSettings();
      return;
    }

    permissionStatus = await Permission.contacts.request();
    switch (permissionStatus) {
      case PermissionStatus.granted:
        fetchContacts();
        break;
      case PermissionStatus.permanentlyDenied:
        isOpenAppSettings = true;
        break;
      default:
        break;
    }
    if (mounted && setStateBottomSheet != null) {
      setStateBottomSheet!(() {});
    }
  }

  void onSearchContacts(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      String search = VietnameseCore.unSignAndToLowerCase(value.trim());
      parseContactsDisplay(search);
    });
  }

  Future<void> fetchContacts() async {
    if (isFetchContacts) {
      return;
    }
    loadingBottomSheet = true;
    if (mounted && setStateBottomSheet != null) {
      setStateBottomSheet!(() {});
    }
    var contacts = await ContactsService.getContacts(
        withThumbnails: false, photoHighResolution: false);
    var sortedContacts = List<Contact>.from(contacts)
      ..sort((a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''));
    isFetchContacts = true;
    var contactContents = getContactContents(sortedContacts);
    contactsValue.addAll(contactContents);
    loadingBottomSheet = false;
    parseContactsDisplay('');
  }

  List<ContactItem> getContactContents(List<Contact> contacts) {
    List<ContactItem> list = [];
    String group = '';

    for (Contact c in contacts) {
      for (int elementIndex = 0;
          elementIndex < (c.phones?.length ?? 0);
          elementIndex++) {
        String? phone = c.phones?.elementAt(elementIndex).value;

        if (phone == null) continue;

        phone = convertOnlyNumber(phone);
        if (phone == '') continue;

        String? displayName = c.displayName;
        if (displayName == null) {
          var item = c.phones?.elementAt(elementIndex);
          displayName = "${item?.label} ${item?.value}";
        }

        String title = displayName ?? '';
        String charFirst = '';

        if (title.isNotEmpty) {
          charFirst = title[0].toUpperCase();
        }

        if (charFirst != group) {
          group = charFirst;
        }

        var item = ContactItem(
          phone: phone,
          title: title,
          group: group,
        );

        list.add(item);
      }
    }

    return list;
  }

  void parseContactsDisplay(String search) {
    String group = '';
    int index = 0;

    contactsDisplay = [];
    if (search.isEmpty) {
      for (var item in contactsValue) {
        item.isLast = false;
        if (group != item.group) {
          group = item.group;
          index = 0;
        }
        item.index = index++;
        contactsDisplay.add(item);
      }
    } else {
      bool isSearchByPhone = searchPhonePatterns.hasMatch(search);

      String searchPhone0 = '';
      String searchPhone84 = '';
      if (isSearchByPhone) {
        searchPhone0 = convertOnlyNumber(search);
        if (searchPhone0.isEmpty) {
          return;
        }
        searchPhone84 = searchPhone0;
        if (searchPhone84[0] == '0') {
          searchPhone84 = '+84${searchPhone84.substring(1)}';
        }
      }

      for (var item in contactsValue) {
        item.isLast = false;
        if (isSearchByPhone) {
          if (searchPhone0 == '') {
            continue;
          }

          String phone = normalizeVietnamPhoneNumber(item.phone);

          if (searchPhone0 == searchPhone84) {
            if (!phone.contains(searchPhone0)) {
              continue;
            }
          } else {
            if (!phone.contains(searchPhone0) &&
                !phone.contains(searchPhone84)) {
              continue;
            }
          }
        } else {
          String name = VietnameseCore.unSignAndToLowerCase(item.title);
          if (!name.contains(search)) {
            continue;
          }
        }

        if (group != item.group) {
          group = item.group;
          index = 0;
        }

        item.index = index++;
        contactsDisplay.add(item);
      }
    }

    if (contactsDisplay.isNotEmpty) {
      var title = contactsDisplay[0].title;
      if (title.isNotEmpty) {
        groupFirst = title[0].toUpperCase();
      }
      contactsDisplay.last.isLast = true;
    }

    if (mounted && setStateBottomSheet != null) {
      setStateBottomSheet!(() {});
    }
  }

  String convertOnlyNumber(String? value) {
    if (value == null) return '';
    value = value.trim();
    String result = '';
    String data = '0123456789';
    for (int i = 0; i < value.length; i++) {
      for (int j = 0; j < data.length; j++) {
        if (value[i] == data[j]) {
          result += value[i];
          break;
        }
      }
    }
    return result;
  }
}

abstract class VietnameseCore {
  static final Map<String, String> _charsMap = {
    "à": "a",
    "á": "a",
    "ạ": "a",
    "ả": "a",
    "ã": "a",
    "â": "a",
    "ầ": "a",
    "ấ": "a",
    "ậ": "a",
    "ẩ": "a",
    "ẫ": "a",
    "ă": "a",
    "ằ": "a",
    "ắ": "a",
    "ặ": "a",
    "ẳ": "a",
    "ẵ": "a",
    "è": "e",
    "é": "e",
    "ẹ": "e",
    "ẻ": "e",
    "ẽ": "e",
    "ê": "e",
    "ề": "e",
    "ế": "e",
    "ệ": "e",
    "ể": "e",
    "ễ": "e",
    "ò": "o",
    "ó": "o",
    "ọ": "o",
    "ỏ": "o",
    "õ": "o",
    "ô": "o",
    "ồ": "o",
    "ố": "o",
    "ộ": "o",
    "ổ": "o",
    "ỗ": "o",
    "ơ": "o",
    "ờ": "o",
    "ớ": "o",
    "ợ": "o",
    "ở": "o",
    "ỡ": "o",
    "ù": "u",
    "ú": "u",
    "ụ": "u",
    "ủ": "u",
    "ũ": "u",
    "ư": "u",
    "ừ": "u",
    "ứ": "u",
    "ự": "u",
    "ử": "u",
    "ữ": "u",
    "ì": "i",
    "í": "i",
    "ị": "i",
    "ỉ": "i",
    "ĩ": "i",
    "ỳ": "y",
    "ý": "y",
    "ỵ": "y",
    "ỷ": "y",
    "ỹ": "y",
    "đ": "d"
  };

  static String unSignAndToLowerCase(String? text) {
    if (text == null) return '';
    String result = '';
    text = text.toLowerCase();
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (_charsMap.containsKey(char)) {
        char = _charsMap[char]!;
      }
      result += char;
    }
    return result;
  }
}
