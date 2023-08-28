import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class EnvironmentSettings {
  static String apiBaseUrl = 'http://huy.ninepm.me/api';

  static String authTokenHeader = "ninepm";
  static String clientVersionHeader = "ninepm-client";
  static String deviceTokenHeaderName = 'ninepm-device-token';

  static const resendOTPIntervalInSeconds = 120;

  static const FirebaseOptions _firebaseOptionAndroid = FirebaseOptions(
      apiKey: 'AIzaSyDDtqsWcoieiWPlzzfUEq_ruDezHrCq-LY',
      appId: '1:361778880647:android:2b1ff1763ef6767a515822',
      messagingSenderId: '361778880647',
      projectId: 'ninepm-4f426',
      storageBucket: 'ninepm-4f426.appspot.com',
      androidClientId: '361778880647-hvmu53gmroscnvo3o9nddt98ah338dhh.apps.googleusercontent.com');

  static const FirebaseOptions _firebaseOptionIOS = FirebaseOptions(
    apiKey: 'AIzaSyB1Nk7obD5p635_hJMGNuEAT0r0qXq1eBg',
    appId: '1:361778880647:ios:5153da9a69b43973515822',
    messagingSenderId: '361778880647',
    projectId: 'ninepm-4f426',
    storageBucket: 'ninepm-4f426.appspot.com',
    iosClientId: '361778880647-b4mfrqqj1pf81h829q9shhqrimjv8p1b.apps.googleusercontent.com',
    iosBundleId: 'com.ninepm.ninePm',
  );

  static FirebaseOptions? get firebaseOptions {
    if (kIsWeb) {
      return null;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _firebaseOptionAndroid;
      case TargetPlatform.iOS:
        return _firebaseOptionIOS;

      default:
        return null;
    }
  }
}
