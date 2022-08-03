class UserModel {
  final String name;
  final String companyName;
  final String companyLogo;
  final String address;
  final String website;
  final String openTime;
  final String closeTime;
  final String phone;
  final String email;
  final String password;
  final bool homeDelivery;
  final bool tableReservation;
  final bool ghostKitchen;
  final bool foodReservation;
  final bool specialOrders;
  final bool cashPayment;
  final bool momo;

  UserModel(
      this.name,
      this.companyName,
      this.companyLogo,
      this.address,
      this.website,
      this.openTime,
      this.closeTime,
      this.phone,
      this.email,
      this.password,
      this.homeDelivery,
      this.tableReservation,
      this.ghostKitchen,
      this.foodReservation,
      this.specialOrders,
      this.cashPayment,
      this.momo);

  // UserModel.fromData(Map<String, dynamic> json)
  //     : name = json['name'],
  //       companyName = json['companyName'],
  //       companyLogo = json['companyLogo'],
  //       website = json['website'],
  //       phone = json['phone'],
  //       email = json['email'],
  //       openTime = json['openTime'],
  //       closeTime = json['closeTime'],
  //       homeDelivery = json['homeDelivery'],
  //       tableReservation = json['tableReservation'],
  //       ghostKitchen = json['ghostKitchen'],
  //       foodReservation = json['foodReservation'],
  //       specialOrders = json['specialOrders'],
  //       cashPayment = json['cashPayment'],
  //       momo = json['momo'];

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "companyName": companyName,
      "companyLogo": companyLogo,
      "website": website,
      "email": email,
      "phone": phone,
      "openTime": openTime,
      "closeTime": closeTime,
      "homeDelivery": homeDelivery,
      "tableReservation": tableReservation,
      "foodReservation": foodReservation,
      "ghostKitchen": ghostKitchen,
      "specialOrders": specialOrders,
      "cashPayment": cashPayment,
      "momo": momo,
    };
  }
}
