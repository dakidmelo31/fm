class ReservationModel {
  final String type;
  final String restaurantName;
  final String restaurantId;
  final String restaurantImage;
  final String restaurantLocation;
  final int total;
  final bool status;
  final String time;
  final DateTime date;
  ReservationModel(
      {
        required this.status,
        required this.restaurantName,
        required this.restaurantId,
        required this.restaurantImage,
        required this.restaurantLocation,
        required this.time,
        required this.total,
        required this.date,
        required this.type,
  });
}