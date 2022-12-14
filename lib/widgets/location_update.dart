import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:merchants/global.dart';

import '../models/restaurants.dart';
import '../providers/global_data.dart';
import '../themes/light_theme.dart';

class LocationUpdate extends StatefulWidget {
  const LocationUpdate({required this.restaurant});
  final Restaurant restaurant;

  @override
  State<LocationUpdate> createState() => _LocationUpdateState();
}

class _LocationUpdateState extends State<LocationUpdate>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late GoogleMapController _googleMapController;
  late Marker _marker;
  @override
  void initState() {
    _marker = Marker(
        markerId: MarkerId(auth.currentUser!.uid),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(widget.restaurant.lat, widget.restaurant.lng),
        infoWindow: InfoWindow(
            onTap: () {
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                  msg:
                      "Change this your location by long pressing new location.",
                  toastLength: Toast.LENGTH_LONG);
            },
            title: "Current Restaurant Position"));
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: GoogleMap(
              onTap: (details) {
                _animationController.reverse();
              },
              onLongPress: (details) => setState(() {
                _animationController.forward();
                _marker = Marker(
                    markerId: MarkerId(auth.currentUser!.uid),
                    icon: BitmapDescriptor.defaultMarker,
                    position: LatLng(details.latitude, details.longitude),
                    infoWindow: InfoWindow(
                        onTap: () {
                          Fluttertoast.cancel();
                          Fluttertoast.showToast(
                              msg:
                                  "Change this your location by long pressing new location.",
                              toastLength: Toast.LENGTH_LONG);
                        },
                        title: "Current Restaurant Position"));
                _googleMapController
                    .animateCamera(CameraUpdate.newLatLng(details));
              }),
              onMapCreated: (controller) => _googleMapController = controller,
              initialCameraPosition: CameraPosition(
                  target: LatLng(widget.restaurant.lat, widget.restaurant.lng),
                  bearing: 0,
                  tilt: 50,
                  zoom: 15.0),
              buildingsEnabled: true,
              mapToolbarEnabled: true,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: false,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              markers: {_marker},
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 68.0),
              child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      switchInCurve: Curves.fastLinearToSlowEaseIn,
                      switchOutCurve: Curves.fastLinearToSlowEaseIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Card(
                          elevation: 15,
                          color:
                              ColorTween(begin: Colors.black, end: Colors.white)
                                  .animate(_animationController)
                                  .value,
                          shadowColor: Colors.grey.withOpacity(.2),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                _animationController.isCompleted
                                    ? "Tap to hide details"
                                    : "Long press to select location",
                                style: TextStyle(
                                    color: ColorTween(
                                            begin: Colors.white,
                                            end: Colors.black)
                                        .animate(_animationController)
                                        .value)),
                          )),
                    );
                  }),
            ),
          ),
          AnimatedBuilder(
              animation: _animationController,
              builder: (builder, child) {
                return Positioned(
                  child: BackButton(
                    color: Colors.black,
                  ),
                  top: 15.0,
                  left: 20.0,
                );
              }),
          AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                    height: size.height * .42,
                    width: size.width,
                    left: 0,
                    bottom: -size.height *
                        (1 -
                            CurvedAnimation(
                                    parent: _animationController,
                                    curve: Curves.fastLinearToSlowEaseIn,
                                    reverseCurve: Curves.decelerate)
                                .value),
                    child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 150.0,
                      color: Colors.white,
                      shadowColor: Colors.black,
                      child: SizedBox(
                          width: size.width,
                          child: Column(
                            children: [
                              ScaleTransition(
                                scale: CurvedAnimation(
                                    curve: Curves.elasticInOut,
                                    parent: _animationController),
                                child: lottie.Lottie.asset(
                                  "assets/location.json",
                                  animate: true,
                                  filterQuality: FilterQuality.high,
                                  options: lottie.LottieOptions(
                                      enableMergePaths: true),
                                  fit: BoxFit.contain,
                                  height: 100,
                                  alignment: Alignment.center,
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "You have changed the position of your business on the map. Would you like to save changes?",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18.0),
                                ),
                              ),
                              Spacer(),
                              Card(
                                color: Colors.lightGreen,
                                elevation: 20.0,
                                shadowColor: Colors.grey.withOpacity(.25),
                                margin: EdgeInsets.only(
                                    bottom: 35.0,
                                    left: 5.0,
                                    right: 5.0,
                                    top: 15.0),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.heavyImpact();
                                    DocumentReference documentReference =
                                        firestore
                                            .collection("restaurants")
                                            .doc(auth.currentUser!.uid);
                                    firestore
                                        .runTransaction((transaction) async {
                                      DocumentSnapshot snap = await transaction
                                          .get(documentReference);
                                      if (!snap.exists) {
                                        throw Exception("No restaurant found");
                                      }
                                      transaction.update(documentReference, {
                                        "lat": _marker.position.latitude,
                                        "long": _marker.position.longitude
                                      });
                                    }).then((value) {
                                      Fluttertoast.cancel();
                                      Fluttertoast.showToast(
                                          msg: "Updated successfully");
                                      sendTopicNotification(
                                          type: "restaurant",
                                          typeId:
                                              widget.restaurant.restaurantId,
                                          image:
                                              widget.restaurant.businessPhoto,
                                          description:
                                              'We have updated our Business location',
                                          title: widget.restaurant.companyName +
                                              " changed location");
                                    });
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text("Save Changes",
                                              style: Primary.whiteText),
                                          Icon(
                                            Icons.update_rounded,
                                            color: Colors.white,
                                          )
                                        ],
                                      )),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          height: double.infinity),
                    ));
              })
        ],
      ),
    );
  }
}
