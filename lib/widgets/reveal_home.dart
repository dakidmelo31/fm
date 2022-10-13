// ignore_for_file: must_be_immutable, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/global.dart';
import 'package:merchants/pages/conversation_screen.dart';
import 'package:merchants/pages/home_screen.dart';
import 'package:merchants/pages/startup_screen.dart';
import 'package:merchants/providers/auth_provider.dart';
import 'package:merchants/transitions/transitions.dart';
import 'package:merchants/widgets/main_screen.dart';
import 'package:merchants/widgets/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

import '../models/restaurants.dart';

class RevealWidget extends StatefulWidget {
  RevealWidget({Key? key, required this.index}) : super(key: key);
  int? index;
  static const routeName = "/load_restaurant";

  @override
  State<RevealWidget> createState() => _RevealWidgetState();
}

class _RevealWidgetState extends State<RevealWidget> {
  late PageController _pageController;
  int _index = 0;

  _checkUser() async {
    if (auth.currentUser == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, StartupScreen.routeName);
      });

      debugPrint("user is not logged in");
    }
  }

  late var messageOverviewStream;
  bool showNotificationIcon = false;

  @override
  void initState() {
    if (widget.index != null) {
      _index = widget.index!;
    }
    _checkUser();
    _pageController = PageController(initialPage: _index);

    super.initState();

    messageOverviewStream = FirebaseFirestore.instance
        .collection("overviews")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("chats")
        .snapshots();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _userData = Provider.of<Auth>(context, listen: true);
    final Restaurant restaurant = _userData.restaurant;
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (_index != 0) {
          setState(() {
            _index == 0;
            _pageController.animateToPage(_index,
                duration: Duration(milliseconds: 700),
                curve: Curves.fastLinearToSlowEaseIn);
          });
          return false;
        }
        return true;
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          animation = CurvedAnimation(
              parent: animation, curve: Curves.fastLinearToSlowEaseIn);

          return SizeTransition(
            sizeFactor: animation,
            child: child,
            axis: Axis.horizontal,
            axisAlignment: 0.0,
          );
        },
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("restaurants")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (_, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Lottie.asset(
                "assets/loading-animation.json",
                width: size.width - 70,
                height: size.width - 70,
                alignment: Alignment.center,
                fit: BoxFit.contain,
                options: LottieOptions(enableMergePaths: true),
                reverse: true,
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }
            var event = snapshot.data;
            // int doubleCost = int.parse("${event["deliveryCost"]}");
            // int cost = doubleCost.toInt();
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return Container(
            //     width: size.width,
            //     height: size.height,
            //     color: Colors.white,
            //     child: Center(
            //       child: Lottie.asset("assets/loading5.json"),
            //     ),
            //   );
            // }
            Restaurant restaurant = Restaurant(
              gallery: List<String>.from(event["gallery"]),
              name: event["name"] ?? "",
              variants: List<String>.from(event["variants"]),
              days: List<String>.from(event["days"]),
              costs: List<int>.from(event["costs"]),
              deviceToken: event["deviceToken"],
              address: event["address"] ?? "",
              companyName: event["companyName"] ?? "",
              businessPhoto: event["businessPhoto"] ?? "",
              tableReservation: event["tableReservation"] ?? "",
              closingTime: event["closingTime"] ?? "",
              categories: List<String>.from(event["categories"]),
              avatar: event["avatar"] ?? "",
              email: event["email"] ?? "",
              foodReservation: event["foodReservation"] ?? false,
              ghostKitchen: event["ghostKitchen"] ?? false,
              homeDelivery: event["homeDelivery"] ?? false,
              momo: event["momo"] ?? false,
              specialOrders: event["specialOrders"] ?? false,
              lat: event["lat"] ?? 0.0,
              lng: event["long"] ?? 0.0,
              openingTime: event['openTime'] ?? "",
              phone: event['phone'] ?? "",
              username: event['username'] ?? "",
              restaurantId: event.id,
              deliveryCost: event['deliveryCost'],
              comments: event['comments'] ?? "",
              followers: event['followers'] ?? 0,
              likes: event['likes'] ?? 0,
              cash: event["cash"] ?? false,
            );

            final List<Widget> pages = [
              HomeScreen(restaurant: restaurant),
              ChatHome(
                stream: messageOverviewStream,
                restaurant: restaurant,
              ),
              // MessagesScreen(),
              SettingsScreen()
            ];

            return SafeArea(
              child: Scaffold(
                bottomNavigationBar: SlidingClippedNavBar(
                  backgroundColor: Color.fromARGB(255, 238, 238, 238),
                  inactiveColor: Colors.lightGreen,
                  activeColor: Colors.black,
                  barItems: [
                    BarItem(title: "Home", icon: Icons.home_rounded),
                    BarItem(
                        title: "Messages", icon: FontAwesomeIcons.solidMessage),
                    BarItem(title: "Settings", icon: FontAwesomeIcons.gears)
                  ],
                  selectedIndex: _index,
                  fontSize: 14,
                  iconSize: 20,
                  onButtonPressed: (index) {
                    HapticFeedback.heavyImpact();

                    setState(() {
                      _index = index;
                    });
                    _pageController.animateToPage(_index,
                        duration: Duration(seconds: 1),
                        curve: Curves.fastLinearToSlowEaseIn);
                  },
                ),
                body: PageView.builder(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  itemCount: pages.length,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index) {
                    setState(() {
                      _index = index;
                    });
                  },
                  allowImplicitScrolling: false,
                  itemBuilder: (_, index) {
                    return AnimatedSwitcher(
                      duration: Duration(
                        milliseconds: 2700,
                      ),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                              curve: Curves.fastLinearToSlowEaseIn,
                              parent: animation,
                              reverseCurve: Curves.fastOutSlowIn),
                          child: child,
                        );
                      },
                      reverseDuration: Duration(milliseconds: 300),
                      switchInCurve: Curves.fastLinearToSlowEaseIn,
                      switchOutCurve: Curves.fastOutSlowIn,
                      child: pages[_index],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  showNotificationNow() {
    setState(() {
      showNotificationIcon = false;
    });
  }
}
