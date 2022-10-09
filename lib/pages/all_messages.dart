// ignore_for_file: must_be_immutable

import 'package:date_time_format/date_time_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concentric_transition/page_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/models/overview.dart';
import 'package:merchants/pages/home_screen.dart';
import 'package:merchants/transitions/transitions.dart';
import 'package:merchants/widgets/chat_bubble.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import '../global.dart';
import '../models/chats_model.dart';
import '../models/order_model.dart';
import '../models/restaurants.dart';
import '../providers/auth_provider.dart';
import '../providers/global_data.dart';
import 'order_details.dart';

class AllMessages extends StatefulWidget {
  AllMessages(
      {Key? key,
      this.callUpdate,
      this.fromPush,
      // this.customerId,
      this.customer,
      this.customerId,
      this.restaurant,
      required this.chatsStream,
      required this.ordersStream})
      : super(key: key);
  Overview? customer;
  bool? callUpdate;
  bool? fromPush;
  String? customerId;
  final chatsStream;
  final ordersStream;
  Restaurant? restaurant;

  @override
  State<AllMessages> createState() => _AllMessagesState();
}

class _AllMessagesState extends State<AllMessages> {
  late var _chatStream;
  late var _orderStream;

  List<Order> ordersList = [];
  bool checkId({required String orderId}) {
    bool answer = false;
    for (Order item in ordersList) {
      if (item.orderId == orderId) {
        answer = true;
        break;
      }
    }
    return answer;
  }

  late Overview? customer;

