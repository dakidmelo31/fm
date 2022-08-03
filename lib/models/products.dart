class Products {
  Products({
    this.data,
    this.createdDate,
  });

  List<ProductItems>? data;
  dynamic createdDate;

  factory Products.fromJson(Map<String, dynamic> json) => Products(
        data: List<ProductItems>.from(
            json["data"].map((x) => ProductItems.fromJson(x))),
        createdDate: json["createdDate"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "createdDate": createdDate
      };
}

class ProductItems {
  String? accessories;
  String? name;
  double? price;
  String? gallery;
  String? img;
  int? averageRating;
  bool? available;
  String? duration;

  ProductItems(
      {this.price,
      this.name,
      this.available,
      this.duration,
      this.accessories,
      this.averageRating,
      this.img});

  ProductItems.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    available = json['available'];
    accessories = json['accessories'];
    img = json['img'];
    averageRating = json['averageRating'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['available'] = available;
    data['accessories'] = accessories;
    data['img'] = img;
    data['duration'] = duration;
    data['averageRating'] = averageRating;
    data['price'] = price;
    data['name'] = name;
    return data;
  }
}
