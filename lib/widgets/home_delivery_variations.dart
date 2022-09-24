import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../themes/light_theme.dart';

class HomeDeliveryVariants extends StatefulWidget {
  const HomeDeliveryVariants({Key? key}) : super(key: key);

  @override
  State<HomeDeliveryVariants> createState() => _HomeDeliveryVariantsState();
}

class _HomeDeliveryVariantsState extends State<HomeDeliveryVariants> {
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  Map<String, String> list = {};

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _locationController = TextEditingController();
    _priceController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightGreen,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: Column(
        children: [
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
                      if (value == null || _isNumeric(value)) {
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
          Card(
            color: Colors.white,
            elevation: 20.0,
            shadowColor: Colors.grey.withOpacity(.75),
            margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.heavyImpact();

                if (_formKey.currentState!.validate()) {
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(msg: "Variant added");
                }
              },
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Save Changes",
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
    );
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
