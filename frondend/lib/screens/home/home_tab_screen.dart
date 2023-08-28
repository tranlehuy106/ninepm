import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nine_pm/common/bases/base_screen.dart';
import 'package:nine_pm/screens/send_love_messages/send_love_messages_screen.dart';

import 'home_bloc.dart';
import 'home_dto.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key, required this.bloc});

  final HomeBloc bloc;

  @override
  State<StatefulWidget> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen>
    with BaseScreen<HomeTabScreen> {
  static const ninePmPath = 'assets/home/9pm.svg';
  static const addPath = 'assets/home/add.svg';

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
    subscriptions.add(bloc.getListCrushSubject.listen(
      (_) => onGetListCrush(context),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAppbar(),
          const SizedBox(height: 32),
          buildBody(),
        ],
      ),
    );
  }

  Widget buildAppbar() {
    return Center(
      child: SvgPicture.asset(
        ninePmPath,
        width: 234,
        height: 64,
      ),
    );
  }

  Widget buildBody() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Tin nhắn đã được gửi đi, nếu người kia cũng download 9PM và chọn bạn?'),
                const SizedBox(height: 16),
                buildText(
                  'Yes',
                  const Color(0xFF00BA00),
                  '9PM sẽ kết nối 2 bạn với nhau. Cả 2 bạn sẽ nhận được tin nhắn chúc mừng vào lúc 9PM tối nay.',
                ),
                buildText(
                  'No',
                  const Color(0xFFFF2D55),
                  'Ngược lại, sẽ không có chuyện gì xảy ra cả. ',
                ),
                const SizedBox(height: 13),
                const Text('Chúc bạn may mắn và hẹn bạn vào 9:00 PM.'),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFF141414),
            thickness: 8,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Danh sách “crush”',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      await Navigator.of(context).pushNamed(
                        SendLoveMessagesScreen.routeName,
                      );
                      bloc.getListCrush();
                    },
                    icon: SvgPicture.asset(
                      addPath,
                      width: 28,
                      height: 28,
                    ))
              ],
            ),
          ),
          const SizedBox(height: 12),
          buildItems(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget buildText(String label, Color color, String text) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF3E3E40),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          margin: const EdgeInsets.only(bottom: 3, top: 10),
          width: double.infinity,
          child: Text(text),
        ),
        Positioned(
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: color,
            ),
            width: 40,
            height: 20,
            child: Center(
                child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )),
          ),
        )
      ],
    );
  }

  Widget buildItems() {
    return Expanded(
      child: ListView.builder(
        itemCount: bloc.homeCrushList.length,
        itemBuilder: (BuildContext context, int index) {
          return buildItem(bloc.homeCrushList[index]);
        },
      ),
    );
  }

  Widget buildItem(HomeCrushItem crush) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      margin: const EdgeInsets.only(bottom: 12.0),
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF38383A),
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text('****** ${crush.phoneNumberOfCrush}')),
            Text(
              crush.startAt,
              style: const TextStyle(fontSize: 14, color: Color(0x99EBEBF5)),
            ),
          ],
        ),
      ),
    );
  }

  onGetListCrush(BuildContext context) async {
    if (mounted) {
      setState(() {});
    }
  }
}
