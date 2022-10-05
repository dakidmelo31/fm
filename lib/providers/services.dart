import 'package:flutter/cupertino.dart';

import '../global.dart';
import '../models/service.dart';

class ServicesData with ChangeNotifier {
  List<ServiceModel> services = [];

  ServicesData() {
    loadServices();
  }
  Future<void> loadServices() async {
    firestore
        .collection("services")
        .where("restaurantId", isEqualTo: auth.currentUser!.uid)
        .orderBy("created_time", descending: true)
        .snapshots()
        .listen((event) {
      debugPrint("going through services now");
      services.clear();
      for (var serviceData in event.docs) {
        String documentID = serviceData.id;

        debugPrint(serviceData.id);
        ServiceModel service = ServiceModel(
          verified: serviceData['verified'],
          serviceId: documentID,
          likes: convertInt(serviceData['likes']),
          description: serviceData['description'],
          comments: convertInt(serviceData['comments']),
          name: serviceData["name"],
          negociable: serviceData["negociable"],
          image: serviceData['image'],
          cost: serviceData['cost'], //double.parse(data['price'])
          restaurantId: serviceData['restaurantId'],
          gallery: List<String>.from(serviceData['gallery']),
          duration: serviceData['duration'],
          coverage: serviceData['coverage'],
        );
        services.add(service);
      }
    });
    notifyListeners();
  }

  updateGallery({required List<String> gallery, required String serviceId}) {
    services[services
            .lastIndexWhere((element) => element.serviceId == serviceId)]
        .gallery = gallery;
    notifyListeners();
  }

  void clear() {
    this.services.clear();
  }

  void setImage({required String image, required String serviceId}) {
    services[services
            .lastIndexWhere((element) => element.serviceId == serviceId)]
        .image = image;

    notifyListeners();
  }
}
