import 'package:flutter/cupertino.dart';
import 'package:merchants/models/food_model.dart';

import '../global.dart';

class Meals with ChangeNotifier {
  List<Food> meals = [];

  ServicesData() {
    loadServices();
  }

  Future<void> loadServices() async {
    firestore
        .collection("meals")
        .where("restaurantId", isEqualTo: auth.currentUser!.uid)
        .orderBy("created_time", descending: true)
        .snapshots()
        .listen((event) {
      meals.clear();
      for (var data in event.docs) {
        String documentID = data.id;

        Food food = Food(
          foodId: documentID,
          verified: data["verified"],
          ingredients: List<String>.from(data['ingredients']),
          likes: data['likes'] as int,
          description: data['description'],
          comments: data['comments'] as int,
          name: data["name"],
          available: data["available"],
          image: data['image'],
          averageRating:
              data["averageRating"] as int, //int.parse(data['averageRating'])
          price: data["price"] as double, //double.parse(data['price'])
          restaurantId: data['restaurantId'],
          gallery: List<String>.from(data['gallery']),
          compliments: List<String>.from(data['accessories']),
          duration: data['duration'],
          categories: List<String>.from(data['categories']),
        );

        meals.add(food);
      }
    });
    notifyListeners();
  }

  Future<Food?> getMeal({required String foodId}) async {
    return meals.firstWhere((element) => element.foodId == foodId,
        orElse: null);
  }

  updateMeal({required String foodId, required Map<String, dynamic> data}) {
    meals[meals.lastIndexWhere((element) => element.foodId == foodId)] =
        Food.fromJson(data);
    notifyListeners();
  }
}
