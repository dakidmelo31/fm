import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global.dart';
import '../models/restaurants.dart';

class Auth with ChangeNotifier {
  Restaurant restaurant = Restaurant(
      deviceToken: '',
      address: '',
      gallery: [],
      name: "",
      categories: [],
      days: [],
      costs: [],
      variants: [],
      lng: 0.0,
      lat: 0.0,
      restaurantId: "",
      businessPhoto: '',
      tableReservation: false,
      cash: false,
      momo: false,
      specialOrders: false,
      avatar: '',
      closingTime: '',
      openingTime: '',
      companyName: '',
      username: '',
      email: '',
      foodReservation: false,
      ghostKitchen: false,
      homeDelivery: false,
      phone: '');

  Auth() {
    getRestaurant();
  }

  setGallery(List<String> newGallery) {
    restaurant.gallery = newGallery;
    notifyListeners();
  }

  setBusinessPhoto(String businessPhoto) {
    restaurant.businessPhoto = businessPhoto;
    notifyListeners();
  }

  toggleVariant() {
    notifyListeners();
  }

  getRestaurant() async {
    final deviceToken = await FirebaseMessaging.instance.getToken().toString();
    if (auth.currentUser == null) return;
    String userId = auth.currentUser!.uid;
    firestore.collection("restaurants").doc(userId).snapshots().listen((event) {
      if (!event.exists) {
        return;
      }
      restaurant = Restaurant(
        variants: List<String>.from(event["variants"]),
        days: List<String>.from(event["days"]),
        costs: List<int>.from(event["costs"]),
        deviceToken: deviceToken,
        address: event["address"],
        name: event['name'],
        categories: List<String>.from(event["categories"]),
        gallery: List<String>.from(event["gallery"]),
        lng: event["long"],
        lat: event['lat'],
        restaurantId: event.id,
        businessPhoto: event['businessPhoto'],
        tableReservation: event['tableReservation'],
        cash: event['cash'],
        momo: event['momo'],
        specialOrders: event['specialOrders'],
        avatar: event['avatar'],
        closingTime: event['closingTime'],
        openingTime: event['openTime'],
        companyName: event['companyName'],
        username: event['username'],
        email: event['email'],
        foodReservation: event['foodReservation'],
        ghostKitchen: event['ghostKitchen'],
        homeDelivery: event['homeDelivery'],
        comments: event['comments'],
        likes: event['likes'],
        deliveryCost: event['deliveryCost'],
        followers: event['followers'],
        phone: event['phone'] ?? '',
      );
      debugPrint("loaded the name: " + event['name']);
    });
  }

  updateBool(String val, bool update) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(val, update);

    notifyListeners();
  }

  updateString(String val, String update) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(val, update);
    notifyListeners();
  }

  clear() {
    this.restaurant = Restaurant(
        deviceToken: '',
        address: '',
        gallery: [],
        days: [],
        name: "",
        categories: [],
        costs: [],
        variants: [],
        lng: 0.0,
        lat: 0.0,
        restaurantId: "",
        businessPhoto: '',
        tableReservation: false,
        cash: false,
        momo: false,
        specialOrders: false,
        avatar: '',
        closingTime: '',
        openingTime: '',
        companyName: '',
        username: '',
        email: '',
        foodReservation: false,
        ghostKitchen: false,
        homeDelivery: false,
        phone: '');
  }
}
