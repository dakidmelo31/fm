import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merchants/global.dart';
import 'package:merchants/models/restaurants.dart';

import '../themes/light_theme.dart';

class HomeDeliveryVariants extends StatefulWidget {
  const HomeDeliveryVariants({Key? key, required this.restaurant})
      : super(key: key);
  final Restaurant restaurant;

  @override
  State<HomeDeliveryVariants> createState() => _HomeDeliveryVariantsState();
}

class _HomeDeliveryVariantsState extends State<HomeDeliveryVariants> {
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late List<String> variants;
  late List<int> costs;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    variants = widget.restaurant.variants;
    costs = widget.restaurant.costs;
    _locationController = TextEditingController();
    _priceController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightGreen,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.fastLinearToSlowEaseIn,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text("Home delivery Locations",
                    style: Primary.bigWhiteHeading),
              ),
            ),
            for (var i = 0; i < variants.length; i++)
              ListTile(
                onTap: () {
                  setState(() {
                    _locationController.text = variants[i];
                    _priceController.text = costs[i].toInt().toString();
                  });
                },
                title: Text(
                  variants[i],
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(costs[i].toString() + " CFA"),
                trailing: IconButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      int index = variants
                          .indexWhere((element) => element == variants[i]);
                      costs.removeAt(index);
                      variants.removeAt(index);
                    });
                  },
                  icon: Icon(
                    Icons.delete_forever_rounded,
                  ),
                ),
              ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 10),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter the location";
                        }
                        return null;
                      },
                      controller: _locationController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(.1),
                          hintStyle: TextStyle(color: Colors.white),
                          label: Text(
                            "Delivery Location",
                            style: TextStyle(color: Colors.white),
                          ),
                          border: InputBorder.none,
                          hintText: "E.g Dirty South or Molyko..."),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 10),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || !_isNumeric(value)) {
                          return "Enter just the number";
                        }
                        return null;
                      },
                      style: TextStyle(color: Colors.white),
                      controller: _priceController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(.1),
                          hintStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                          label: Text(
                            "Cost of Delivery",
                            style: TextStyle(color: Colors.white),
                          ),
                          hintText: "E.g 250..."),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: FloatingActionButton.large(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    HapticFeedback.heavyImpact();

                    if (_formKey.currentState!.validate()) {
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(msg: "Variant added");
                      setState(() {
                        if (variants.contains(_locationController.text
                            .toString()
                            .toLowerCase())) {
                          debugPrint("found something");
                          int index = variants.lastIndexOf(_locationController
                              .text
                              .toString()
                              .toLowerCase());
                          costs.removeAt(index);
                          variants.removeAt(index);
                        } else {
                          variants.add(_locationController.text
                              .toString()
                              .toLowerCase());
                          costs
                              .add(int.parse(_priceController.text.toString()));
                        }
                        _locationController.text = "";
                        _priceController.text = "";
                      });
                    }
                  },
                  child: Icon(
                    Icons.add,
                  )),
            ),
            
            Card(
              color: Colors.white,
              elevation: 20.0,
              shadowColor: Colors.grey.withOpacity(.75),
              margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
              child: InkWell(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  DocumentReference documentReference = firestore
                      .collection("restaurants")
                      .doc(widget.restaurant.restaurantId);
                  firestore.runTransaction((transaction) async {
                    DocumentSnapshot snap =
                        await transaction.get(documentReference);
                    if (!snap.exists) {
                      throw Exception("Document does not exists");
                    }
                    transaction.update(documentReference,
                        {"variants": variants, "costs": costs});
                  }).then((value) => Fluttertoast.showToast(
                      msg: "Saved Successfully",
                      backgroundColor: Colors.lightGreen));
                },
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Save your changes online",
                        ),
                        Icon(
                          Icons.update_rounded,
                        )
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
