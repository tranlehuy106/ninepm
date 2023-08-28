import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:nine_pm/common/bases/base_screen.dart';
import 'package:nine_pm/common/fcm/fcm_bloc.dart';
import 'package:nine_pm/fcm_config.dart';
import 'package:nine_pm/utils/parse_json_data.dart';
import 'package:provider/provider.dart';
import 'chat_bloc.dart';
import 'chat_dto.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.bloc});

  static const routeName = '/chat';
  final ChatBloc bloc;

  @override
  State<StatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with BaseScreen<ChatScreen>, WidgetsBindingObserver {
  late ChatBloc bloc;

  ScrollController scrollController = ScrollController();

  TextEditingController textEditingController = TextEditingController();
  bool canSend = false;

  int receiverId = 0;
  String phoneNumberOfCrush = '';

  late double widthMessage;

  List<ChatItem> chatItems = [];

  late FcmBloc fcmBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    bloc = widget.bloc;

    textEditingController.addListener(updateCloseIconVisibility);

    subscriptions.add(bloc.getFetchDataChatSubject.listen(
      onGetFetchDataChat,
      onError: onHandleError,
    ));
  }

  @override
  void dispose() {
    fcmBloc.isShowNotification = true;
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    textEditingController.dispose();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      bloc.getFetchDataChat(receiverId);
    }
  }

  @override
  void onFirstRun(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      final item = args as dynamic;
      phoneNumberOfCrush = parseStr(item, 'phone_number_of_crush');
      if (phoneNumberOfCrush.length > 3) {
        phoneNumberOfCrush =
            phoneNumberOfCrush.substring(phoneNumberOfCrush.length - 3);
      }
      receiverId = parseInt(item, 'id');
    }

    widthMessage = MediaQuery.of(context).size.width * 2 / 3;

    bloc.getFetchDataChat(receiverId);

    subscriptions.add(bloc.getFetchDataChatSubject.listen(
      onGetFetchDataChat,
      onError: onHandleError,
    ));

    fcmBloc = Provider.of<FcmBloc>(context);
    fcmBloc.isShowNotification = false;
    subscriptions.add(fcmBloc.receiveMessageStreamController.listen(
      onReceiveMessage,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: Padding(
        padding: const EdgeInsets.only(top: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAppbar(),
            buildBody(),
            buildInput(),
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
          Center(
            child: Text(
              'Trò chuyện cùng ******$phoneNumberOfCrush',
              style: const TextStyle(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GroupedListView<ChatItem, String>(
          controller: scrollController,
          elements: chatItems,
          groupBy: (element) => element.startDate,
          order: GroupedListOrder.DESC,
          itemComparator: (item1, item2) => item1.id.compareTo(item2.id),
          reverse: true,
          groupSeparatorBuilder: (String value) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
          itemBuilder: (context, element) {
            if (element.type == TypeMessage.myMessage) {
              return myMessage(element);
            } else {
              return yourMessage(element);
            }
          },
        ),
      ),
    );
  }

  Widget myMessage(ChatItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: widthMessage,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF7C5AEC),
              ),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 16,
              ),
              margin: const EdgeInsets.only(bottom: 4),
              child: Text(item.message, textAlign: TextAlign.left),
            ),
            Positioned(
              bottom: 8,
              right: 6,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  '${item.startTime} ✓',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 8),
                ),
              ),
            ),
            Visibility(
              visible: item.status == 'SEEN',
              child: const Positioned(
                bottom: 8,
                right: 3,
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    '✓',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget yourMessage(ChatItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: widthMessage,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF3E3E40),
              ),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 16,
              ),
              margin: const EdgeInsets.only(bottom: 4),
              child: Text(
                item.message,
                textAlign: TextAlign.left,
              ),
            ),
            Positioned(
              bottom: 8,
              right: 6,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  item.startTime,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 8),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget buildInput() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: textEditingController,
                maxLength: 127,
                decoration: InputDecoration(
                  suffixIcon: Visibility(
                    visible: canSend,
                    child: InkWell(
                      onTap: onSend,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.send),
                      ),
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF3E3E40),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  counterText: '',
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: const TextStyle(color: Color(0x99EBEBF5)),
                ),
                style: const TextStyle(color: Color(0x99EBEBF5)),
                cursorColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onSend() {
    String message = textEditingController.text;
    textEditingController.clear();

    DateTime now = DateTime.now();
    String startDate = DateFormat('dd/MM/yyyy').format(now);
    String startTime = DateFormat('hh:mm').format(now);

    int id = 0;
    if (chatItems.isNotEmpty) {
      id = chatItems.last.id + 1;
    }

    var chatItem = ChatItem(
      id: id,
      type: TypeMessage.myMessage,
      status: 'SENT',
      message: message,
      startDate: startDate,
      startTime: startTime,
    );

    chatItems.add(chatItem);

    if (mounted) {
      setState(() {});

      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    bloc.sendMessage(receiverId, message);
  }

  void updateCloseIconVisibility() {
    setState(() {
      canSend = textEditingController.text.isNotEmpty;
    });
  }

  onGetFetchDataChat(List<ChatItem> items) {
    chatItems = items;
    if (mounted) {
      setState(() {});
    }
  }

  onReceiveMessage(RemoteMessage remoteMessage) {
    String type = parseStr(remoteMessage.data, 'type');
    switch (type) {
      case 'chat':
        parseChatData(remoteMessage);
        break;
      case 'seen':
        seenChatData();
        break;
      default:
        break;
    }
  }

  seenChatData() {
    for (var element in chatItems) {
      element.status = 'SEEN';
    }
    if (mounted) {
      setState(() {});
    }
  }

  parseChatData(RemoteMessage remoteMessage) {
    if (receiverId.toString() != parseStr(remoteMessage.data, 'sender_id')) {
      showFlutterNotification(remoteMessage);
      return;
    }

    bloc.seenMessage(parseStr(remoteMessage.data, 'id'));

    seenChatData();

    var chatItem = ChatItem.fromJsonOfFcm(
      remoteMessage.data,
      receiverId,
    );

    chatItems.add(chatItem);

    if (mounted) {
      setState(() {});
    }
  }
}
