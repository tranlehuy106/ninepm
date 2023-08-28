import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nine_pm/common/bases/base_screen.dart';
import 'package:nine_pm/common/fcm/fcm_bloc.dart';
import 'package:nine_pm/screens/chat/chat_screen.dart';
import 'package:nine_pm/utils/parse_json_data.dart';
import 'package:provider/provider.dart';
import 'home_bloc.dart';
import 'home_dto.dart';

class ChatTabScreen extends StatefulWidget {
  const ChatTabScreen({super.key, required this.bloc});

  final HomeBloc bloc;

  @override
  State<StatefulWidget> createState() => _ChatTabScreenState();
}

class _ChatTabScreenState extends State<ChatTabScreen>
    with BaseScreen<ChatTabScreen> {
  static const liveChat = 'assets/home/live_chat.svg';

  late HomeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
  }

  @override
  void dispose() {
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
    subscriptions.add(bloc.getListLoverSubject.listen(
      onGetListLover,
      onError: onHandleError,
    ));

    var fcmBloc = Provider.of<FcmBloc>(context);
    subscriptions.add(fcmBloc.receiveMessageStreamController.listen(
      onReceiveMessage,
    ));
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
      child: const Center(
        child: Text(
          'Trò chuyện',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    return Expanded(
      child: Stack(
        children: [
          Visibility(
            visible: bloc.chatLoverList.isEmpty,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  liveChat,
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      'Những người kết nối thành công '
                      'với bạn sẽ được hiển thị tại đây, '
                      'nơi bạn có thể trò chuyện.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: bloc.chatLoverList.isNotEmpty,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Những người kết nối thành công '
                    'với bạn sẽ được hiển thị tại đây, '
                    'nơi bạn có thể trò chuyện.',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: bloc.chatLoverList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildItem(bloc.chatLoverList[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(ChatLoverItem lover) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          ChatScreen.routeName,
          arguments: {
            'phone_number_of_crush': lover.phoneNumberOfCrush,
            'id': lover.crushUserId
          },
        );
        bloc.getListLover();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '****** ${lover.phoneNumberOfCrush}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  lover.startAt,
                  style: TextStyle(
                    fontSize: 15,
                    color: lover.status == 'SEEN'
                        ? const Color(0x99EBEBF5)
                        : const Color(0xFFEBEBF5),
                    fontWeight: lover.status == 'SEEN'
                        ? FontWeight.w400
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              lover.message,
              style: TextStyle(
                fontSize: 12,
                color: lover.status == 'SEEN'
                    ? const Color(0x99EBEBF5)
                    : const Color(0xFFEBEBF5),
                fontWeight:
                    lover.status == 'SEEN' ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  onGetListLover(_) {
    if (mounted) {
      setState(() {});
    }
  }

  onReceiveMessage(RemoteMessage remoteMessage) {
    if (parseStr(remoteMessage.data, 'type') != 'chat') {
      return;
    }

    if (!mounted) {
      return;
    }

    bloc.getListLover();
  }
}
