import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _image;
  _imageFromGallery() async {
    XFile? _myImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxHeight: 500,
      maxWidth: 350,
    );

    _image = File(_myImage!.path);
  }

  addMeal(Food food) async {
    Future uploadFile() async {
      if (_image == null) {
        return;
      }
      String url = "";

      //check if user's data already exists

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref =
          storage.ref().child("uploads/" + DateTime.now().toString());
      UploadTask uploadTask = ref.putFile(File(_image!.path));
      await uploadTask.then((res) {
        res.ref.getDownloadURL().then(
          (value) async {
            await _firestore
                .collection(restaurantPath)
                .doc(auth.currentUser!.uid)
                .set(
              {
                "name": food.name,
                "duration": food.duration,
                "price": food.price,
                "available": food.available,
                "restaurantId": auth.currentUser!.uid,
                "accessories": food.compliments.toString(),
                "averageRating": food.averageRating,
                "img": food.image,
              },
              SetOptions(merge: true),
            ).then(
              (value) async {
                debugPrint("Done Adding Meal");
              },
            ).catchError((onError) => debugPrint("found error ${onError}"));
          },
        );
      });
      return url;
    }
  }

  // Future<void> updateMeal(Map<dynamic, dynamic> data, String id) {
  //   return _firestore.collection(meals).doc(id).update( data );
  // }
}
