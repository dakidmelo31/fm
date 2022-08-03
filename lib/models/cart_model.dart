class CartModel {
  final String name;
  final String id;
  final String restaurantId;
  final String image;
  final int quantity;
  int? price;
  bool? available;

  CartModel(
      {required this.available,
      required this.image,
      required this.price,
      required this.name,
      required this.id,
      required this.restaurantId,
      required this.quantity});
}
