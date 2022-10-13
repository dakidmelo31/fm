import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchants/providers/auth_provider.dart';
import 'package:merchants/providers/firestore_api.dart';
import 'package:merchants/providers/meals.dart';
import 'package:merchants/providers/orders_data.dart';
import 'package:merchants/providers/restaurant_provider.dart';
import 'package:merchants/providers/reviews.dart';
import 'package:merchants/providers/services.dart';
import 'package:provider/provider.dart';

import 'global.dart';
import 'pages/home_screen.dart';
import 'pages/signup_screen.dart';
import 'pages/startup_screen.dart';

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
        navigatorKey: navigatorKey,
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
          CreateAccount.routeName: (context) => CreateAccount(),
          Home.routeName: (context) => Home(),
        },
      ),
    );
  }
}
