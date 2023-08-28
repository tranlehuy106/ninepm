import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nine_pm/routes.dart';
import 'package:nine_pm/settings/environment_settings.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:uuid/uuid.dart';

import 'common/bases/base_http_clients.dart';
import 'common/fcm/fcm_bloc.dart';
import 'common/fcm/fcm_service.dart';
import 'common/theme.dart';
import 'fcm_config.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: EnvironmentSettings.firebaseOptions);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String initialRoute = SplashScreen.routeName;
  final NinePmHttpClient httpClient = NinePmHttpClient();
  late Routes routes;
  late List<SingleChildWidget> providers;

  late FcmBloc fcmBloc;
  bool preloading = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    routes = Routes(httpClient: httpClient);

    fcmBloc = FcmBloc(fcmService: FcmService(httpClient: httpClient));

    preload();

    providers = [
      Provider<NinePmHttpClient>.value(value: httpClient),
      Provider<FcmBloc>.value(value: fcmBloc),
    ];
  }

  @override
  void dispose() {
    fcmBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (preloading) {
      return const SizedBox();
    }

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        navigatorObservers: const [],
        themeMode: ThemeMode.system,
        theme: NinepmTheme.themeData,
        darkTheme: ThemeData.dark(),
        initialRoute: initialRoute,
        routes: routes.routes,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }

  Future<void> preload() async {
    const storage = FlutterSecureStorage();
    httpClient.authTokenValue = await storage.read(key: 'ninepm_auth_token');
    httpClient.deviceTokenValue =
        await storage.read(key: 'ninepm_device_token');

    if (httpClient.getDeviceTokenValue == null) {
      var uuid = const Uuid();
      httpClient.deviceTokenValue = uuid.v4();
      await storage.write(
        key: 'ninepm_device_token',
        value: httpClient.getDeviceTokenValue,
      );
    }

    fcmBloc.init();

    if (mounted) {
      setState(() {
        preloading = false;
      });
    }
  }
}
