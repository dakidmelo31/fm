import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/pages/all_orders.dart';
import 'package:merchants/providers/restaurant_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../models/restaurants.dart';

// ignore: must_be_immutable
class OrderCards extends StatelessWidget {
  OrderCards({Key? key, required this.restaurant, required this.orderStream})
      : super(key: key);
  Stream<QuerySnapshot<Object?>>? orderStream;
  Restaurant restaurant;
  Widget _cardBuilder(
      {required String name,
      required Color textColor,
      required Color cardColor,
      int amount = 0,
      String time = "",
      required BuildContext context}) {
    final _restaurantData = Provider.of<MealsData>(context);
    DateTime? latestTime = name.toLowerCase() == "pending"
        ? _restaurantData.pendingTime
        : name.toLowerCase() == "processing"
            ? _restaurantData.processingTime
            : name.toLowerCase() == "takeouts" || name.toLowerCase() == "ready"
                ? _restaurantData.takeoutTime
                : name.toLowerCase() == "completed" ||
                        name.toLowerCase() == "complete"
                    ? _restaurantData.completedTime
                    : null;
    final String time = latestTime == null ? "" : timeAgo.format(latestTime);

    return AnimatedSwitcher(
      duration: Duration(
        milliseconds: 2500,
      ),
      switchInCurve: Curves.fastLinearToSlowEaseIn,
      switchOutCurve: Curves.fastOutSlowIn,
      transitionBuilder: (child, animation) {
        animation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastLinearToSlowEaseIn,
            reverseCurve: Curves.fastOutSlowIn);
        return SizeTransition(
          axis: Axis.horizontal,
          child: child,
          sizeFactor: animation,
        );
      },
      reverseDuration: Duration(milliseconds: 200),
      child: latestTime == null
          ? Card(
              color: cardColor, //Color.fromARGB(255, 236, 106, 0)
              elevation: 25,
              shadowColor: cardColor == Colors.lightGreen
                  ? Colors.black
                  : Colors.grey.withOpacity(.25),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: OpenContainer(
                transitionDuration: Duration(milliseconds: 700),
                closedElevation: 0.0,
                openElevation: 0.0,
                closedColor: Colors.transparent,
                openColor: Colors.transparent,
                middleColor: Color.fromARGB(255, 240, 240, 240),
                transitionType: ContainerTransitionType.fadeThrough,
                tappable: true,
                openBuilder: (context, action) =>
                    AllOrders(name: name, restaurant: restaurant),
                closedBuilder: ((context, action) => InkWell(
                      onTap: () {},
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart,
                                size: 30, color: textColor),
                            Text("No orders yet",
                                style:
                                    TextStyle(color: textColor, fontSize: 15)),
                            Text(name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cardColor == Colors.lightGreen
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w700,
                                )),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "",
                                style: TextStyle(
                                    color: cardColor == Colors.lightGreen
                                        ? Colors.white
                                        : Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            )
          : Card(
              color: cardColor, //Color.fromARGB(255, 236, 106, 0)
              elevation: 25,
              shadowColor: cardColor == Colors.lightGreen
                  ? Colors.black
                  : Colors.grey.withOpacity(.25),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: OpenContainer(
                transitionDuration: Duration(milliseconds: 700),
                closedElevation: 0.0,
                openElevation: 0.0,
                closedColor: Colors.transparent,
                openColor: Colors.transparent,
                middleColor: Color.fromARGB(255, 240, 240, 240),
                transitionType: ContainerTransitionType.fadeThrough,
                tappable: true,
                openBuilder: (context, action) => AllOrders(
                  name: name,
                  restaurant: restaurant,
                ),
                closedBuilder: ((context, action) => InkWell(
                      onTap: action,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart,
                                size: 30, color: textColor),
                            Text(
                                name.toLowerCase() == "pending"
                                    ? _restaurantData.pendingOrders.length
                                        .toString()
                                    : name.toLowerCase() == "processing"
                                        ? _restaurantData
                                            .processingOrders.length
                                            .toString()
                                        : name.toLowerCase() == "takeouts" ||
                                                name.toLowerCase() == "ready"
                                            ? _restaurantData
                                                .takeoutOrders.length
                                                .toString()
                                            : name.toLowerCase() ==
                                                        "completed" ||
                                                    name.toLowerCase() ==
                                                        "complete"
                                                ? _restaurantData
                                                    .completedOrders.length
                                                    .toString()
                                                : _restaurantData
                                                    .allOrders.length
                                                    .toString(),
                                style:
                                    TextStyle(color: textColor, fontSize: 25)),
                            Text(name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: cardColor == Colors.lightGreen
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w700,
                                )),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                time,
                                style: TextStyle(
                                    color: cardColor == Colors.lightGreen
                                        ? Colors.white
                                        : Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(
        milliseconds: 2500,
      ),
      switchInCurve: Curves.fastLinearToSlowEaseIn,
      switchOutCurve: Curves.fastOutSlowIn,
      transitionBuilder: (child, animation) {
        animation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastLinearToSlowEaseIn,
            reverseCurve: Curves.fastOutSlowIn);
        return SizeTransition(
          axis: Axis.horizontal,
          child: child,
          sizeFactor: animation,
        );
      },
      reverseDuration: Duration(milliseconds: 200),
      child: StreamBuilder<QuerySnapshot>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return Text("Error found" + snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Lottie.asset(
              "assets/app/animations/shop_placeholder.json",
              fit: BoxFit.contain,
              alignment: Alignment.center,
            );
          }

          int pending = 0, ready = 0, complete = 0, processing = 0;
          if (snapshot.data!.docChanges.length > 0) {
            final data = Provider.of<MealsData>(context, listen: false);
            data.getAllOrders();
          }

          snapshot.data!.docs.forEach((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            switch ("${data['status']}".toLowerCase()) {
              case "complete":
              case "completed":
                complete++;
                break;

              case "pending":
                pending++;
                break;

              case "processing":
                processing++;
                break;

              case "ready":
              case "takeout":
              case "takeouts":
                ready++;
                break;
            }
          });

          List<Widget> cards = [
            _cardBuilder(
                name: "Pending",
                textColor: Colors.white,
                cardColor: Colors.lightGreen,
                amount: pending,
                context: context,
                time: ""),
            _cardBuilder(
                name: "Processing",
                context: context,
                amount: processing,
                textColor: Colors.blue,
                cardColor: Colors.white),
            _cardBuilder(
                name: "Takeouts",
                amount: ready,
                context: context,
                textColor: Colors.green,
                cardColor: Colors.white),
            _cardBuilder(
                name: "Completed",
                amount: complete,
                context: context,
                textColor: Color.fromARGB(255, 162, 0, 211),
                cardColor: Colors.white),
          ];

          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            shrinkWrap: true,
            children: cards,
          );
        },
      ),
    );
  }
}
