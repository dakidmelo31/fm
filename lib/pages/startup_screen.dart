import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:merchants/pages/complete_signup.dart';
import 'package:merchants/providers/auth_provider.dart';
import 'package:merchants/widgets/choose_option.dart';
import 'package:merchants/widgets/login_form.dart';
import 'package:merchants/widgets/top_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

FirebaseAuth tmpAuth = FirebaseAuth.instance;

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
      _onlineController,
      _completedController;

  _checkUser() async {
    if (auth.currentUser != null) {
      debugPrint("current user is not null");
      final prefs = await SharedPreferences.getInstance();

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
    _checkUser();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 2,
      ),
    );
    _onlineController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 600,
      ),
    );

    _onlineController.addListener(() {
      debugPrint(_onlineController.value.toString());
      if (_onlineController.isCompleted) {
        debugPrint("completed animation");
        Future.delayed(Duration(seconds: 5), () {
          _onlineController.reverse();
        });
      }
    });

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
    _connectivityStream = Connectivity().onConnectivityChanged;
    super.initState();
  }

  late Stream<ConnectivityResult> _connectivityStream;

  @override
  Widget build(BuildContext context) {
    debugPrint(_formType.toString());

    final _userData = Provider.of<Auth>(context);
    Size size = MediaQuery.of(context).size;
    _animationController.forward();
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/splash_bg.png",
            ),
            filterQuality: FilterQuality.high,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.black.withOpacity(.83),
              Colors.black.withOpacity(.47),
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
                StreamBuilder<ConnectivityResult>(
                    stream: _connectivityStream,
                    builder:
                        (context, AsyncSnapshot<ConnectivityResult> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox.shrink();
                      }
                      if (snapshot.requireData == ConnectivityResult.mobile) {
                        double value = 20.0;
                        _onlineController.forward();
                        return AnimatedBuilder(
                            animation: _onlineController,
                            builder: (context, child) {
                              Animation<double> animation = CurvedAnimation(
                                  parent: _onlineController,
                                  curve: Curves.fastLinearToSlowEaseIn);
                              return Align(
                                alignment: Alignment.topCenter,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1000),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  color: Colors.green,
                                  child: Center(
                                      child: Text(
                                    "Online",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  )),
                                  height: value * animation.value,
                                  width: size.width,
                                ),
                              );
                            });
                      }

                      if (snapshot.requireData == ConnectivityResult.wifi) {
                        double value = 20.0;
                        _onlineController.forward();
                        return AnimatedBuilder(
                            animation: _onlineController,
                            builder: (context, child) {
                              Animation<double> animation = CurvedAnimation(
                                  parent: _onlineController,
                                  curve: Curves.fastLinearToSlowEaseIn);
                              return Align(
                                alignment: Alignment.topCenter,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1000),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  color: Colors.blue,
                                  child: Center(
                                      child: Text(
                                    "Using Wifi",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  )),
                                  height: value * animation.value,
                                  width: size.width,
                                ),
                              );
                            });
                      }

                      if (snapshot.requireData == ConnectivityResult.none) {
                        double value = 20.0;
                        return AnimatedBuilder(
                            animation: _onlineController,
                            builder: (context, child) {
                              Animation<double> animation = CurvedAnimation(
                                  parent: _onlineController,
                                  curve: Curves.fastLinearToSlowEaseIn);
                              return Align(
                                alignment: Alignment.topCenter,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1000),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  color: Colors.red,
                                  child: Center(
                                      child: Text(
                                    "Offline",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  )),
                                  height: value,
                                  width: size.width,
                                ),
                              );
                            });
                      }

                      return SizedBox.shrink();
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum FormType { login, signup, none, complete }
