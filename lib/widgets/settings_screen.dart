import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:merchants/pages/intro_page.dart';
import 'package:merchants/pages/startup_screen.dart';
import 'package:merchants/pages/verification_form.dart';
import 'package:merchants/providers/restaurant_provider.dart';
import 'package:merchants/transitions/transitions.dart';
import 'package:merchants/widgets/settings_card.dart';
import 'package:merchants/widgets/upload_gallery.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global.dart';
import '../models/food_model.dart';
import '../providers/auth_provider.dart';
import '../themes/light_theme.dart';

FirebaseFirestore firstore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class SettingsScreen extends StatefulWidget {
  static const routeName = "/settings";
  SettingsScreen();

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextStyle whiteText = const TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    Future<TimeOfDay> _timePicker() async {
      debugPrint("show time picker dialog");

      final TimeOfDay time = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return TimePickerDialog(
              initialEntryMode: TimePickerEntryMode.dial,
              initialTime: TimeOfDay.now(),
              cancelText: "Cancel",
              confirmText: "Now",
            );
          });
      return time;
    }

    Size size = MediaQuery.of(context).size;
    final _restaurantData = Provider.of<MealsData>(context, listen: true);
    final _userData = Provider.of<Auth>(context, listen: true);
    final Restaurant restaurant = _userData.restaurant;
    final List<Food> meals = _restaurantData.meals;
    const caption = TextStyle(
        color: Colors.orange, fontSize: 30, fontWeight: FontWeight.w700);
    const caption2 = TextStyle(
        color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700);
    const label = TextStyle(
        color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 80,
        automaticallyImplyLeading: false,
        title: const Text(
          "Profile",
        ),
        actions: [
          if (false)
            IconButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  Navigator.push(
                    context,
                    CustomFadeTransition(
                      child: VerificationForm(),
                    ),
                  );
                },
                icon: Icon(Icons.security_update_good_rounded,
                    color: Colors.lightGreen)),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.pink),
            onPressed: () async {
              bool? outcome = await showCupertinoDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) {
                    return Material(
                      color: Colors.transparent,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Card(
                            color: Colors.white,
                            child: SizedBox(
                              height: 100,
                              width: 300,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("Confirm logout",
                                      style: Primary.bigHeading),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: Text("Logout"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });

              if (outcome != null && outcome) {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove("phone");
                prefs.clear();
                setState(() {
                  auth.signOut();
                });

                Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            StartupScreen(),
                        transitionDuration: Duration(milliseconds: 1200),
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
              }
            },
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            alignment: Alignment.center,
          )
        ],
      ),
      body: SizedBox(
        width: size.width,
        height: size.height -
            MediaQuery.of(context).padding.bottom -
            MediaQuery.of(context).padding.along(Axis.vertical),
        child: ListView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      showCupertinoDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text("Picture"),
                            content: CachedNetworkImage(
                              imageUrl: restaurant.businessPhoto,
                              errorWidget: (_, __, ___) =>
                                  Lottie.asset("assets/no-connection2.json"),
                              placeholder: (
                                _,
                                __,
                              ) =>
                                  Lottie.asset("assets/loading7.json"),
                              fadeInCurve: Curves.fastLinearToSlowEaseIn,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              width: size.width * .9,
                              height: size.width * .9,
                            ),
                            insetAnimationCurve: Curves.elasticInOut,
                            insetAnimationDuration:
                                const Duration(milliseconds: 300),
                          );
                        },
                      );
                    },
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: restaurant.businessPhoto,
                        errorWidget: (_, __, ___) =>
                            Lottie.asset("assets/no-connection2.json"),
                        placeholder: (
                          _,
                          __,
                        ) =>
                            Lottie.asset("assets/loading7.json"),
                        fadeInCurve: Curves.fastLinearToSlowEaseIn,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        width: size.width * .3,
                        height: size.width * .3,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: size.height * .15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Text(
                            meals.length.toString(),
                            style: caption,
                          ),
                          Text(
                            "Meals",
                            style: label,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            restaurant.followers.toString(),
                            style: caption,
                          ),
                          Text(
                            "Followers",
                            style: label,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            _restaurantData.allOrders.length.toString(),
                            style: caption,
                          ),
                          Text(
                            "Orders",
                            style: label,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: Introduction(),
                                  type: PageTransitionType.bottomToTop));
                        },
                        child: Text("Gallery")),
                    IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            PageRouteBuilder(
                                transitionDuration:
                                    Duration(milliseconds: 1200),
                                reverseTransitionDuration:
                                    Duration(milliseconds: 300),
                                transitionsBuilder:
                                    (_, animation, anotherAnimation, child) {
                                  return SizeTransition(
                                    sizeFactor: animation,
                                    axis: Axis.horizontal,
                                    axisAlignment: 0.0,
                                    child: child,
                                  );
                                },
                                pageBuilder: (BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation) {
                                  animation = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.fastLinearToSlowEaseIn);

                                  return SizeTransition(
                                    sizeFactor: animation,
                                    axis: Axis.vertical,
                                    axisAlignment: 0.0,
                                    child: UploadGallery(),
                                  );
                                }),
                          ).then((value) {
                            _userData.getRestaurant();
                          });
                        },
                        icon: Icon(Icons.add_a_photo))
                  ],
                ),
                MasonryGridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: restaurant.gallery.length,
                  itemBuilder: (context, index) {
                    String image = restaurant.gallery[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(
                          Random().nextBool() ? 12 : 20.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  barrierColor: Colors.transparent,
                                  opaque: false,
                                  transitionDuration:
                                      Duration(milliseconds: 900),
                                  reverseTransitionDuration:
                                      Duration(milliseconds: 300),
                                  pageBuilder: (BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secondaryAnimation) {
                                    animation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.fastLinearToSlowEaseIn);
                                    return FadeTransition(
                                      opacity: animation,
                                      child: Scaffold(
                                        backgroundColor:
                                            Colors.black.withOpacity(.6),
                                        body: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Hero(
                                                tag: image,
                                                child: CachedNetworkImage(
                                                  imageUrl: image,
                                                  placeholder: (_, __) =>
                                                      Lottie.asset(
                                                          "assets/loading7.json"),
                                                  alignment: Alignment.center,
                                                  fit: BoxFit.cover,
                                                  errorWidget: (_, __, ___) =>
                                                      Lottie.asset(
                                                    "assets/no-connection1.json",
                                                    alignment: Alignment.center,
                                                    fit: BoxFit.cover,
                                                    width: size.width,
                                                    height: size.width,
                                                  ),
                                                  width: size.width,
                                                  height: size.width,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Hero(
                                                  tag: "button",
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 18.0),
                                                    child: ElevatedButton(
                                                        onPressed: () {
                                                          _userData
                                                              .setBusinessPhoto(
                                                                  image);
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "restaurants")
                                                              .doc(restaurant
                                                                  .restaurantId)
                                                              .update({
                                                                "gallery":
                                                                    restaurant
                                                                        .gallery,
                                                                "businessPhoto":
                                                                    image
                                                              })
                                                              .then((value) =>
                                                                  debugPrint(
                                                                      "successful Printing"))
                                                              .catchError((er) {
                                                                debugPrint(
                                                                    "Error during switch $er");
                                                              });
                                                          setState(() {});
                                                        },
                                                        child: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: Text(
                                                            "Make This Profile Photo",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15.0),
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }));
                        },
                        child: Hero(
                          tag: image,
                          child: CachedNetworkImage(
                            imageUrl: image,
                            placeholder: (_, __) =>
                                Lottie.asset("assets/loading7.json"),
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Lottie.asset(
                              "assets/no-connection2.json",
                              alignment: Alignment.center,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // SizedBox(
                //     height: 120,
                //     width: size.width,
                //     child: CarouselSlider.builder(
                //         itemCount: restaurant.gallery.length,
                //         itemBuilder: (_, index, pageViewIndex) {
                //           String image = restaurant.gallery[index];
                //           return ClipRRect(
                //             borderRadius: BorderRadius.circular(20.0),
                //             child: CachedNetworkImage(
                //               imageUrl: image,
                //               placeholder: (_, __) =>
                //                   Lottie.asset("assets/loading-animation.json"),
                //               alignment: Alignment.center,
                //               fit: BoxFit.cover,
                //               errorWidget: (_, __, ___) => Lottie.asset(
                //                 "assets/no-connection.json",
                //                 alignment: Alignment.center,
                //                 fit: BoxFit.contain,
                //               ),
                //             ),
                //           );
                //         },
                //         options: CarouselOptions(autoPlay: true))),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  alignment: Alignment.center,
                  child: Hero(
                    tag: 'button',
                    child: Material(
                      color: Colors.transparent,
                      child: const Text(
                        "You can change your information here by Just tapping on it",
                        maxLines: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Divider(
                  height: 6,
                  thickness: 2,
                  color: Colors.orangeAccent,
                  endIndent: 30,
                  indent: 30,
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  height: size.height * .15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SettingsCard(
                          updateKey: "companyName",
                          initialValue: restaurant.companyName),
                      SettingsCard(
                          updateKey: "email", initialValue: restaurant.email)
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: size.height * .15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SettingsCard(
                          updateKey: "phone", initialValue: restaurant.phone),
                      SettingsCard(
                          updateKey: "address",
                          initialValue: restaurant.address)
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 17),
                        elevation: 15,
                        shadowColor: Colors.green,
                        child: InkWell(
                          onTap: () async {
                            TimeOfDay time = await _timePicker();
                            var _updateTime = (time.hour <= 12
                                        ? time.hour == 12
                                            ? 1
                                            : time.hour
                                        : time.hour - 12)
                                    .toString() +
                                ":" +
                                time.minute.toString() +
                                (time.hour > 11 ? " PM" : " AM");
                            Map<String, dynamic> update = {
                              "openingTime": _updateTime,
                              "openTime": _updateTime,
                            };
                            restaurant.openingTime = _updateTime;
                            updateData(
                              collection: "restaurants",
                              doc: restaurant.restaurantId,
                              data: update,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 17),
                            child: Column(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.clock,
                                  color: Colors.lightGreen,
                                ),
                                const Text(
                                  "Opening Time",
                                  style: caption2,
                                ),
                                Text(
                                  restaurant.openingTime.toString(),
                                  style: label,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 15,
                        shadowColor: Colors.orangeAccent,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 17),
                        child: InkWell(
                          onTap: () async {
                            TimeOfDay time = await _timePicker();
                            var _updateTime =
                                (time.hour < 12 ? time.hour : time.hour - 12)
                                        .toString() +
                                    ":" +
                                    time.minute.toString() +
                                    (time.hour > 11 ? " PM" : " AM");
                            Map<String, dynamic> update = {
                              "closingTime": _updateTime,
                            };
                            restaurant.closingTime = _updateTime;

                            updateData(
                              collection: "restaurants",
                              doc: restaurant.restaurantId,
                              data: update,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 17),
                            child: Column(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.clock,
                                  color: Colors.pink,
                                ),
                                const Text(
                                  "Closing Time",
                                  style: caption2,
                                ),
                                Text(
                                  restaurant.closingTime.toString(),
                                  style: label,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 15),
                      const Text(
                        "Payment Details",
                        style: caption2,
                      ),
                      const SizedBox(height: 15),
                      SwitchListTile.adaptive(
                        tileColor: restaurant.cash
                            ? Colors.white
                            : Colors.grey.withOpacity(.2),
                        value: restaurant.cash,
                        onChanged: (bool newVal) async {
                          Map<String, dynamic> update = {
                            "cash": newVal,
                          };
                          restaurant.cash = newVal;
                          await updateData(
                            collection: "restaurants",
                            doc: restaurant.restaurantId,
                            data: update,
                          );
                          setState(() {});
                        },
                        title: const Text("Pay with Cash"),
                        dense: true,
                        subtitle: const Text("Physical payment accepted"),
                      ),
                      SwitchListTile.adaptive(
                        tileColor: restaurant.momo
                            ? Colors.white
                            : Colors.grey.withOpacity(.2),
                        value: restaurant.momo,
                        onChanged: (bool newVal) async {
                          Map<String, dynamic> update = {
                            "momo": newVal,
                          };
                          restaurant.momo = newVal;

                          await updateData(
                            collection: "restaurants",
                            doc: restaurant.restaurantId,
                            data: update,
                          );
                          setState(() {});
                        },
                        title: const Text("Collect Payments Via Mobile Money"),
                        dense: true,
                        subtitle: const Text(
                            "Receive your payments through mobile money"),
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 10,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 15),
                      const Text(
                        "Your Main Services",
                        style: caption2,
                      ),
                      const SizedBox(height: 15),
                      SwitchListTile.adaptive(
                        tileColor: restaurant.tableReservation
                            ? Colors.white
                            : Colors.grey.withOpacity(.2),
                        value: restaurant.tableReservation,
                        onChanged: (bool newVal) async {
                          Map<String, dynamic> update = {
                            "tableReservation": newVal,
                          };
                          restaurant.tableReservation = newVal;
                          await updateData(
                            collection: "restaurants",
                            doc: restaurant.restaurantId,
                            data: update,
                          );
                          setState(() {});
                        },
                        title: const Text("Reserve Customer Tables"),
                        dense: true,
                        subtitle:
                            const Text("select this if you reserve tables"),
                      ),
                      SwitchListTile.adaptive(
                        tileColor: restaurant.specialOrders
                            ? Colors.white
                            : Colors.grey.withOpacity(.2),
                        value: restaurant.specialOrders,
                        onChanged: (bool newVal) async {
                          Map<String, dynamic> update = {
                            "specialOrders": newVal,
                          };
                          restaurant.specialOrders = newVal;

                          await updateData(
                            collection: "restaurants",
                            doc: restaurant.restaurantId,
                            data: update,
                          );
                          setState(() {});
                        },
                        title: const Text("Take Special Commands"),
                        dense: true,
                        subtitle: const Text(
                            "select this if you make special commands"),
                      ),
                      SwitchListTile.adaptive(
                        tileColor: restaurant.foodReservation
                            ? Colors.white
                            : Colors.grey.withOpacity(.2),
                        value: restaurant.foodReservation,
                        onChanged: (bool newVal) async {
                          Map<String, dynamic> update = {
                            "foodReservation": newVal,
                          };
                          restaurant.foodReservation = newVal;
                          await updateData(
                            collection: "restaurants",
                            doc: restaurant.restaurantId,
                            data: update,
                          );
                          setState(() {});
                        },
                        title: const Text("Customers can pay ahead"),
                        dense: true,
                        subtitle: const Text(
                            "Allow customers to pay for their meal ahead of time."),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
