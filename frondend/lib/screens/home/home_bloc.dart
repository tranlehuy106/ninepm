import 'package:nine_pm/utils/parse_json_data.dart';
import 'package:rxdart/rxdart.dart';

import 'home_dto.dart';
import 'home_service.dart';

class HomeBloc {
  HomeBloc({required this.service});

  final HomeService service;

  final getListCrushSubject = PublishSubject<void>();
  final getListLoverSubject = PublishSubject<void>();

  bool _waitingGetListCrushResponse = false;
  bool _waitingGetListLoverResponse = false;

  List<HomeCrushItem> homeCrushList = [];
  List<HomeLoverItem> homeLoverList = [];
  List<ChatLoverItem> chatLoverList = [];

  void dispose() {
    getListCrushSubject.close();
    getListLoverSubject.close();
  }

  Future<void> getListCrush() async {
    if (_waitingGetListCrushResponse) {
      return;
    }
    _waitingGetListCrushResponse = true;
    try {
      final response = await service.getListCrush();
      _waitingGetListCrushResponse = false;

      if (getListCrushSubject.isClosed) {
        return;
      }

      homeCrushList = [];
      var crushes = parseList(response, 'crushes');
      for (final item in crushes) {
        homeCrushList.add(HomeCrushItem.fromJson(item));
      }

      homeLoverList = [];
      var lovers = parseList(response, 'lovers');
      for (final item in lovers) {
        homeLoverList.add(HomeLoverItem.fromJson(item));
      }

      getListCrushSubject.add(null);
    } on Exception catch (exception) {
      _waitingGetListCrushResponse = false;
      if (getListCrushSubject.isClosed) {
        return;
      }
      getListCrushSubject.addError(exception);
      return;
    }
  }

  Future<void> getListLover() async {
    if (_waitingGetListLoverResponse) {
      return;
    }
    _waitingGetListLoverResponse = true;
    try {
      final response = await service.getListLover();
      _waitingGetListLoverResponse = false;

      if (getListLoverSubject.isClosed) {
        return;
      }

      chatLoverList = [];
      var items = parseList(response, 'items');
      for (final item in items) {
        chatLoverList.add(ChatLoverItem.fromJson(item));
      }

      getListLoverSubject.add(null);
    } on Exception catch (exception) {
      _waitingGetListLoverResponse = false;
      if (getListLoverSubject.isClosed) {
        return;
      }
      getListLoverSubject.addError(exception);
      return;
    }
  }
}
