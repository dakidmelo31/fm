import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:merchants/firebase_options.dart';
import 'package:merchants/pages/SimplePage.dart';
import 'package:merchants/pages/home_screen.dart';
import 'package:merchants/pages/signup_screen.dart';
import 'package:merchants/pages/startup_screen.dart';
import 'package:merchants/providers/auth_provider.dart';
import 'package:merchants/providers/firestore_api.dart';
import 'package:merchants/providers/meals.dart';
import 'package:merchants/providers/notification_service.dart';
import 'package:merchants/providers/orders_data.dart';
import 'package:merchants/providers/restaurant_provider.dart';
import 'package:merchants/providers/reviews.dart';
import 'package:merchants/providers/services.dart';
import 'package:provider/provider.dart';

late AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

// flutter local notification
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  NotificationService().initNotification();
  runApp(
    InAppNotification(
      child: ChangeNotifierProvider(
        create: (BuildContext context) => Auth(),
        child: ChangeNotifierProvider(
            create: (BuildContext context) => MealsData(),
            child: const AppHome()),
      ),
    ),
  );
}

FirebaseAuth auth = FirebaseAuth.instance;

class AppHome extends StatelessWidget {
  const AppHome({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    // SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.immersive,
    // );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServicesData()),
        ChangeNotifierProvider(create: (_) => Meals()),
        ChangeNotifierProvider(create: (_) => FirestoreApi()),
        ChangeNotifierProvider(create: (_) => MealsData()),
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProvider(create: (_) => OrdersData()),
        ChangeNotifierProvider(create: (_) => ReviewProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Foodin Merchant",
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.lightGreen,
            type: BottomNavigationBarType.shifting,
            enableFeedback: true,
          ),
        ),
        routes: {
          StartupScreen.routeName: (context) => const StartupScreen(),
          SimplePage.routeName: (context) => const SimplePage(),
          CreateAccount.routeName: (context) => CreateAccount(),
          Home.routeName: (context) => Home(),
        },
      ),
    );
  }
}
