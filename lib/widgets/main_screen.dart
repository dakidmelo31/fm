import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:merchants/models/service.dart';
import 'package:merchants/providers/restaurant_provider.dart';
import 'package:merchants/providers/services.dart';
import 'package:merchants/transitions/transitions.dart';
import 'package:merchants/widgets/create_service.dart';
import 'package:merchants/widgets/service_card.dart';
import 'package:merchants/widgets/settings_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../models/food_model.dart';
import '../pages/new_meal.dart';
import '../theme/main_theme.dart';
import '../themes/light_theme.dart';
import 'drag_notch.dart';
import 'meal_card.dart';
import 'order_cards.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomeScreen extends StatefulWidget {
  static const routeName = "/homeScreen";
  const HomeScreen({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int convertInt(dynamic value) {
    if (value == null) return 0;
    var myInt = value;
    int newInt = myInt as int;

    return newInt;
  }

  List<String> convertString(dynamic list) {
    if (list == null) {
      return [];
    }
    if (list.runtimeType == String) {
      String names = list as String;
      List<String> d = names.split(",");
      return d;
    }

    return [];
  }

  List<String> convertList(dynamic list) {
    List<String> data = [];
    if (list == null) {
      return data;
    }

    for (String item in list) {
      data.add(item);
    }

    return data;
  }

  late final Restaurant restaurant;

  late AnimationController _animationController;
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    restaurant = widget.restaurant;
    // auth.signOut();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    _tabController.addListener(() {
      setState(() {
        answer = _tabController.index == 0;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool popScope = true, answer = true;

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<MealsData>(context);
    final services = Provider.of<ServicesData>(context);
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (!popScope) {
          debugPrint("$popScope");
          _animationController.reverse();
          popScope = true;
          return false;
        }
        if (!answer) {
          _tabController.animateTo(0,
              duration: Duration(milliseconds: 600),
              curve: Curves.fastLinearToSlowEaseIn);
          answer = true;
          return false;
        }
        return popScope;
      },
      child: Stack(
        children: [
          AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return AnimatedPositioned(
                  curve: Curves.linearToEaseOut,
                  duration: Duration(milliseconds: 350),
                  top: 0,
                  // top: 0 - size.height * _animationController.value * .3,
                  width: size.width,
                  height: size.height * .8,
                  child: Center(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate([
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              height: size.height * .1,
                              width: size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              CustomFadeTransition(
                                                  child: Material(
                                                      child:
                                                          SettingsScreen())));
                                        },
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: restaurant.businessPhoto,
                                            errorWidget: (_, __, ___) =>
                                                Lottie.asset(
                                                    "assets/no-connection2.json"),
                                            placeholder: (
                                              _,
                                              __,
                                            ) =>
                                                Lottie.asset(
                                                    "assets/loading7.json"),
                                            fadeInCurve:
                                                Curves.fastLinearToSlowEaseIn,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                            width: 54,
                                            height: 54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        restaurant.companyName.toString(),
                                        style: boldText,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        restaurant.address.toString(),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  AvatarGlow(
                                    duration: Duration(
                                      milliseconds: 1200,
                                    ),
                                    endRadius: 25.0,
                                    animate: true,
                                    curve: Curves.decelerate,
                                    glowColor: Colors.lightGreen,
                                    showTwoGlows: true,
                                    startDelay: Duration(seconds: 1),
                                    child: IconButton(
                                      onPressed: () async {
                                        showCupertinoModalBottomSheet(
                                            context: context,
                                            animationCurve: Curves.decelerate,
                                            bounce: true,
                                            barrierColor:
                                                Colors.black.withOpacity(.7),
                                            backgroundColor:
                                                Colors.black.withOpacity(.7),
                                            elevation: 10.0,
                                            enableDrag: true,
                                            duration:
                                                Duration(milliseconds: 700),
                                            isDismissible: true,
                                            overlayStyle: SystemUiOverlayStyle(
                                              statusBarBrightness:
                                                  Brightness.dark,
                                              statusBarColor: Color.fromARGB(
                                                  255, 54, 99, 3),
                                              systemNavigationBarDividerColor:
                                                  Color.fromARGB(
                                                      255, 54, 99, 3),
                                            ),
                                            builder: (builder) {
                                              return FractionallySizedBox(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                heightFactor: .3,
                                                widthFactor: 1.0,
                                                child: Material(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(18.0),
                                                        child: Text(
                                                            "What do you want to create?",
                                                            style: Primary
                                                                .bigHeading),
                                                      ),
                                                      Spacer(),
                                                      Card(
                                                        color: Colors.white,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    15.0,
                                                                vertical: 5.0),
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.pushReplacement(
                                                                context,
                                                                VerticalSizeTransition(
                                                                    child:
                                                                        NewMeal()));
                                                          },
                                                          child: Center(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          15.0,
                                                                      vertical:
                                                                          18.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                      Icons
                                                                          .restaurant_rounded,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "New Meal",
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        elevation: 15.0,
                                                        shadowColor: Colors.grey
                                                            .withOpacity(.5),
                                                      ),
                                                      Spacer(),
                                                      Card(
                                                        color: Colors.blue,
                                                        elevation: 15.0,
                                                        shadowColor: Colors.grey
                                                            .withOpacity(.5),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    15.0,
                                                                vertical: 5.0),
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator
                                                                .pushReplacement(
                                                              context,
                                                              CustomFadeTransition(
                                                                child:
                                                                    CreateService(),
                                                              ),
                                                            );
                                                          },
                                                          child: Center(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          15.0,
                                                                      vertical:
                                                                          18.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                      Icons
                                                                          .miscellaneous_services,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                      "New Service",
                                                                      style: Primary
                                                                          .whiteText),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });

                                        final data = Provider.of<MealsData>(
                                            context,
                                            listen: false);
                                        data.meals = [];
                                        await data.loadMeals();
                                        setState(() {});
                                      },
                                      icon: FaIcon(
                                        FontAwesomeIcons.plus,
                                        size: 25,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              "Calendar Bookings",
                              style: boldText,
                            ),
                            DatePicker(
                              DateTime.now(),
                              width: 80,
                              height: 100,
                              initialSelectedDate: DateTime.now(),
                              selectedTextColor: Colors.white,
                              selectionColor: Theme.of(context).primaryColor,
                              dateTextStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "Order Menu",
                              style: boldText,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            OrderCards(
                                restaurant: widget.restaurant,
                                orderStream: firestore
                                    .collection("orders")
                                    .where("restaurantId",
                                        isEqualTo: auth.currentUser!.uid)
                                    .orderBy("time", descending: true)
                                    .snapshots()),
                          ]),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return AnimatedPositioned(
                  duration: Duration(milliseconds: 1600),
                  curve: Curves.fastLinearToSlowEaseIn,
                  top: size.height * .8 * (1 - _animationController.value),
                  // top: size.height * .8 -
                  //     (size.height * .75 * _animationController.value),
                  left: 0,
                  // height: size.height * .2 +
                  //     (size.height * .75 * _animationController.value),
                  height: size.height,

                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GestureDetector(
                          onPanUpdate: (details) {
                            if (details.delta.dy > 0) {
                              setState(() {
                                popScope = true;
                                _animationController.reverse();
                              });
                            } else if (details.delta.dy < 0) {
                              setState(() {
                                popScope = false;
                                _animationController.forward();
                              });
                            }
                          },
                          child: Container(
                            color: ColorTween(
                                    begin: Color.fromARGB(255, 238, 238, 238),
                                    end: Colors.lightGreen)
                                .animate(CurvedAnimation(
                                    parent: _animationController,
                                    curve: Curves.decelerate,
                                    reverseCurve: Curves.decelerate))
                                .value,
                            width: size.width,
                            height: kToolbarHeight * 1,
                            child: DragNotch(pullUp: () {
                              setState(() {
                                popScope = false;
                                _animationController.forward();
                              });
                            }, pullDown: () {
                              setState(() {
                                popScope = true;
                                _animationController.reverse();
                              });
                            }),
                          ),
                        ),
                        Container(
                          color: ColorTween(
                                  begin: Color.fromARGB(255, 238, 238, 238),
                                  end: Colors.white)
                              .animate(_animationController)
                              .value,
                          height: kToolbarHeight,
                          width: size.width,
                          child: TabBar(controller: _tabController, tabs: [
                            Tab(
                              child: Text(
                                "Meals",
                                style: TextStyle(
                                  color: ColorTween(
                                          begin: Color.fromARGB(
                                              255, 182, 181, 181),
                                          end: Colors.lightGreen)
                                      .animate(_animationController)
                                      .value,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Services",
                                style: TextStyle(
                                  color: ColorTween(
                                          begin: Color.fromARGB(
                                              255, 184, 184, 184),
                                          end: Colors.lightGreen)
                                      .animate(_animationController)
                                      .value,
                                ),
                              ),
                            ),
                          ]),
                        ),
                        Container(
                          height: size.height - (kToolbarHeight * 2),
                          width: size.width,
                          color: Colors.white,
                          child: TabBarView(
                              controller: _tabController,
                              physics: BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              children: [
                                AnimationLimiter(
                                  child: data.meals.length == 0
                                      ? Center(
                                          child: TextButton.icon(
                                              icon: Icon(Icons.plus_one),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    HorizontalSizeTransition(
                                                        child: NewMeal()));
                                              },
                                              label: Text(
                                                  "Add your first meal now")),
                                        )
                                      : ListView.builder(
                                          physics: BouncingScrollPhysics(),
                                          padding:
                                              EdgeInsets.only(bottom: 100.0),
                                          itemCount: data.meals.length,
                                          itemBuilder: (_, index) {
                                            Food food = data.meals[index];
                                            return AnimationConfiguration
                                                .staggeredList(
                                                    position: index,
                                                    child: SlideAnimation(
                                                      duration: Duration(
                                                        milliseconds: 100,
                                                      ),
                                                      curve: Curves
                                                          .fastLinearToSlowEaseIn,
                                                      child: FadeInAnimation(
                                                          child: MealCard(
                                                              food: food),
                                                          curve: Curves
                                                              .fastLinearToSlowEaseIn),
                                                    ));
                                          }),
                                ),
                                AnimationLimiter(
                                  child: services.services.length == 0
                                      ? Center(
                                          child: TextButton.icon(
                                              icon: Icon(Icons.plus_one),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    HorizontalSizeTransition(
                                                        child: NewMeal()));
                                              },
                                              label: Text(
                                                  "Add your first service now")),
                                        )
                                      : ListView.builder(
                                          physics: BouncingScrollPhysics(),
                                          padding:
                                              EdgeInsets.only(bottom: 100.0),
                                          itemCount: services.services.length,
                                          itemBuilder: (_, index) {
                                            ServiceModel service =
                                                services.services[index];
                                            return AnimationConfiguration
                                                .staggeredList(
                                                    position: index,
                                                    child: SlideAnimation(
                                                      duration: Duration(
                                                        milliseconds: 100,
                                                      ),
                                                      curve: Curves
                                                          .fastLinearToSlowEaseIn,
                                                      child: FadeInAnimation(
                                                          child: ServiceCard(
                                                              service: service),
                                                          curve: Curves
                                                              .fastLinearToSlowEaseIn),
                                                    ));
                                          }),
                                )
                              ]),
                        )
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  double bottomHeight = 120.0;
}
