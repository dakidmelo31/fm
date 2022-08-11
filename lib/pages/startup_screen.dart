import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:merchants/models/overview.dart';
import 'package:merchants/pages/all_messages.dart';
import 'package:merchants/pages/complete_signup.dart';
import 'package:merchants/pages/order_details.dart';
import 'package:merchants/providers/auth_provider.dart';
import 'package:merchants/providers/orders_data.dart';
import 'package:merchants/widgets/choose_option.dart';
import 'package:merchants/widgets/login_form.dart';
import 'package:merchants/widgets/top_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/customer.dart';
import '../models/restaurants.dart';
import 'home_screen.dart';

FirebaseAuth tmpAuth = FirebaseAuth.instance;
// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String? token) {
  _messageCount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}

class StartupScreen extends StatefulWidget {
  static const routeName = "/";
  const StartupScreen({Key? key}) : super(key: key);

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with TickerProviderStateMixin {
  FirebaseAuth auth = FirebaseAuth.instance;

  FormType _formType = FormType.none;
  late Animation<double> _mainAnimation, _switchAnimation, _completedAnimation;
  late AnimationController _animationController,
      _switchController,
      _completedController;
  bool? pushNotif;
  _checkUser() async {
    // FirebaseMessaging.instance.getInitialMessage().then((value) {});
    final prefs = await SharedPreferences.getInstance();

    Future.delayed(Duration.zero, () {
      if (auth.currentUser != null || pushNotif == null) {
        debugPrint(pushNotif.toString());
        debugPrint("current user is not null");

        if (prefs.containsKey("phone")) {
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacementNamed(context, Home.routeName);
          });
        } else {
          auth.signOut();
          prefs.clear();
          Navigator.pushReplacementNamed(context, StartupScreen.routeName);
        }
      } else {
        debugPrint("user is not logged in");
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _switchController.dispose();
    _completedController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 2,
      ),
    );

    _switchController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 1500,
      ),
    );
    _completedController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 3500,
      ),
    );

    _mainAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    );
    _switchAnimation = CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeInCirc,
    );
    _completedAnimation = CurvedAnimation(
      parent: _completedController,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FirebaseMessaging.instance.getInitialMessage().then((value) {
        if (value != null) {
          pushNotif = true;
          debugPrint("Push Notification from terminated app");
          debugPrint(value.data.toString());
          String userId = value.data["userId"];

          debugPrint("Chat Message recieved");
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: ((context, animation, secondaryAnimation) {
                animation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastLinearToSlowEaseIn,
                );
                return ScaleTransition(
                    scale: animation,
                    child: AllMessages(
                        fromPush: true,
                        customerId: value.data["userId"].toString(),
                        chatsStream: FirebaseFirestore.instance
                            .collection("messages")
                            .where("userId", isEqualTo: userId)
                            .where("restaurantId",
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .orderBy("lastMessageTime", descending: false)
                            .snapshots(),
                        ordersStream: FirebaseFirestore.instance
                            .collection("orders")
                            .where("userId", isEqualTo: userId)
                            .where("restaurantId",
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .orderBy("time", descending: true)
                            .snapshots()));
              }),
            ),
          );
        } else {
          _checkUser();
          debugPrint("App opened normally");
        }
        // From Terminated App

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          RemoteNotification? notification = message.notification;
          AndroidNotification? android = message.notification?.android;
          if (notification != null && android != null && !kIsWeb) {
            flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  icon: 'ic_launcher',
                ),
              ),
            );
          }
        });
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('A new onMessageOpenedApp event was published!');
          pushNotif = true;

          debugPrint("Push Message recieved");
          var data = message.data;
          debugPrint(data.toString());
          String userId = message.data["userId"];

          if (value != null) {
            pushNotif = true;
            debugPrint("Push Notification from terminated app");
            debugPrint(value.data.toString());
            String userId = value.data["userId"];

            debugPrint("Chat Message recieved");
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: ((context, animation, secondaryAnimation) {
                  animation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastLinearToSlowEaseIn,
                  );
                  return ScaleTransition(
                      scale: animation,
                      child: AllMessages(
                          fromPush: true,
                          customerId: value.data["userId"].toString(),
                          chatsStream: FirebaseFirestore.instance
                              .collection("messages")
                              .where("userId", isEqualTo: userId)
                              .where("restaurantId",
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .orderBy("lastMessageTime", descending: false)
                              .snapshots(),
                          ordersStream: FirebaseFirestore.instance
                              .collection("orders")
                              .where("userId", isEqualTo: userId)
                              .where("restaurantId",
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .orderBy("time", descending: true)
                              .snapshots()));
                }),
              ),
            );
          } else {
            _checkUser();
            debugPrint("App opened normally");
          }

          debugPrint(message.data.toString());

          debugPrint("Push Notification from terminated app");
          debugPrint(message.notification.toString());
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(_formType.toString());

    Size size = MediaQuery.of(context).size;
    _animationController.forward();
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/logo/splash_bg.png",
            ),
            filterQuality: FilterQuality.high,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.transparent,
              // Colors.black,
              // Colors.black.withOpacity(.83),
              // Colors.black.withOpacity(.47),
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: WillPopScope(
            onWillPop: () async => false,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                TopInfo(mainAnimation: _mainAnimation),
                ChooseOption(
                    mainAnimation: _mainAnimation,
                    switchAnimation: CurvedAnimation(
                        parent: _switchAnimation,
                        curve: Interval(
                          0.0,
                          0.8,
                        )),
                    onAnimationStarted: () {
                      setState(() {
                        _formType = FormType.login;
                        _switchController.forward();
                      });
                    }),
                if (_formType == FormType.login)
                  LoginForm(
                    loginFunction: () {
                      setState(() {
                        _formType = FormType.login;
                      });
                    },
                    completedAnimation: _completedAnimation,
                    completedCallback: () {
                      setState(() {
                        _formType = FormType.complete;
                        _completedController.forward();
                        _switchController
                            .reverse()
                            .then((value) => _animationController.reverse());
                      });
                    },
                    switchAnimation: CurvedAnimation(
                        parent: _switchAnimation,
                        curve: Interval(.7, 1.0, curve: Curves.decelerate)),
                    switchFunction: () {
                      setState(() {
                        _switchController.reverse();
                        _completedController.forward();
                        _formType = FormType.complete;
                      });
                    },
                  ),
                if (_formType == FormType.complete)
                  CompleteProfile(
                      completedAnimation: _completedAnimation,
                      completedCallback: () {
                        _completedController.forward();
                        _switchController
                            .reverse()
                            .then((value) => _animationController.reverse());
                      },
                      reverseAnimation: () {
                        _completedController.reverse();
                      }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum FormType { login, signup, none, complete }
