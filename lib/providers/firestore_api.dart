import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, FirebaseFirestore, QuerySnapshot;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:merchants/models/food_model.dart';

class FirestoreApi with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String restaurantPath = "restaurants";
  String meals = "meals";

  Future<DocumentSnapshot> getDataCollection() {
    return _firestore
        .collection(restaurantPath)
        .doc(auth.currentUser!.uid)
        .get();
  }

  Stream<QuerySnapshot> streamMyMeals() {
    return _firestore.collection(meals).snapshots();
  }

  Future<DocumentSnapshot> getMealById(String id) {
    return _firestore.collection(meals).doc(id).get();
  }

  Future<void> removeMeal(String id) {
    return _firestore.collection(meals).doc(id).delete();
  }

  addMeal(Food food) async {}

  // Future<void> updateMeal(Map<dynamic, dynamic> data, String id) {
  //   return _firestore.collection(meals).doc(id).update( data );
  // }
}
