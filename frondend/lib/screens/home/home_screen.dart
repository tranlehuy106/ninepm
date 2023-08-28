import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nine_pm/common/bases/base_screen.dart';
import 'package:nine_pm/common/fcm/fcm_bloc.dart';
import 'package:nine_pm/screens/chat/chat_screen.dart';
import 'package:nine_pm/utils/parse_json_data.dart';
import 'package:provider/provider.dart';

import 'chat_tab_screen.dart';
import 'home_bloc.dart';
import 'home_dto.dart';
import 'home_tab_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.bloc});

  static const routeName = '/home';
  final HomeBloc bloc;

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with BaseScreen<HomeScreen>, SingleTickerProviderStateMixin {
  static const heartSelectedPath = 'assets/home/heart_selected.svg';
  static const heartUnselectedPath = 'assets/home/heart_unselected.svg';
  static const chatSelectedPath = 'assets/home/chat_selected.svg';
  static const chatUnselectedPath = 'assets/home/chat_unselected.svg';
  static const bgSuccessPath = 'assets/home/bg_success.png';
  static const couplePath = 'assets/home/couple.svg';

  late HomeBloc bloc;

  late TabController tabController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
    bloc.getListCrush();
    bloc.getListLover();

    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(handleTabChange);
  }

  @override
  void dispose() {
    tabController.dispose();
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
    var fcmBloc = Provider.of<FcmBloc>(context);
    subscriptions.add(fcmBloc.receiveMessageStreamController.listen(
      onReceiveMessage,
    ));

    subscriptions.add(bloc.getListCrushSubject.listen(
      (_) => onGetListCrush(context),
      onError: onHandleError,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: TabBarView(
        controller: tabController,
        children: [
          HomeTabScreen(key: UniqueKey(), bloc: bloc),
          ChatTabScreen(key: UniqueKey(), bloc: bloc),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: Color(0x40FFFFFF)),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF323233),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedItemColor: const Color(0xFF8551F5),
          unselectedItemColor: const Color(0x66FFFFFF),
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
              tabController.index = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              activeIcon: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SvgPicture.asset(
                  heartSelectedPath,
                  width: 24,
                  height: 24,
                ),
              ),
              icon: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SvgPicture.asset(
                  heartUnselectedPath,
                  width: 24,
                  height: 24,
                ),
              ),
              label: 'Crush',
            ),
            BottomNavigationBarItem(
              activeIcon: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SvgPicture.asset(
                  chatSelectedPath,
                  width: 24,
                  height: 24,
                ),
              ),
              icon: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SvgPicture.asset(
                  chatUnselectedPath,
                  width: 24,
                  height: 24,
                ),
              ),
              label: 'Trò chuyện',
            ),
          ],
        ),
      ),
    );
  }

  void handleTabChange() {
    if (currentIndex != tabController.index) {
      setState(() {
        currentIndex = tabController.index;
      });
    }

    if (tabController.index == 0) {
      bloc.getListCrush();
    } else if (tabController.index == 1) {
      bloc.getListLover();
    }
  }

  onReceiveMessage(RemoteMessage remoteMessage) {
    String type = parseStr(remoteMessage.data, 'type');
    switch (type) {
      case 'connected':
        bloc.getListCrush();
        break;
      default:
        break;
    }
  }

  Future<bool?> showSuccessDialog(
    BuildContext context,
    HomeLoverItem item,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          alignment: Alignment.center,
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(bgSuccessPath),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: 326,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Xin chúc mừng!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bạn và người ấy đã kết nối thành công với nhau.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SvgPicture.asset(couplePath, width: 200, height: 200),
                    const SizedBox(height: 16),
                    Text(
                      item.phoneNumberOfCrush,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Trò chuyện ngay nào.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFFFFFF),
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Gửi lời chào 👋'),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Để sau'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  onGetListCrush(BuildContext context) async {
    for (final item in bloc.homeLoverList) {
      var result = await showSuccessDialog(context, item);
      if (result ?? false) {
        if (context.mounted) {
          await Navigator.of(context).pushNamed(
            ChatScreen.routeName,
            arguments: {
              'phone_number_of_crush': item.phoneNumberOfCrush,
              'id': item.crushUserId
            },
          );
        }
      }
    }
  }
}
