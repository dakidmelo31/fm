// ignore_for_file: invalid_return_type_for_catch_error

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/animations/opacity_tween.dart';
import 'package:merchants/animations/slideup_tween.dart';
import 'package:merchants/pages/home_screen.dart';
import 'package:merchants/providers/global_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global.dart';

class LoginForm extends StatefulWidget {
  const LoginForm(
      {Key? key,
      required this.switchAnimation,
      required this.switchFunction,
      required this.loginFunction,
      required this.completedCallback,
      required this.completedAnimation})
      : super(key: key);
  final VoidCallback switchFunction, loginFunction, completedCallback;
  final Animation<double> switchAnimation, completedAnimation;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

FirebaseAuth auth = FirebaseAuth.instance;

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  OTP _formState = OTP.notSent;
  late PhoneAuthCredential credential;
  int seconds = 60;
  bool loading = false;
  String verificationCode = "", phoneNumber = "";
  TextEditingController _editingController = TextEditingController();

  bool hideResend = false;

  Future<void> verifyPhoneNumber() async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 70),
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(
          () {
            verificationCode = verificationId;
          },
        );
      },
      verificationCompleted: (PhoneAuthCredential credential) async {
        // ANDROID ONLY!
        // Sign the user in (or link) with the auto-generated credential
        debugPrint("received token");
        await auth.signInWithCredential(credential).then((value) async {
          final prefs = await SharedPreferences.getInstance();

          defaultSubscriptions();

          if (prefs.containsKey("phone")) {
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Home(index: 0),
                    transitionDuration: Duration(milliseconds: 2200),
                    transitionsBuilder:
                        (_, animation, anotherAnimation, child) {
                      animation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.fastLinearToSlowEaseIn,
                          reverseCurve: Curves.fastLinearToSlowEaseIn);
                      return Align(
                        alignment: Alignment.centerRight,
                        heightFactor: 0.0,
                        widthFactor: 0.0,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          axisAlignment: 1.0,
                          child: child,
                        ),
                      );
                    }));
          } else {
            prefs.setString("phone", phoneNumber);
            firestore
                .collection("restaurants")
                .doc(auth.currentUser!.uid)
                .get()
                .then((value) {
              if (value.data() != null) {
                prefs.setBool("account_created", true);

                Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 2800),
                      reverseTransitionDuration: Duration(milliseconds: 300),
                      transitionsBuilder:
                          (_, animation, anotherAnimation, child) {
                        animation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastLinearToSlowEaseIn);
                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          axisAlignment: 0.0,
                          child: child,
                        );
                      },
                      opaque: false,
                      pageBuilder: (context, animation, secondaryAnimation) {
                        animation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastLinearToSlowEaseIn);
                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          axisAlignment: 1.0,
                          child: Home(index: 0),
                        );
                      },
                    ));
              } else {
                prefs.setString("tmpNumber", phoneNumber);
                widget.switchFunction();
              }
            });
          }
        }).catchError((onError) =>
            {debugPrint("error saving user: ${onError.toString()}")});
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid. ${phoneNumber}');
        } else {
          debugPrint("there is another error: ${e.message}");
        }

        // Handle other errors
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Update the UI - wait for the user to enter the SMS code
        _formState = OTP.sent;

        setState(() {
          verificationCode = verificationId;
        });
        // Create a PhoneAuthCredential with the code
        // credential = PhoneAuthProvider.credential(
        //     verificationId: verificationId, smsCode: verificationCode);

        // Sign the user in (or link) with the credential
        // await auth.signInWithCredential(credential);

        // Create a PhoneAuthCredential with the code
        // PhoneAuthCredential credential = PhoneAuthProvider.credential(
        //     verificationId: verificationId, smsCode: verificationCode);

        // Sign the user in (or link) with the credential
        // await auth.signInWithCredential(credential);
      },
    );
    // auth.signInWithPhoneNumber(_editingController.text.toString());
  }

  int endTime = DateTime.now().millisecondsSinceEpoch +
      Duration(seconds: 60).inMilliseconds;

  late CountdownTimerController countdownTimerController;
  String v1 = "", v2 = "", v3 = "", v4 = "", v5 = "", v6 = "";
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    countdownTimerController = CountdownTimerController(
        endTime: endTime,
        onEnd: () {
          debugPrint("timer ended");
          countdownTimerController.disposeTimer();
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: widget.switchAnimation,
      builder: (_, child) {
        return SafeArea(
          child: Opacity(
            opacity: widget.switchAnimation.value,
            child: Container(
              width: size.width,
              height: size.height,
              color: Colors.white,
              child: Stack(
                children: [
                  Positioned(left: 0, top: 0, height: 60, child: Text("")),
                  if (widget.switchAnimation.value >= .9)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      width: size.width,
                      height: size.height - 100,
                      child: Column(
                        children: [
                          OpacityTween(
                            child: Text(
                              "Let's verify right away.",
                            ),
                          ),
                          AnimatedSwitcher(
                              duration: Duration(milliseconds: 1300),
                              reverseDuration: Duration(milliseconds: 1300),
                              child: _formState == OTP.notSent
                                  ? Lottie.asset(
                                      "assets/verify-id.json",
                                      // width: 250,
                                      height: size.height * .2,
                                      reverse: true,
                                      options:
                                          LottieOptions(enableMergePaths: true),
                                      alignment: Alignment.center,
                                      fit: BoxFit.contain,
                                    )
                                  : TweenAnimationBuilder(
                                      curve: Curves.fastLinearToSlowEaseIn,
                                      tween:
                                          Tween<double>(begin: 0.0, end: 1.0),
                                      duration: Duration(milliseconds: 700),
                                      builder: (_, double value, child) {
                                        return Opacity(
                                            opacity: value, child: child);
                                      },
                                      child: ClipOval(
                                        child: Lottie.asset(
                                          "assets/2fauth.json",
                                          width: 250,
                                          height: 250,
                                          alignment: Alignment.center,
                                          animate: true,
                                          options: LottieOptions(
                                              enableMergePaths: true),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )),
                          if (_formState == OTP.notSent)
                            OpacityTween(
                              child: SlideUpTween(
                                begin: Offset(120, 0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 35.0),
                                  child: Material(
                                    elevation: 15,
                                    shadowColor: Colors.grey.withOpacity(.2),
                                    child: IntlPhoneField(
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.done,
                                      controller: _editingController,
                                      autofocus: true,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 3, horizontal: 15),
                                        labelText: 'Phone Number',
                                        border: InputBorder.none,
                                      ),
                                      initialCountryCode: 'CM',
                                      onChanged: (phone) {
                                        phoneNumber = phone.completeNumber;
                                        // print(phone.completeNumber);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_formState == OTP.sent)
                            TweenAnimationBuilder(
                              curve: Curves.fastLinearToSlowEaseIn,
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 600),
                              builder: (_, double value, child) {
                                return Opacity(opacity: value, child: child);
                              },
                              child: OpacityTween(
                                child: SlideUpTween(
                                  begin: Offset(100, 10),
                                  child: Container(
                                    width: size.width,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 10,
                                          color: Colors.grey.withOpacity(.2),
                                          offset: Offset(
                                            5,
                                            15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              height: 68,
                                              width: 35,
                                              child: TextFormField(
                                                onSaved: ((newValue) {}),
                                                onChanged: (val) {
                                                  if (val.length == 1) {
                                                    v1 = val;
                                                    FocusScope.of(context)
                                                        .nextFocus();
                                                  }
                                                },
                                                style: TextStyle(
                                                    color: Colors.deepPurple),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      1),
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 68,
                                              width: 35,
                                              child: TextFormField(
                                                onSaved: ((newValue) {}),
                                                onChanged: (val) {
                                                  if (val.length == 1) {
                                                    v2 = val;
                                                    FocusScope.of(context)
                                                        .nextFocus();
                                                  }
                                                },
                                                style: TextStyle(
                                                    color: Colors.deepPurple),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      1),
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 68,
                                              width: 35,
                                              child: TextFormField(
                                                onSaved: ((newValue) {}),
                                                onChanged: (val) {
                                                  if (val.length == 1) {
                                                    v3 = val;
                                                    FocusScope.of(context)
                                                        .nextFocus();
                                                  }
                                                },
                                                style: TextStyle(
                                                    color: Colors.deepPurple),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      1),
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 68,
                                              width: 35,
                                              child: TextFormField(
                                                onSaved: ((newValue) {}),
                                                onChanged: (val) {
                                                  if (val.length == 1) {
                                                    v4 = val;
                                                    FocusScope.of(context)
                                                        .nextFocus();
                                                  }
                                                },
                                                style: TextStyle(
                                                    color: Colors.deepPurple),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      1),
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 68,
                                              width: 35,
                                              child: TextFormField(
                                                onSaved: ((newValue) {}),
                                                onChanged: (val) {
                                                  if (val.length == 1) {
                                                    v5 = val;
                                                    FocusScope.of(context)
                                                        .nextFocus();
                                                  }
                                                },
                                                style: TextStyle(
                                                    color: Colors.deepPurple),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      1),
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 68,
                                              width: 35,
                                              child: TextFormField(
                                                onSaved: ((newValue) {}),
                                                onChanged: (val) {
                                                  if (val.length == 1) {
                                                    v6 = val;

                                                    FocusScope.of(context)
                                                        .nextFocus();
                                                  }
                                                },
                                                style: TextStyle(
                                                    color: Colors.deepPurple),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      1),
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_formState == OTP.sent)
                            SizedBox(
                              height: 60,
                              child: Center(
                                child: CountdownTimer(
                                  endTime: 170,
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                  onEnd: () {
                                    debugPrint("countdown has ended");
                                    setState(() {
                                      endTime =
                                          Duration(seconds: 60).inMilliseconds;
                                      hideResend = !hideResend;
                                    });
                                  },
                                  widgetBuilder:
                                      (_, CurrentRemainingTime? time) {
                                    if (time == null) {
                                      return TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _formState = OTP.notSent;
                                          });
                                        },
                                        child: Text("Resend Code"),
                                      );
                                    }
                                    seconds = (time.min == null
                                            ? 0
                                            : time.min! * 60) +
                                        (time.sec == null ? 0 : time.sec!);
                                    return Text(
                                      "${seconds}s till next retry is available",
                                      style: TextStyle(color: Colors.grey),
                                    );
                                  },
                                  controller: countdownTimerController,
                                ),
                              ),
                            ),
                          Spacer(),
                          SlideUpTween(
                            begin: Offset(-50, 0),
                            child: _formState == OTP.notSent
                                ? Card(
                                    color: Colors.lightGreen,
                                    elevation: 15,
                                    shadowColor: Colors.grey.withOpacity(.2),
                                    child: InkWell(
                                      onTap: () async {
                                        HapticFeedback.heavyImpact();
                                        Fluttertoast.showToast(
                                          msg: "Sending OTP please wait...",
                                          backgroundColor: Colors.lightGreen,
                                          fontSize: 14.0,
                                          textColor: Colors.white,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                        );

                                        countdownTimerController.start();

                                        verifyPhoneNumber();
                                      },
                                      child: SizedBox(
                                        width: size.width - 80,
                                        height: 60,
                                        child: Center(
                                          child: Text(
                                            "Signup Now",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : CupertinoButton(
                                    child: Text("Verify Number"),
                                    onPressed: () async {
                                      Fluttertoast.showToast(
                                        msg: "Setup the rest of your account.",
                                      );
                                      debugPrint(
                                          "verify otp code $v1$v2$v3$v4$v5$v6");
                                      auth
                                          .signInWithCredential(
                                        PhoneAuthProvider.credential(
                                          verificationId: verificationCode,
                                          smsCode: "$v1$v2$v3$v4$v5$v6",
                                        ),
                                      )
                                          .then(
                                        (value) async {
                                          defaultSubscriptions();

                                          final prefs = await SharedPreferences
                                              .getInstance();

                                          if (prefs.containsKey("phone")) {
                                            Navigator.pushReplacement(
                                                context,
                                                PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) =>
                                                        Home(),
                                                    transitionDuration:
                                                        Duration(
                                                            milliseconds: 2200),
                                                    transitionsBuilder: (_,
                                                        animation,
                                                        anotherAnimation,
                                                        child) {
                                                      animation = CurvedAnimation(
                                                          parent: animation,
                                                          curve: Curves
                                                              .fastLinearToSlowEaseIn,
                                                          reverseCurve: Curves
                                                              .fastLinearToSlowEaseIn);
                                                      return Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        heightFactor: 0.0,
                                                        widthFactor: 0.0,
                                                        child: SizeTransition(
                                                          sizeFactor: animation,
                                                          axis: Axis.horizontal,
                                                          axisAlignment: 1.0,
                                                          child: child,
                                                        ),
                                                      );
                                                    }));
                                          } else {
                                            prefs.setString(
                                                "phone", phoneNumber);
                                            firestore
                                                .collection("restaurants")
                                                .doc(auth.currentUser!.uid)
                                                .get()
                                                .then((value) {
                                              if (value.data() != null) {
                                                prefs.setBool(
                                                    "account_created", true);

                                                Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      transitionDuration:
                                                          Duration(
                                                              milliseconds:
                                                                  2800),
                                                      reverseTransitionDuration:
                                                          Duration(
                                                              milliseconds:
                                                                  300),
                                                      transitionsBuilder: (_,
                                                          animation,
                                                          anotherAnimation,
                                                          child) {
                                                        animation = CurvedAnimation(
                                                            parent: animation,
                                                            curve: Curves
                                                                .fastLinearToSlowEaseIn);
                                                        return SizeTransition(
                                                          sizeFactor: animation,
                                                          axis: Axis.horizontal,
                                                          axisAlignment: 0.0,
                                                          child: child,
                                                        );
                                                      },
                                                      opaque: false,
                                                      pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) {
                                                        animation = CurvedAnimation(
                                                            parent: animation,
                                                            curve: Curves
                                                                .fastLinearToSlowEaseIn);
                                                        return SizeTransition(
                                                          sizeFactor: animation,
                                                          axis: Axis.horizontal,
                                                          axisAlignment: 1.0,
                                                          child: Home(),
                                                        );
                                                      },
                                                    ));
                                              } else {
                                                prefs.setString(
                                                    "tmpNumber", phoneNumber);
                                                widget.switchFunction();
                                              }
                                            });
                                          }
                                        },
                                      ).catchError((onError) {
                                        Fluttertoast.showToast(
                                          msg: "Wrong OTP code, check well",
                                          backgroundColor: Colors.lightGreen,
                                          fontSize: 14.0,
                                          textColor: Colors.white,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.TOP,
                                        );
                                      });
                                    }),
                          ),
                          Spacer(
                            flex: 2,
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      },
      child: Text(""),
    );
  }
}

enum OTP { sent, retry, notSent }
