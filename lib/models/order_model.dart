import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String restaurantId;
  String status;
  final List<int> quantities;
  final List<String> names;
  final List<double> prices;
  final bool homeDelivery;
  final double deliveryCost;
  final String deviceId;
  final Timestamp time;
  final String userId;
  final String userToken;
  String orderId = '';
  final int friendlyId;
  Order({
    required this.restaurantId,
    required this.userToken,
    required this.status,
    required this.quantities,
    required this.names,
    required this.prices,
    required this.homeDelivery,
    required this.deviceId,
    required this.deliveryCost,
    required this.time,
    required this.friendlyId,
    required this.userId,
  });

  Order copyWith({
    String? restaurantId,
    String? status,
    List<int>? quantities,
    List<String>? names,
    List<double>? prices,
    bool? homeDelivery,
    double? deliveryCost,
    Timestamp? time,
    String? userId,
    int? friendlyId,
  }) {
    return Order(
      restaurantId: restaurantId ?? this.restaurantId,
      userToken: userToken,
      status: status ?? this.status,
      friendlyId: friendlyId ?? this.friendlyId,
      quantities: quantities ?? this.quantities,
      names: names ?? this.names,
      deviceId: deviceId,
      prices: prices ?? this.prices,
      homeDelivery: homeDelivery ?? this.homeDelivery,
      deliveryCost: deliveryCost ?? this.deliveryCost,
      time: time ?? this.time,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'restaurantId': restaurantId});
    result.addAll({'friendlyId': friendlyId});
    result.addAll({'status': status});
    result.addAll({'quantities': quantities});
    result.addAll({'names': names});
    result.addAll({'prices': prices});
    result.addAll({'userToken': userToken});
    result.addAll({'homeDelivery': homeDelivery});
    result.addAll({'deliveryCost': deliveryCost});
    result.addAll({'time': FieldValue.serverTimestamp()});
    result.addAll({'userId': userId});

    return result;
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      restaurantId: map['restaurantId'] ?? '',
      userToken: map['userToken'] ?? '',
      status: map['status'] ?? '',
      deviceId: map['deviceId'] ?? '',
      friendlyId: map['friendlyId'] ?? 1020,
      quantities: List<int>.from(map['quantities']),
      names: List<String>.from(map['names']),
      prices: List<double>.from(map['prices']),
      homeDelivery: map['homeDelivery'] ?? false,
      deliveryCost: map['deliveryCost']?.toInt() ?? 0,
      time: map['time'],
      userId: map['userId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Order(restaurantId: $restaurantId, status: $status, quantities: $quantities, names: $names, prices: $prices, homeDelivery: $homeDelivery, deliveryCost: $deliveryCost, time: $time, userId: $userId)';
  }
}