  deliveredBy() async {
    if (widget.customerId != null) {
      await firestore
          .collection("overviews")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("chats")
          .doc(widget.customerId)
          .get()
          .then((DocumentSnapshot item) {
        debugPrint("Customer Loading");

        Timestamp? time = item['time'];
        DateTime date = time == null ? DateTime.now() : time.toDate();
        Overview chat = Overview(
            name: item["name"],
            deviceId: item["deviceId"],
            you: item["sentByMe"],
            messageId: item.id,
            message: item['lastMessage'],
            photo: item['photo'],
            time: date,
            unreadCount: item['newMessage'],
            userId: item.id);
        chat.messageId = item.id;
        widget.customer = chat;
        debugPrint("total information is: " + chat.toString());
        return chat;
      }).then((value) {
        SchedulerBinding.instance.addPostFrameCallback((timestamp) {
          setState(() {
            debugPrint("Customer Created");
            customer = value;
          });
        });
      });

      var dat = await firestore
          .collection("restaurants")
          .doc(auth.currentUser!.uid)
          .get();
      if (dat.exists) {
        var event = dat.data() as Map<String, dynamic>;
        // int doubleCost = int.parse("${event["deliveryCost"]}");
        // int cost = doubleCost.toInt();
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Container(
        //     width: size.width,
        //     height: size.height,
        //     color: Colors.white,
        //     child: Center(
        //       child: Lottie.asset("assets/loading5.json"),
        //     ),
        //   );
        // }
        Restaurant restaurant = Restaurant(
          gallery: List<String>.from(event["gallery"]),
          days: List<String>.from(event["days"]),
          variants: List<String>.from(event["variants"]),
          costs: List<int>.from(event["costs"]),
          name: event["name"] ?? "",
          deviceToken: event["deviceToken"],
          address: event["address"] ?? "",
          companyName: event["companyName"] ?? "",
          businessPhoto: event["businessPhoto"] ?? "",
          tableReservation: event["tableReservation"] ?? "",
          closingTime: event["closingTime"] ?? "",
          categories: List<String>.from(event["categories"]),
          avatar: event["avatar"] ?? "",
          email: event["email"] ?? "",
          foodReservation: event["foodReservation"] ?? false,
          ghostKitchen: event["ghostKitchen"] ?? false,
          homeDelivery: event["homeDelivery"] ?? false,
          momo: event["momo"] ?? false,
          specialOrders: event["specialOrders"] ?? false,
          lat: event["lat"] ?? 0.0,
          lng: event["long"] ?? 0.0,
          openingTime: event['openTime'] ?? "",
          phone: event['phone'] ?? "",
          username: event['username'] ?? "",
          restaurantId: dat.id,
          deliveryCost: event['deliveryCost'],
          comments: event['comments'] ?? "",
          followers: event['followers'] ?? 0,
          likes: event['likes'] ?? 0,
          cash: event["cash"] ?? false,
        );
        setState(() {
          widget.restaurant = restaurant;
        });
      }
    } else {
      debugPrint("Nothing to load");
    }
  }

  @override
  void initState() {
    deliveredBy();
    customer = widget.customer;
    timeAgo.setDefaultLocale("en");
    super.initState();
    if (customer != null) {
      _chatStream = firestore
          .collection("messages")
          .where("userId", isEqualTo: customer!.userId)
          .where("restaurantId",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("lastMessageTime", descending: false)
          .snapshots();
      _orderStream = firestore
          .collection("orders")
          .where("userId", isEqualTo: customer!.userId)
          .where("restaurantId",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("time", descending: true)
          .snapshots();
    } else {
      debugPrint("from push notification");
      _chatStream = firestore
          .collection("messages")
          .where("userId", isEqualTo: widget.customerId!)
          .where("restaurantId",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("lastMessageTime", descending: false)
          .snapshots();
      _orderStream = firestore
          .collection("orders")
          .where("userId", isEqualTo: widget.customerId!)
          .where("restaurantId",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("time", descending: true)
          .snapshots();
    }
  }

  String lastMessage = "";
  bool sentByMe = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (widget.customerId != null) {
          Navigator.pushReplacement(
              context, HorizontalSizeTransition(child: Home()));
        }
        if (lastMessage.isNotEmpty) {
          updateOverview(
              id: widget.customer!.userId,
              message: lastMessage,
              sentByMe: true);
          debugPrint("updating overview: $lastMessage");
        } else
          debugPrint("Nothing to update overview with");
        return true;
      },
      child: Stack(
        children: [
          Image.asset("assets/app/bg8.jpg",
              width: size.width,
              height: size.height,
              alignment: Alignment.center,
              fit: BoxFit.cover),
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: customer == null
                  ? Container(
                      alignment: Alignment.center,
                      width: size.width,
                      height: size.height,
                      child: Lottie.asset(
                        "assets/loading5.json",
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        reverse: true,
                      ),
                    )
                  : GestureDetector(
                      onTap: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      child: Column(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                              stream: _orderStream,
                              builder: (context, AsyncSnapshot ordersnaps) {
                                if (ordersnaps.hasError) {
                                  return Center(
                                    child: Text("please log back in"),
                                  );
                                }

                                if (ordersnaps.connectionState ==
                                    ConnectionState.waiting) {
                                  return Lottie.asset("assets/loading7.json",
                                      width: size.width,
                                      height: 80,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center);
                                }

                                debugPrint(" total orders: " +
                                    ordersnaps.data!.docs.length.toString());
                                for (var doc in ordersnaps.data!.docs) {
                                  String documentId = doc.id;

                                  // debugPrint(documentId);

                                  if (!checkId(orderId: documentId)) {
                                    var currentOrder = Order(
                                      status: doc["status"] ?? "pending",
                                      deviceId: doc["deviceId"] ?? "",
                                      userToken: doc["userToken"] ?? "",
                                      friendlyId: doc["friendlyId"] ?? 20000,
                                      quantities:
                                          List<int>.from(doc['quantities']),
                                      names: List<String>.from(doc['names']),
                                      prices: List<double>.from(doc['prices']),
                                      homeDelivery:
                                          doc['homeDelivery'] ?? false,
                                      deliveryCost:
                                          doc['deliveryCost']?.toDouble() ?? 0,
                                      time: doc["time"],
                                      userId: customer!.userId,
                                      restaurantId: auth.currentUser!.uid,
                                    );
                                    currentOrder.orderId = documentId;
                                    ordersList.add(
                                      currentOrder,
                                    );
                                  }

                                  // debugPrint(List<String>.from(doc['names']).join(", "));
                                }

                                return SizedBox(
                                    width: double.infinity,
                                    height: size.height * .155,
                                    child: ListView.builder(
                                      itemCount: ordersList.length,
                                      physics: BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics()),
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (_, index) {
                                        final Order order = ordersList[index];
                                        int totalCost = 0;

                                        for (int i = 0;
                                            i < order.prices.length;
                                            i++) {
                                          var price = order.prices[i];
                                          var qty = order.quantities[i];
                                          totalCost += (price * qty).toInt();
                                        }

                                        return Card(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          elevation: 12,
                                          shadowColor:
                                              Colors.black.withOpacity(.21),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () {
                                              debugPrint("move to orders");
                                              Navigator.push(
                                                  context,
                                                  ConcentricPageRoute(
                                                      builder: (_) =>
                                                          OrderDetails(
                                                              restaurant: widget
                                                                  .restaurant!,
                                                              color: getColor(
                                                                  status: order
                                                                      .status),
                                                              order: order,
                                                              total:
                                                                  totalCost)));

                                              // Navigator.push(
                                              //   context,
                                              //   PageTransition(
                                              //     child: OrderDetails(
                                              //       order: order,
                                              //       total: totalCost,
                                              //     ),
                                              //     type: PageTransitionType.topToBottom,
                                              //     alignment: Alignment.topCenter,
                                              //     duration: Duration(milliseconds: 700),
                                              //     curve: Curves.decelerate,
                                              //   ),
                                              // );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                  width: size.width * .4,
                                                  height: size.height * .15,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Hero(
                                                        tag: order.orderId,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text("Total"),
                                                            ClipOval(
                                                              child: Container(
                                                                width: 15,
                                                                height: 15,
                                                                color: order.status
                                                                            .toLowerCase() ==
                                                                        "pending"
                                                                    ? Colors
                                                                        .lightGreen
                                                                    : order.status.toLowerCase() ==
                                                                            "processing"
                                                                        ? Colors
                                                                            .blue
                                                                        : order.status.toLowerCase() ==
                                                                                "takeout"
                                                                            ? Colors.green[700]
                                                                            : order.status.toLowerCase() == "complete"
                                                                                ? Colors.purple[800]
                                                                                : Colors.pink,
                                                              ),
                                                            ),
                                                            Text(NumberFormat().format(order
                                                                        .homeDelivery
                                                                    ? totalCost +
                                                                        order
                                                                            .deliveryCost
                                                                    : totalCost) +
                                                                " CFA"),
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text("Items"),
                                                          Text(
                                                              order.names.length
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700)),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: const [
                                                          Text("Home Delivery"),
                                                          Text("Applied",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700)),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text("Date"),
                                                          Text(
                                                            timeAgo.format(order
                                                                .time
                                                                .toDate()),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  )),
                                            ),
                                          ),
                                        );
                                      },
                                    ));
                              }),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                                stream: _chatStream,
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasError) {
                                    return Text("Error loading message: " +
                                        snapshot.error.toString());
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Lottie.asset(
                                      "assets/search-list.json",
                                      fit: BoxFit.contain,
                                      width: size.width - 100,
                                      height: size.width - 100,
                                    );
                                  }
                                  List<DocumentSnapshot<Map<String, dynamic>>>
                                      chatMessages = snapshot.data!.docs;
                                  return ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      itemCount: chatMessages
                                          .length, // snapshot.data!.docChanges.length,
                                      reverse: true,
                                      itemBuilder: (_, index) {
                                        var map = chatMessages[
                                            chatMessages.length - 1 - index];
                                        Chat msg = Chat(
                                          senderName: map['senderName'],
                                          messageId: map.id,
                                          restaurantId: map['restaurantId'],
                                          restaurantImage:
                                              map['restaurantImage'],
                                          restaurantName: map['restaurantName'],
                                          userId: map['userId'],
                                          sender: map['sender'],
                                          userImage: map['userImage'],
                                          lastmessage: map['lastmessage'],
                                          lastMessageTime: DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  map['lastMessageTime']),
                                          opened: map['opened'] ?? true,
                                        );
                                        var map2 = chatMessages[
                                            chatMessages.length - 2 - index >= 0
                                                ? chatMessages.length -
                                                    2 -
                                                    index
                                                : 0];
                                        Chat msg2 = Chat(
                                          senderName: map2['senderName'],
                                          messageId: map2.id,
                                          restaurantId: map2['restaurantId'],
                                          restaurantImage:
                                              map2['restaurantImage'],
                                          restaurantName:
                                              map2['restaurantName'],
                                          userId: map2['userId'],
                                          sender: map2['sender'],
                                          userImage: map2['userImage'],
                                          lastmessage: map2['lastmessage'],
                                          lastMessageTime: DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  map2['lastMessageTime']),
                                          opened: map2['opened'] ?? true,
                                        );
                                        msg.messageId = map.id;
                                        DateTime time = msg.lastMessageTime;
                                        DateTime time2 = msg2.lastMessageTime;

                                        if (index == chatMessages.length - 1) {
                                          DBManager.instance.addChat(chat: msg);
                                        }

                                        bool mergeTimes = false;

                                        String separator = time.format("z");
                                        String separator2 = time2.format("z");
                                        if (separator != separator2) {
                                          separator = time.format("l j M, Y");
                                        } else if (msg == msg2) {
                                          separator = time.format("l j M, Y");
                                        } else {
                                          separator = '';
                                        }

                                        String moment = time.format("H:i");
                                        String moment2 = time2.format("H:i");
                                        if (moment == moment2) {
                                          mergeTimes = true;
                                        }

                                        return Bubble(
                                            separator: separator,
                                            separator2: separator2,
                                            msg2: msg2,
                                            moment: moment,
                                            moment2: moment2,
                                            msg: msg,
                                            mergeTimes: mergeTimes);
                                      });
                                }),
                          ),
                          TextWidget(
                              userToken: customer!.deviceId,
                              customerId: customer!.userId,
                              update: (String changes) {
                                setState(() {
                                  lastMessage = changes;
                                  sentByMe = true;
                                });
                              }),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class TextWidget extends StatefulWidget {
  TextWidget(
      {Key? key,
      required this.customerId,
      required this.update,
      required this.userToken})
      : super(key: key);
  final String customerId;
  final String userToken;
  Function(String data) update;

  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  late TextEditingController _editingController;
  late final restaurant;
  @override
  void initState() {
    _editingController = TextEditingController();
    restaurant = Provider.of<Auth>(context, listen: false).restaurant;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // debugPrint("adding my name: " + restaurant.name);

    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: 10),
      child: SizedBox(
        height: kToolbarHeight,
        width: size.width,
        child: Row(
          children: [
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          -2,
                        ),
                      ),
                    ]),
                child: TextField(
                  controller: _editingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Message",
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FloatingActionButton(
                  onPressed: () async {
                    if (_editingController.text.isNotEmpty) {
                      widget.update(_editingController.text);
                    }
                    Chat chat = Chat(
                      lastMessageTime: DateTime.now(),
                      senderName: restaurant.name.toString(),
                      opened: false,
                      lastmessage: _editingController.text,
                      restaurantId: auth.currentUser!.uid,
                      restaurantImage: restaurant.businessPhoto.toString(),
                      restaurantName: restaurant.companyName.toString(),
                      sender: auth.currentUser!.uid,
                      userId: widget.customerId,
                      userImage: restaurant.phone,
                    );

                    if (_editingController.text.isNotEmpty) {
                      final _userData =
                          Provider.of<Auth>(context, listen: false);
                      final Restaurant restaurant = _userData.restaurant;

                      sendMessage(
                          type: "message",
                          chat: chat,
                          userToken: widget.customerId,
                          restaurant: restaurant);
                      _editingController.text = "";
                    } else {
                      debugPrint("no text sent");
                    }
                  },
                  child: const Icon(
                    Icons.send_outlined,
                    color: Colors.white,
                  ),
                  elevation: 6),
            ),
          ],
        ),
      ),
    );
  }
}

Color getColor({required String status}) {
  return status == "pending"
      ? Colors.grey
      : status == "processing"
          ? Colors.blue
          : status.toLowerCase() == "takeout"
              ? Colors.lightGreen
              : status.toLowerCase() == "completed"
                  ? Colors.deepPurple
                  : Colors.pink;
}
