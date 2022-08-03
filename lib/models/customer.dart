// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Customer {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String deviceId;
  final String phone;
  final String image;
  Customer({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.deviceId,
    required this.phone,
    required this.image,
  });

  Customer copyWith({
    String? name,
    String? address,
    double? lat,
    double? long,
    String? deviceId,
    String? phone,
    String? image,
  }) {
    return Customer(
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: long ?? this.lng,
      deviceId: deviceId ?? this.deviceId,
      phone: phone ?? this.phone,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'address': address,
      'lat': lat,
      'long': lng,
      'deviceId': deviceId,
      'phone': phone,
      'image': image,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'] as String,
      address: map['address'] as String,
      lat: map['lat'] as double,
      lng: map['long'] as double,
      deviceId: map['deviceId'] as String,
      phone: map['phone'] as String,
      image: map['image'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Customer.fromJson(String source) =>
      Customer.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Customer(name: $name, address: $address, lat: $lat, long: $lng, deviceId: $deviceId, phone: $phone, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Customer &&
        other.name == name &&
        other.address == address &&
        other.lat == lat &&
        other.lng == lng &&
        other.deviceId == deviceId &&
        other.phone == phone &&
        other.image == image;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        address.hashCode ^
        lat.hashCode ^
        lng.hashCode ^
        deviceId.hashCode ^
        phone.hashCode ^
        image.hashCode;
  }
}
