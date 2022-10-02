class Restaurant {
  int followers;
  final String deviceToken;

  String name,
      address,
      restaurantId,
      closingTime,
      openingTime,
      businessPhoto,
      avatar,
      email,
      phone,
      username,
      companyName;
  bool momo,
      cash,
      tableReservation,
      specialOrders,
      homeDelivery,
      foodReservation,
      ghostKitchen;
  double lat, lng;
  List<int> costs;
  List<String> categories, gallery, variants, days;
  double deliveryCost = 500;
  int comments = 0;
  int likes = 0;

  Restaurant(
      {required this.address,
      required this.name,
      required this.variants,
      required this.costs,
      required this.categories,
      required this.lng,
      required this.lat,
      required this.gallery,
      this.comments = 0,
      this.followers = 0,
      this.likes = 0,
      this.deliveryCost = 500,
      required this.restaurantId,
      required this.businessPhoto,
      required this.tableReservation,
      required this.cash,
      required this.momo,
      required this.specialOrders,
      required this.avatar,
      required this.closingTime,
      required this.openingTime,
      required this.companyName,
      required this.username,
      required this.email,
      required this.foodReservation,
      required this.ghostKitchen,
      required this.homeDelivery,
      required this.days,
      required this.phone,
      required this.deviceToken});
}
