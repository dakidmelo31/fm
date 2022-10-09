import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/pages/service_details.dart';
import 'package:merchants/providers/meals.dart';
import 'package:merchants/providers/services.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../models/restaurants.dart';
import '../pages/product_details.dart';
import '../theme/main_theme.dart';

class MyMeals extends StatefulWidget {
  const MyMeals({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;
  @override
  State<MyMeals> createState() => _MyMealsState();
}

class _MyMealsState extends State<MyMeals> {
  late int totalMeals;
  PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    final allServices =
        Provider.of<ServicesData>(context, listen: true).services;
    final allMeals = Provider.of<Meals>(context).meals;
    Size size = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: firestore
            .collection("meals")
            .where("restaurantId", isEqualTo: auth.currentUser!.uid)
            .orderBy("created_time", descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Check your Internet"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Expanded(
              child: ListView(
                children: [
                  Lottie.asset(
                    "assets/data.json",
                    alignment: Alignment.center,
                    width: size.width,
                  ),
                  Lottie.asset(
                    "assets/data.json",
                    alignment: Alignment.center,
                    width: size.width,
                  ),
                ],
              ),
            );
          }

          if (snapshot.data != null) {
            if (snapshot.data?.docs == null) {
              return Text("Error loading data");
            }
          }

          totalMeals = snapshot.data!.docs.length;
          return Column(
            children: [
              SizedBox(
                height: kToolbarHeight,
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.fastLinearToSlowEaseIn);
                      },
                      child: Text("My Meals"),
                    ),
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.fastLinearToSlowEaseIn);
                        debugPrint("Scroll to Services");
                      },
                      child: Text("My Services"),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.height * .5,
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      height: size.height * .8,
                      child: Column(
                        children: allMeals.map((food) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8),
                            child: Card(
                              color: food.available
                                  ? Colors.white
                                  : Color.fromARGB(255, 240, 240, 240),
                              shadowColor: food.available
                                  ? Colors.grey.withOpacity(.15)
                                  : Colors.grey.withOpacity(.08),
                              elevation: food.available ? 10 : 0,
                              child: SizedBox(
                                width: size.width,
                                height: 160,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: OpenContainer(
                                        openBuilder: (context, _) =>
                                            MealDetails(food: food),
                                        closedBuilder:
                                            (context, openContainer) => InkWell(
                                          onTap: openContainer,
                                          child: CachedNetworkImage(
                                            imageUrl: food.image,
                                            errorWidget: (_, __, ___) =>
                                                errorWidget2,
                                            placeholder: (
                                              _,
                                              __,
                                            ) =>
                                                Lottie.asset(
                                                    "assets/loading5.json"),
                                            fadeInCurve:
                                                Curves.fastLinearToSlowEaseIn,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                            width: size.width / 2.8,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            FittedBox(
                                              child: SelectableText(
                                                food.name,
                                                scrollPhysics:
                                                    const NeverScrollableScrollPhysics(),
                                                style: heading,
                                                maxLines: 2,
                                              ),
                                            ),
                                            SwitchListTile.adaptive(
                                              value: food.available,
                                              onChanged: (update) {
                                                //change status

                                                debugPrint("show this now");
                                                firestore
                                                    .collection("meals")
                                                    .doc(food.foodId)
                                                    .update(
                                                        {"available": update});
                                              },
                                              title: Text(
                                                food.available
                                                    ? "Available"
                                                    : "Unavailable",
                                                style: TextStyle(
                                                    color: food.available
                                                        ? Colors.green
                                                        : Colors.pink),
                                              ),
                                              contentPadding: EdgeInsets.zero,
                                              dense: true,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              // ignore: prefer_const_literals_to_create_immutables
                                              children: [
                                                Spacer(),
                                                const FaIcon(
                                                  FontAwesomeIcons.solidHeart,
                                                  color: Colors.pink,
                                                  size: 18,
                                                ),
                                                // ignore: prefer_const_constructors
                                                Text(
                                                    "  ${food.likes > 999 ? (food.likes / 1000).toStringAsFixed(2) : food.likes} ${food.likes > 999 ? "K" : ""}"),
                                                Spacer(),
                                                const FaIcon(
                                                  FontAwesomeIcons.comment,
                                                  color: Colors.orange,
                                                  size: 18,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Text(
                                                      "${food.comments > 999 ? (food.comments / 1000).toStringAsFixed(2) : food.comments} ${food.comments > 999 ? "K" : ""}",
                                                      style: TextStyle(
                                                          color: Colors.grey)),
                                                ),
                                                Spacer(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      color: Colors.blue,
                      height: size.height * .6,
                      child: Column(
                        children: allServices.map((service) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8),
                            child: Card(
                              color: service.negociable
                                  ? Colors.white
                                  : Color.fromARGB(255, 240, 240, 240),
                              shadowColor: service.negociable
                                  ? Colors.grey.withOpacity(.15)
                                  : Colors.grey.withOpacity(.08),
                              elevation: service.negociable ? 10 : 0,
                              child: SizedBox(
                                width: size.width,
                                height: 160,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: OpenContainer(
                                        openBuilder: (context, _) =>
                                            ServiceDetails(service: service),
                                        closedBuilder:
                                            (context, openContainer) => InkWell(
                                          onTap: openContainer,
                                          child: CachedNetworkImage(
                                            imageUrl: service.image,
                                            errorWidget: (_, __, ___) =>
                                                errorWidget,
                                            placeholder: (
                                              _,
                                              __,
                                            ) =>
                                                Lottie.asset(
                                                    "assets/loading5.json"),
                                            fadeInCurve:
                                                Curves.fastLinearToSlowEaseIn,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                            width: size.width / 2.8,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            FittedBox(
                                              child: SelectableText(
                                                service.name,
                                                scrollPhysics:
                                                    const NeverScrollableScrollPhysics(),
                                                style: heading,
                                                maxLines: 2,
                                              ),
                                            ),
                                            SwitchListTile.adaptive(
                                              value: service.negociable,
                                              onChanged: (update) {
                                                //change status
                                                firestore
                                                    .collection("services")
                                                    .doc(service.serviceId)
                                                    .update(
                                                        {"negociable": update});
                                              },
                                              title: Text(
                                                service.negociable
                                                    ? "Available"
                                                    : "Unavailable",
                                                style: TextStyle(
                                                    color: service.negociable
                                                        ? Colors.green
                                                        : Colors.pink),
                                              ),
                                              contentPadding: EdgeInsets.zero,
                                              dense: true,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              // ignore: prefer_const_literals_to_create_immutables
                                              children: [
                                                Spacer(),
                                                const FaIcon(
                                                  FontAwesomeIcons.solidHeart,
                                                  color: Colors.pink,
                                                  size: 18,
                                                ),
                                                // ignore: prefer_const_constructors
                                                Text(
                                                    "  ${service.likes > 999 ? (service.likes / 1000).toStringAsFixed(2) : service.likes} ${service.likes > 999 ? "K" : ""}"),
                                                Spacer(),
                                                const FaIcon(
                                                  FontAwesomeIcons.comment,
                                                  color: Colors.orange,
                                                  size: 18,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Text(
                                                      "${service.comments > 999 ? (service.comments / 1000).toStringAsFixed(2) : service.comments} ${service.comments > 999 ? "K" : ""}",
                                                      style: TextStyle(
                                                          color: Colors.grey)),
                                                ),
                                                Spacer(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
