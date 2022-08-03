import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Food with ChangeNotifier {
  String name;
  bool available, verified;
  String restaurantId;
  String description;
  String foodId;
  double price;
  String image;
  List<String> compliments;
  List<String> categories;
  List<String> gallery;
  List<String> ingredients;
  int averageRating;
  String duration;
  final int likes;
  final int comments;

  Food({
    required this.description,
    required this.ingredients,
    required this.verified,
    required this.likes,
    required this.comments,
    required this.name,
    required this.available,
    required this.price,
    required this.categories,
    required this.restaurantId,
    required this.foodId,
    required this.image,
    required this.averageRating,
    required this.duration,
    required this.gallery,
    required this.compliments,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "available": available,
      "price": price,
      "likes": likes,
      "comments": comments,
      "description": description,
      "verified": false,
      "duration": duration,
      "categories": categories,
      "restaurantId": restaurantId,
      "image": image,
      "gallery": gallery,
      "accessories": compliments,
      "averageRating": averageRating,
      "ingredients": ingredients,
      "created_time": FieldValue.serverTimestamp()
    };
  }

  factory Food.fromJson(Map<dynamic, dynamic> json) => Food(
      description: "",
      foodId: "",
      compliments: json['accessories'],
      available: json['available'],
      averageRating: json['averageRating'], //Ratings.fromJson(json['ratings'])
      categories: json["categories"],
      duration: json['duration'],
      gallery: json['gallery'],
      image: json['image'],
      name: json['name'],
      likes: json['likes'],
      comments: json['comments'],
      price: json['price'],
      verified: json['verified'],
      ingredients: json['ingredients'],
      restaurantId: json['restaurantId']);
}
