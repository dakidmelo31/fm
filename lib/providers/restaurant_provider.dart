import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:merchants/global.dart';
import 'package:merchants/models/food_model.dart';

import 'package:merchants/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class MealsData with ChangeNotifier {
  List<Order> orderSearches = [];

  searchOrders({required String keyword}) async {
    orderSearches.clear();

    var data = allOrders
        .where((element) => element.friendlyId.toString().contains(keyword));

    for (Order item in data) {
      orderSearches.add(item);
    }
  }

  static int convertInt(dynamic value) {
    if (value == null) return 0;
    var myInt = value;
    int newInt = myInt as int;

    return newInt;
  }

  static double convertDouble(dynamic value) {
    if (value == null) return 0;
    var myInt = value + 0.0;
    double newInt = myInt as double;

    return newInt;
  }

  static List<String> convertString(dynamic list) {
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

  static List<String> convertList(dynamic list) {
    List<String> data = [];
    if (list == null) {
      return data;
    }

    for (String item in list) {
      data.add(item);
    }

    return data;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Food> meals = [], searchList = [];

  loadMeals() async {
    firestore
        .collection("meals")
        .where("restaurantId", isEqualTo: auth.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) async {
          for (var data in querySnapshot.docs) {
            String foodId = data.id;
            // debugPrint(
            //     "going through $foodId now and items of meals array are ${meals.length}");

            meals.add(
              Food(
                foodId: foodId,
                verified: data["verified"],
                ingredients: List<String>.from(data['ingredients']),
                likes: data['likes'] as int,
                description: data['description'],
                comments: data['comments'] as int,
                name: data["name"],
                available: data["available"],
                image: data['image'],
                averageRating: data["averageRating"]
                    as int, //int.parse(data['averageRating'])
                price: data["price"] as double, //double.parse(data['price'])
                restaurantId: data['restaurantId'],
                gallery: List<String>.from(data['gallery']),
                compliments: List<String>.from(data['accessories']),
                duration: data['duration'],
                categories: List<String>.from(data['categories']),
              ),
            );
          }
        })
        .then((value) {})
        .whenComplete(() {
          notifyListeners();
        });
  }

  MealsData() {
    getAllOrders();
    loadMeals();
  }

  Food getMeal(String foodId) {
    return meals.firstWhere((element) => element.foodId == foodId);
  }

  toggleLike(
      {required String userId,
      required String foodId,
      required dynamic value,
      required String name}) async {
    final _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey(foodId)) {
      debugPrint("already liked");
    } else {
      debugPrint("add like");
      FirebaseFirestore.instance
          .collection("meals")
          .where("foodId", isEqualTo: foodId)
          .get()
          .then(
        (querySnapshot) {
          for (var document in querySnapshot.docs) {
            int likes = document.data()["likes"];
            likes++;
            FirebaseFirestore.instance.collection("meals").doc(foodId).update(
              {
                "likes": likes,
              },
            ).then(
              (value) {
                debugPrint("done updating");
              },
            ).catchError(
              (error) {
                debugPrint("Error while updating: $error");
              },
            );
          }
        },
      );
    }
  }

  List<Order> allOrders = [],
      pendingOrders = [],
      processingOrders = [],
      completedOrders = [],
      cancelledOrders = [],
      takeoutOrders = [];
  DateTime? pendingTime, processingTime, completedTime, takeoutTime;
  getAllOrders() async {
    QuerySnapshot<Map<String, dynamic>> data = await firestore
        .collection("orders")
        .where("restaurantId", isEqualTo: auth.currentUser!.uid)
        .orderBy("time", descending: false)
        .get();
    allOrders.clear();
    cancelledOrders.clear();
    completedOrders.clear();
    processingOrders.clear();
    pendingOrders.clear();
    takeoutOrders.clear();

    if (data.docs.isEmpty) {
      pendingTime = DateTime.now();
      processingTime = DateTime.now();
      completedTime = DateTime.now();
      takeoutTime = DateTime.now();
    }

    for (var item in data.docs) {
      List<double> _total = List<double>.from(item["prices"]);

      Order order = Order(
          deviceId: item["deviceId"] ?? "",
          userToken: item["userToken"] ?? "",
          friendlyId: item["friendlyId"] ?? "",
          prices: _total,
          userId: item["userId"],
          quantities: List<int>.from(item['quantities']),
          names: List<String>.from(item['names']),
          time: item['time'],
          status: item['status'],
          restaurantId: item["restaurantId"],
          deliveryCost: (item['deliveryCost'] + 0.0),
          homeDelivery: item['homeDelivery']);
      order.orderId = item.id;
      order.status = order.status.toLowerCase();
      allOrders.add(order);

      //add to orders list
      order.status.toLowerCase() == "pending"
          ? pendingOrders.add(order)
          : order.status.toLowerCase() == "completed"
              ? completedOrders.add(order)
              : order.status.toLowerCase() == "processing"
                  ? processingOrders.add(order)
                  : order.status.toLowerCase() == "takeout"
                      ? takeoutOrders.add(order)
                      : null;
      order.status.toLowerCase() == "pending"
          ? pendingTime = order.time.toDate()
          : order.status.toLowerCase() == "completed"
              ? completedTime = order.time.toDate()
              : order.status.toLowerCase() == "processing"
                  ? processingTime = order.time.toDate()
                  : order.status.toLowerCase() == "takeout"
                      ? takeoutTime = order.time.toDate()
                      : null;

      pendingOrders.sort(((b, a) => a.time.compareTo(b.time)));
      completedOrders.sort(((b, a) => a.time.compareTo(b.time)));
      processingOrders.sort(((b, a) => a.time.compareTo(b.time)));
      takeoutOrders.sort(((b, a) => a.time.compareTo(b.time)));
      allOrders.sort(((b, a) => a.time.compareTo(b.time)));
    }
  }

  updateRestaurant(
      {required String restaurantId, required Map<String, dynamic> map}) async {
    firestore
        .collection("restaurant")
        .doc(restaurantId)
        .set(map, SetOptions(merge: true))
        .then((value) => debugPrint("done adding map to firestore"))
        .catchError((onError) {
      debugPrint("Error updating data: $onError");
    });
  }
}
