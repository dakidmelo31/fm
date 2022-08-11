// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class SettingsCard extends StatefulWidget {
  final String updateKey;
  String? initialValue;
  SettingsCard({required this.updateKey, required this.initialValue});

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _editingController = TextEditingController();

    Size size = MediaQuery.of(context).size;
    final _userData = Provider.of<Auth>(context);
    Restaurant restaurant = _userData.restaurant;
    const caption2 = TextStyle(
        color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700);
    const label = TextStyle(
        color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400);
    String initialValue =
        this.widget.initialValue == null ? "" : this.widget.initialValue!;
    String _cardName = "";
    String _field = "";
    switch (this.widget.updateKey) {
      case "companyName":
        _cardName = "Business Name";
        _field = "companyName";
        break;
      case "email":
        _cardName = "Email";
        break;
      case "address":
        _cardName = "Business Location";
        _field = "address";
        break;
      case "phone":
        _cardName = "Phone";
        List<String> tmp = initialValue.split("");
        for (var c = 0; c < tmp.length; c++) {
          if (c == 0) {
            initialValue = "(";
          }
          if (c < 3) {
            initialValue = "$initialValue${tmp[c]}";
          }

          if (c == 3) {
            initialValue = "$initialValue${tmp[c]}) ";
          }
          if (c > 3) {
            if (c % 2 == 0) {
              initialValue = "$initialValue${tmp[c]} ";
            } else {
              initialValue = "$initialValue${tmp[c]}";
            }
          }
        }

        break;
      default:
        _cardName = "";

        break;
    }

    return Material(
      child: InkWell(
        onTap: () async {
          await showCupertinoDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              _editingController.text = "";
              return CupertinoAlertDialog(
                title: Text(
                  initialValue,
                  maxLines: 10,
                ),
                content: Material(
                  child: SizedBox(
                    width: size.width,
                    child: CupertinoTextField(
                      textInputAction: TextInputAction.send,
                      enabled: true,
                      autofocus: true,
                      placeholder: "Type new one...",
                      prefix: IconButton(
                        onPressed: () async {
                          if (_cardName.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection("restaurants")
                                .doc(restaurant.restaurantId)
                                .set({
                              _field.isNotEmpty
                                      ? _field
                                      : _cardName.toLowerCase():
                                  _editingController.text
                            });
                          }
                          Navigator.pop(context, true);
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      controller: _editingController,
                      onEditingComplete: () async {
                        if (_cardName.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection("restaurants")
                              .doc(restaurant.restaurantId)
                              .update({
                            _field.isNotEmpty
                                    ? _field
                                    : _cardName.toLowerCase():
                                _editingController.text
                          });
                        }
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                ),
                insetAnimationCurve: Curves.easeInToLinear,
                insetAnimationDuration: const Duration(milliseconds: 0),
              );
            },
          ).then((value) async {}).catchError((onError) {
            debugPrint("error found during update: $onError");
          });
        },
        child: SizedBox(
          width: size.width * .48,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _cardName,
                  style: caption2,
                ),
                Text(
                  _cardName == "Phone"
                      ? initialValue.toString()
                      : initialValue.toString(),
                  style: label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
