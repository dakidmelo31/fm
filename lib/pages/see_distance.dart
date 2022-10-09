import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:merchants/models/customer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/restaurants.dart';

class SeeLocation extends StatefulWidget {
  const SeeLocation({
    Key? key,
    required this.restaurant,
    required this.customer,
  }) : super(key: key);
  final Customer customer;
  final Restaurant restaurant;

  @override
  State<SeeLocation> createState() => _SeeLocationState();
}

class _SeeLocationState extends State<SeeLocation> {
  late CameraPosition myPosition;
  late GoogleMapController _mapController;
  @override
  void initState() {
    initPoints();
    myPosition = CameraPosition(
      target: LatLng(widget.restaurant.lat, widget.restaurant.lng),
      zoom: 14.0,
      tilt: 50,
    );
    // debugPrint("source: Lat " + source.latitude.toString());
    // debugPrint("source: Lng " + source.latitude.toString());
    // debugPrint("Destination: Lat " + destination.latitude.toString());
    // debugPrint("Destination: Lng " + destination.longitude.toString());

    super.initState();
  }

  double lat = 0.0, lng = 0.0;

  Future<void> getLocation() async {
    var locationStatus = await Permission.location.status;
    if (locationStatus.isGranted) {
      debugPrint("granted");
    } else if (locationStatus.isDenied) {
      debugPrint("Not granted");
      await [Permission.location].request();
    } else if (locationStatus.isPermanentlyDenied) {
      openAppSettings().then((value) {
        setState(() {});
      });
    }
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    var lastPosition = await Geolocator.getLastKnownPosition();
    print("position is $lastPosition");

    setState(() {
      lat = position.latitude;
      lng = position.longitude;
    });
    debugPrint("latitude: $lat, and logitude: $lng");
  }

  initPoints() {
    source = LatLng(widget.restaurant.lat, widget.restaurant.lng);

    customerPosition = LatLng(widget.customer.lat, widget.customer.lng);
  }

  // static const String googleApiKey = "AIzaSyBW83ZgIKbFvy9Dzc6AkzQjd4ScIpXDrUM";

  late LatLng source;
  late LatLng customerPosition;
  List<LatLng> polylineCoordinates = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text("Location"),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _mapController
                          .moveCamera(CameraUpdate.newLatLng(customerPosition));
                    });
                  },
                  child: Text(
                    "You",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _mapController.moveCamera(
                        CameraUpdate.newLatLng(myPosition.target),
                      );
                    });
                  },
                  child: Text(
                    "Customer",
                    style: TextStyle(color: Colors.lightGreen),
                  ),
                ),
              ]),
          body: Stack(children: [
            Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  width: size.width,
                  height: size.height,
                  child: GoogleMap(
                    buildingsEnabled: false,
                    initialCameraPosition: myPosition,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    trafficEnabled: false,
                    indoorViewEnabled: false,
                    onMapCreated: (controller) => _mapController = controller,
                    polylines: {
                      Polyline(
                        polylineId: PolylineId("route"),
                        points: polylineCoordinates,
                        width: 6,
                        color: Colors.lightGreen,
                        visible: true,
                      ),
                    },
                    markers: {
                      Marker(
                          infoWindow: InfoWindow(title: "You"),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueOrange),
                          markerId: MarkerId('markerId'),
                          position: myPosition.target),
                      Marker(
                          infoWindow: InfoWindow(
                              title: widget.customer.name + " (Customer)"),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed),
                          markerId: MarkerId('markerId'),
                          position: customerPosition),
                    },
                  ),
                ))
          ])),
    );
  }
}
