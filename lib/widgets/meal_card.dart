// ignore_for_file: must_be_immutable
import 'dart:math';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/global.dart';
import 'package:merchants/models/food_model.dart';
import 'package:merchants/pages/product_details.dart';
import 'package:provider/provider.dart';

import '../models/restaurants.dart';
import '../pages/review_screen.dart';
import '../providers/reviews.dart';

class MealCard extends StatefulWidget {
  MealCard({Key? key, required this.restaurant, required this.food})
      : super(key: key);
  Food food;
  Restaurant restaurant;

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    food = widget.food;
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  late Food food;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewData = Provider.of<ReviewProvider>(context, listen: true);

    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Card(
        color: food.available ? Colors.white : Colors.lightGreen,
        elevation: 8.0,
        shadowColor: food.available ? Colors.white : Colors.lightGreen,
        child: SizedBox(
          width: size.width,
          height: 150.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                OpenContainer(
                  closedElevation: 10.0,
                  openElevation: 10.0,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  transitionType: ContainerTransitionType.fade,
                  closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  transitionDuration: transitionDuration,
                  openBuilder: ((context, action) => MealDetails(food: food)),
                  closedBuilder: (context, action) => InkWell(
                    onTap: action,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        width: 100,
                        height: 140,
                        color: Colors.white,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: CachedNetworkImage(
                              imageUrl: food.image,
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  Lottie.asset("assets/no-connection.json"),
                              placeholder: (
                                _,
                                __,
                              ) =>
                                  Lottie.asset("assets/loading7.json"),
                              fadeInCurve: Curves.fastLinearToSlowEaseIn,
                              width: 90,
                              height: 120,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width - 125.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FittedBox(
                          child: Text(
                            food.name,
                            style: TextStyle(
                              color:
                                  food.available ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  food.available
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_outline_rounded,
                                  color: food.available
                                      ? Colors.pink
                                      : Colors.white,
                                  size: 30.0,
                                ),
                                label: Text(food.likes.toString(),
                                    style: TextStyle(
                                      color: food.available
                                          ? Colors.pink
                                          : Colors.white,
                                    ))),
                            TextButton.icon(
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                          opaque: false,
                                          barrierColor: Colors.transparent,
                                          transitionDuration: Duration(
                                            milliseconds: 2200,
                                          ),
                                          reverseTransitionDuration: Duration(
                                            milliseconds: 300,
                                          ),
                                          pageBuilder:
                                              (_, animation, anotherAnimation) {
                                            animation = CurvedAnimation(
                                                parent: animation,
                                                curve: Curves
                                                    .fastLinearToSlowEaseIn);
                                            return SizeTransition(
                                                sizeFactor: animation,
                                                axis: Axis.vertical,
                                                axisAlignment: 0.0,
                                                child: ReviewScreen(
                                                  foodId: food.foodId,
                                                  name: food.name,
                                                  totalReviews: food.comments,
                                                ));
                                          },
                                          transitionsBuilder: (_, animation,
                                              anotherAnimation, child) {
                                            animation = CurvedAnimation(
                                                parent: animation,
                                                curve: Curves
                                                    .fastLinearToSlowEaseIn);
                                            return SizeTransition(
                                              sizeFactor: animation,
                                              axis: Axis.vertical,
                                              axisAlignment: 0.0,
                                              child: child,
                                            );
                                          }));
                                },
                                icon: Icon(
                                  Icons.star_rounded,
                                  color: food.available
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                                  size: 30.0,
                                ),
                                label: Text(
                                  food.comments.toString(),
                                  style: TextStyle(
                                    color: food.available
                                        ? Colors.orange
                                        : Colors.white,
                                  ),
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Available"),
                            Switch(
                                value: food.available,
                                onChanged: (update) {
                                  updateData(
                                      collection: "meals",
                                      data: {"available": update},
                                      doc: food.foodId);
                                  setState(() {
                                    food.available = update;
                                  });

                                  firestore
                                      .collection("followers")
                                      .doc(auth.currentUser!.uid)
                                      .get()
                                      .then((value) async {
                                    if (value.exists) {
                                      var tokens =
                                          List<String>.from(value['tokens']);
                                      debugPrint("Tokens: $tokens");

                                      tokens.map((userToken) async {
                                        int rand = Random().nextInt(5000);
                                        debugPrint(
                                            "Send Notification to: $userToken");
                                        final data = {
                                          "click_action":
                                              "FLUTTER_NOTIFICATION_CLICK",
                                          "id": "$rand",
                                          "restaurantId": auth.currentUser!.uid,
                                          'message': update
                                              ? food.name +
                                                  " is now available, order or pass by if you're in the mood for some"
                                              : food.name +
                                                  " is fresh out☹️, but there are other meals you can check out",
                                          'color': '#dcedc2',
                                          'type':
                                              update ? 'meal' : 'restaurant',
                                          "extra": food.foodId,
                                          "foodId": food.foodId
                                        };
                                        try {
                                          debugPrint("Token is: $userToken");
                                          http.Response response = await http.post(
                                              Uri.parse(
                                                  "https://fcm.googleapis.com/fcm/send"),
                                              headers: <String, String>{
                                                'Content-Type':
                                                    'application/json',
                                                'Authorization':
                                                    'key=AAAAvlyEBz8:APA91bHiJP23KhUWPvJVvMH0iSgzLh37KQoG2id7-Yuk46_CCV5QTRRz7kU-wXo2g3vWoM5rkQlOTtERlk7vAGAKrZ9HKNLelRAd9yXlYkKN0ETklaYSRXHI9LVCgRh0AKT878i2zXAc',
                                              },
                                              body:
                                                  jsonEncode(<String, dynamic>{
                                                'notification':
                                                    <String, dynamic>{
                                                  'title': widget
                                                      .restaurant.companyName,
                                                  'body': update
                                                      ? food.name +
                                                          " is now available, order or pass by if you're in the mood for some"
                                                      : food.name +
                                                          " is fresh out☹️, but there are other meals you can check out",
                                                  'type': update
                                                      ? 'meal'
                                                      : 'restaurant',
                                                  'image': !update
                                                      ? widget.restaurant
                                                          .businessPhoto
                                                      : food.image,
                                                  'color': "#dcedc2"
                                                },
                                                'priority': 'high',
                                                'data': data,
                                                'collapse-key': update
                                                    ? 'meal'
                                                    : "restaurant",
                                                'to': userToken
                                              }));

                                          if (response.statusCode == 200) {
                                            debugPrint("Notification Sent");
                                          } else {
                                            debugPrint(
                                                "error found ${response.body}");
                                          }
                                        } catch (e) {
                                          throw Exception(
                                              "Error sending personal notification");
                                        }
                                      });
                                    }
                                  }).catchError((onError) {
                                    debugPrint("gone through here");
                                  });
                                })
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
