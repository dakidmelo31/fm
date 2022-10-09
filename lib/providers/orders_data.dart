import 'package:flutter/material.dart';
import 'package:merchants/global.dart';
import 'package:merchants/models/order_model.dart';

class OrdersData with ChangeNotifier {
  List<Order> orders = [];

  addOrder(Order order) {
    orders.add(order);
    notifyListeners();
  }

  removeOrder(String id) {
    orders.removeWhere((element) => element.orderId == id);

    firestore.collection("orderHistory").doc(id).delete().then((e) {
      debugPrint("deleted successfully");
    });
    notifyListeners();
  }

  updateOrder(String id, {required String status}) {
    firestore.collection("orderHistory").doc(id).update(
      {
        "status": status,
      },
    ).then((e) {
      debugPrint("deleted successfully");
    });
    notifyListeners();
  }
}
