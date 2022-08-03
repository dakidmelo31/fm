class RestaurantModel {
  final String name;
  final String address;
  final double lat;
  final double long;
  final int totalMeals;
  final int totalOrders;
  final double averageRating;
  final int totalRating;
  final String id;
  final String image;
  final String url;
  final bool homeDelivery;
  final bool ghostKitchen;
  final bool specialOrders;
  final String openingTime;
  final String closingTime;
  final String phone;
  final bool reservable;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.image,
    required this.phone,
    required this.address,
    required this.url,
    required this.openingTime,
    required this.specialOrders,
    required this.ghostKitchen,
    required this.lat,
    required this.long,
    required this.closingTime,
    required this.reservable,
    required this.homeDelivery,
    required this.totalMeals,
    required this.totalOrders,
    required this.totalRating,
    required this.averageRating,
  });
}
