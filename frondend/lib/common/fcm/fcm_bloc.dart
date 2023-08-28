import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:nine_pm/fcm_config.dart';
import 'package:rxdart/rxdart.dart';

import 'fcm_service.dart';

class FcmBloc {
  FcmBloc({required this.fcmService});

  final FcmService fcmService;

  final interactiveMessageStreamController = PublishSubject<RemoteMessage>();
  final receiveMessageStreamController = PublishSubject<RemoteMessage>();

  bool _isShowNotification = true;

  set isShowNotification(bool value) {
    _isShowNotification = value;
  }

  void init() async {
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return;
    }

    if (token != null) {
      await fcmService.registerFcmToken(token);
    }

    if (kDebugMode) {
      print(token);
    }

    handleTerminatedMessaging();
    askNotificationPermission();
    onForegroundMessaging();
    onMessageOpenedApp();
  }

  void dispose() {
    interactiveMessageStreamController.close();
    receiveMessageStreamController.close();
  }

  ///on iOS a native modal will be displayed
  Future<void> askNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }

  void onForegroundMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (_isShowNotification) {
        showFlutterNotification(message);
      }
      if (kDebugMode) {
        print('Handling a foreground message: ${message.messageId}');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');
        print('Message notification: ${message.notification?.body}');
      }
      receiveMessageStreamController.add(message);
    });
  }

  ///Tab notification background and foreground
  void onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
            'A new onMessageOpenedApp event was published!: ${message.messageId}');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');
        print('Message notification: ${message.notification?.body}');
      }
      interactiveMessageStreamController.add(message);
    });
  }

  void handleTerminatedMessaging() {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (kDebugMode) {
        print('A new getInitialMessage event was published!: ${message ?? ""}');
        if (message != null) {
          print('Message data: ${message.data}');
          print('Message notification: ${message.notification?.title}');
          print('Message notification: ${message.notification?.body}');
        }
      }
      if (message != null) {
        interactiveMessageStreamController.add(message);
      }
    });
  }
}
