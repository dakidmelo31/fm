import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merchants/global.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:merchants/providers/global_data.dart';

class SellingDays extends StatefulWidget {
  const SellingDays({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  State<SellingDays> createState() => _SellingDaysState();
}

class _SellingDaysState extends State<SellingDays>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _days = widget.restaurant.days;
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  late List<String> _days;
  List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          width: size.width,
          height: 140,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Your Selling days"),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: days
                      .map((e) => Card(
                            color: _days.contains(e)
                                ? Colors.lightGreen
                                : Colors.white,
                            elevation: 10,
                            shadowColor: Colors.grey.withOpacity(.5),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                setState(() {
                                  if (_days.contains(e)) {
                                    _days.remove(e);
                                  } else {
                                    _days.add(e);
                                  }
                                });
                                debugPrint("toggle day");
                                debugPrint(widget.restaurant.days.toString() +
                                    " and days: " +
                                    _days.toString());
                                if (widget.restaurant.days == _days) {
                                  _controller.forward();
                                } else {
                                  _controller.reverse();
                                }
                              },
                              child: SizedBox(
                                height: 50,
                                child: ClipOval(
                                  child: AnimatedPadding(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.fastLinearToSlowEaseIn,
                                    padding: EdgeInsets.all(
                                        _days.contains(e) ? 8.0 : 4.0),
                                    child: Center(
                                        child: Text(e,
                                            style: TextStyle(
                                                color: !_days.contains(e)
                                                    ? Colors.black
                                                    : Colors.white))),
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList()),
              AnimatedBuilder(
                  animation: _controller,
                  builder: ((context, child) {
                    return SizeTransition(
                        sizeFactor: _controller,
                        axis: Axis.horizontal,
                        child: widget.restaurant.days != _days
                            ? SizedBox(height: 0, width: 0)
                            : TextButton.icon(
                                icon: Icon(Icons.save_alt),
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  DocumentReference documentReference =
                                      firestore
                                          .collection("restaurants")
                                          .doc(auth.currentUser!.uid);

                                  firestore.runTransaction((transaction) async {
                                    DocumentSnapshot snap = await transaction
                                        .get(documentReference);
                                    if (!snap.exists) {
                                      Fluttertoast.cancel();
                                      Fluttertoast.showToast(
                                          msg:
                                              "You're not verified yet. Login to continue");
                                      throw Exception("No User found");
                                    }
                                    transaction.update(
                                        documentReference, {"days": _days});
                                  }).then((value) {
                                    sendTopicNotification(
                                        type: "restaurant",
                                        typeId: widget.restaurant.restaurantId,
                                        image: widget.restaurant.businessPhoto,
                                        description:
                                            "We now sell on" + _days.join(", "),
                                        title: widget.restaurant.companyName +
                                            " changed selling days");
                                    Fluttertoast.cancel();
                                    Fluttertoast.showToast(
                                        msg: "Selling days Updated");
                                  });
                                },
                                label: Text("Save changes"),
                              ));
                  }))
            ],
          ),
        ),
      ],
    );
  }
}
