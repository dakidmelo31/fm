import 'package:flutter/cupertino.dart';
import 'package:merchants/models/food_model.dart';

class Data extends ChangeNotifier {
  late final List<Food> _myMeals = [];

  late List<Food> myMeals = _myMeals;

  late int totalMeals = myMeals.length;

  bool addMeal(Food food) {
    if (food.runtimeType == Food) {
      myMeals.add(food);
      notifyListeners();
      return true;
    }
    return false;
  }

  updateMeal(Food food) {
    myMeals[myMeals.indexWhere(
        (element) => element.restaurantId == food.restaurantId)] = food;
    notifyListeners();
  }

  void deleteMeal(String restaurantId) {
    myMeals.removeWhere((element) => element.restaurantId == restaurantId);
  }
}
