import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/models/overview.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:merchants/pages/all_messages.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../providers/auth_provider.dart';

class ChatHome extends StatefulWidget {
  ChatHome({Key? key, required this.stream, required this.restaurant})
      : super(key: key);
  final Restaurant restaurant;
  final stream;

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> with TickerProviderStateMixin {
  late var chatStream;
  late var orderStream;
  bool callUpdate = false;
  late AnimationController _animation;

  List<Overview> overviews = [];

  late Animation<double> animation;
  @override
  void initState() {
    _animation = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 1200,
      ),
    );
    animation = CurvedAnimation(
        parent: _animation,
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
    super.initState();
    chatStream = firestore
        .collection("messages")
        .where("restaurantId", isEqualTo: auth.currentUser!.uid)
        .snapshots();
    orderStream = firestore
        .collection("orders")
        .where("restaurantId", isEqualTo: auth.currentUser!.uid)
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy("time", descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: size.width,
          height: size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width,
                height: 100,
                child: Center(
                  child: Card(
                    elevation: 10.0,
                    shadowColor: Colors.grey.withOpacity(.16),
                    child: Center(
                      child: Text(
                        "Messages",
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: widget.stream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError) {
                      Future.delayed(Duration(milliseconds: 2000), () {
                        setState(() {});
                      });
                      debugPrint("error found: " + snapshot.error.toString());
                      return Lottie.asset("assets/no-connection2.json",
                          width: size.width,
                          height: size.width,
                          fit: BoxFit.contain,
                          alignment: Alignment.center);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          Lottie.asset("assets/loading5.json",
                              width: size.width,
                              height: size.width,
                              fit: BoxFit.contain,
                              alignment: Alignment.center),
                        ],
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      debugPrint("done loading");
                    }
                    overviews.clear();
                    for (DocumentSnapshot item in snapshot.data.docs) {
                      if (!item.exists) {
                        continue;
                      }
                      if (!item['sentByMe'])
                        firestore
                            .collection("overviews")
                            .doc(auth.currentUser!.uid)
                            .collection("chats")
                            .doc(item.id)
                            .update({"newMessage": false}).then(
                                (value) => null); //debugPrint("now opened")
                      Timestamp? time = item['time'];
                      DateTime date =
                          time == null ? DateTime.now() : time.toDate();
                      Overview chat = Overview(
                          deviceId: item["deviceId"],
                          name: item["name"],
                          you: item["sentByMe"],
                          messageId: item.id,
                          message: item['lastMessage'],
                          photo: item['photo'],
                          time: date,
                          unreadCount: item['newMessage'],
                          userId: item.id);
                      chat.messageId = item.id;
                      overviews.add(chat);
                    }

                    return Expanded(
                        child: ListView.builder(
                      // initialItemCount: overviews.length,
                      itemCount: overviews.length,
                      physics: AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      itemBuilder: (_, index) {
                        final Overview item = overviews[index];
                        String time = DateTime.now().day - item.time.day > 0
                            ? item.time.day.toString() +
                                "/" +
                                item.time.month.toString() +
                                "/" +
                                item.time.year.toString()
                            : timeAgo.format(item.time);
                        return Card(
                            shadowColor: ColorTween(
                                    begin: Colors.grey,
                                    end: Colors.grey.withOpacity(0.0))
                                .animate(animation)
                                .value,
                            elevation: lerpDouble(0.0, 8.0, animation.value),
                            child: InkWell(
                              onTap: () async {
                                if (callUpdate)
                                  firestore
                                      .collection("messages")
                                      .where("sender", isEqualTo: item.userId)
                                      .where("restaurantId",
                                          isEqualTo: auth.currentUser!.uid)
                                      .get()
                                      .then((value) async {
                                    for (var data in value.docs) {
                                      String docId = data.id;
                                      firestore
                                          .collection("messages")
                                          .doc(docId)
                                          .update({"opened": true}).then(
                                              (value) =>
                                                  debugPrint("message Opened"));
                                    }
                                  });
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration:
                                        Duration(milliseconds: 1500),
                                    reverseTransitionDuration:
                                        Duration(milliseconds: 200),
                                    pageBuilder:
                                        (_, animation, anotherAnimation) {
                                      return AllMessages(
                                          restaurant: widget.restaurant,
                                          chatsStream: chatStream,
                                          customer: item,
                                          ordersStream: orderStream,
                                          callUpdate: callUpdate);
                                    },
                                    transitionsBuilder: (_, animation,
                                        anotherAnimation, child) {
                                      animation = CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.fastLinearToSlowEaseIn,
                                          reverseCurve: Curves.fastOutSlowIn);
                                      return Align(
                                        alignment: Alignment.centerRight,
                                        child: SizeTransition(
                                          sizeFactor: animation,
                                          axis: Axis.horizontal,
                                          axisAlignment: 0.0,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                ).then((value) {
                                  firestore
                                      .collection("messages")
                                      .where("sender", isEqualTo: item.userId)
                                      .where("restaurantId",
                                          isEqualTo: auth.currentUser!.uid)
                                      .get()
                                      .then((value) async {
                                    for (var data in value.docs) {
                                      String docId = data.id;
                                      firestore
                                          .collection("messages")
                                          .doc(docId)
                                          .update({"opened": true}).then(
                                              (value) =>
                                                  debugPrint("message Opened"));
                                    }
                                  });
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: item.photo,
                                        errorWidget: (_, __, ___) =>
                                            Lottie.asset(
                                                "assets/no-connection2.json"),
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                        fadeInCurve:
                                            Curves.fastLinearToSlowEaseIn,
                                        filterQuality: FilterQuality.high,
                                        height: size.width * .12,
                                        width: size.width * .12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * .6,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black,
                                              fontSize: 18.0,
                                            ),
                                            overflow: TextOverflow.ellipsis),
                                        item.you
                                            ? RichText(
                                                text: TextSpan(
                                                    text: 'You',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: ': ' +
                                                              item.message,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                          recognizer:
                                                              TapGestureRecognizer()
                                                                ..onTap = () {
                                                                  // navigate to desired screen
                                                                })
                                                    ]),
                                              )
                                            : Text(
                                                item.message,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        time,
                                        style: TextStyle(
                                            fontSize: 10.0, color: Colors.grey),
                                      ),
                                      item.unreadCount == 0
                                          ? Container()
                                          : ClipOval(
                                              child: Container(
                                                width: 15.0,
                                                height: 15.0,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            )
                                    ],
                                  ),
                                ]),
                              ),
                            ));
                      },
                    ));
                  })
            ],
          ),
        ),
      ),
    );
  }
}
