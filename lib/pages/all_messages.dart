import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concentric_transition/page_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/models/overview.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import '../models/chats_model.dart';
import '../models/order_model.dart';
import '../models/restaurants.dart';
import '../providers/auth_provider.dart';
import '../providers/global_data.dart';
import 'order_details.dart';

class AllMessages extends StatefulWidget {
  const AllMessages(
      {Key? key,
      this.callUpdate,
      required this.customer,
      required this.restaurant,
      required this.chatsStream,
      required this.ordersStream})
      : super(key: key);
  final Overview customer;
  final bool? callUpdate;
  final chatsStream;
  final ordersStream;
  final Restaurant restaurant;

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

  late Overview customer;
  @override
  void initState() {
    customer = widget.customer;
    timeAgo.setDefaultLocale("en");
    super.initState();
    _chatStream = firestore
        .collection("messages")
        .where("userId", isEqualTo: customer.userId)
        .where("restaurantId",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy("lastMessageTime", descending: false)
        .snapshots();
    _orderStream = firestore
        .collection("orders")
        .where("userId", isEqualTo: customer.userId)
        .where("restaurantId",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy("time", descending: true)
        .snapshots();
  }

  String lastMessage = "";
  bool sentByMe = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (lastMessage.isNotEmpty) {
          updateOverview(
              id: widget.customer.userId, message: lastMessage, sentByMe: true);
          debugPrint("updating overview: $lastMessage");
        } else
          debugPrint("Nothing to update overview with");
        return true;
      },
      child: Stack(
        children: [
          Image.asset("assets/background/bg.jpg",
              width: size.width,
              height: size.height,
              alignment: Alignment.center,
              fit: BoxFit.cover),
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
                                friendlyId: doc["friendlyId"] ?? 20000,
                                quantities: List<int>.from(doc['quantities']),
                                names: List<String>.from(doc['names']),
                                prices: List<double>.from(doc['prices']),
                                homeDelivery: doc['homeDelivery'] ?? false,
                                deliveryCost:
                                    doc['deliveryCost']?.toDouble() ?? 0,
                                time: doc["time"],
                                userId: customer.userId,
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
                                    parent: AlwaysScrollableScrollPhysics()),
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
                                    shadowColor: Colors.black.withOpacity(.21),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        debugPrint("move to orders");
                                        Navigator.push(
                                            context,
                                            ConcentricPageRoute(
                                                builder: (_) => OrderDetails(
                                                    restaurant:
                                                        widget.restaurant,
                                                    color: getColor(
                                                        status: order.status),
                                                    order: order,
                                                    total: totalCost)));

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
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                            width: size.width * .4,
                                            height: size.height * .15,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
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
                                                              : order.status
                                                                          .toLowerCase() ==
                                                                      "processing"
                                                                  ? Colors.blue
                                                                  : order.status
                                                                              .toLowerCase() ==
                                                                          "takeout"
                                                                      ? Colors.green[
                                                                          700]
                                                                      : order.status.toLowerCase() ==
                                                                              "complete"
                                                                          ? Colors.purple[
                                                                              800]
                                                                          : Colors
                                                                              .pink,
                                                        ),
                                                      ),
                                                      Text(NumberFormat().format(
                                                              order.homeDelivery
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
                                                            color: Colors.green,
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
                                                      timeAgo.format(
                                                          order.time.toDate()),
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

                            snapshot.data!.docChanges.map((e) {
                              if (e["userId"] == e['sender']) {
                                lastMessage = e["lastmessage"];
                                sentByMe = false;
                                debugPrint(
                                    "recently Received message: $lastMessage");
                              }
                            });

                            List<DocumentSnapshot<Map<String, dynamic>>>
                                chatMessages = snapshot.data!.docs;

                            var dateTracker;
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
                                    restaurantImage: map['restaurantImage'],
                                    restaurantName: map['restaurantName'],
                                    userId: map['userId'],
                                    sender: map['sender'],
                                    userImage: map['userImage'],
                                    lastmessage: map['lastmessage'],
                                    lastMessageTime:
                                        DateTime.fromMillisecondsSinceEpoch(
                                            map['lastMessageTime']),
                                    opened: map['opened'] ?? true,
                                  );
                                  msg.messageId = map.id;
                                  DateTime time = msg.lastMessageTime;
                                  bool mergeTimes = false;

                                  Duration difference;
                                  if (dateTracker == null) {
                                    dateTracker = time;
                                  } else {
                                    difference = dateTracker.difference(time);

                                    // debugPrint(difference.inMinutes.toString());
                                    if (difference.inMinutes <= 1) {
                                      mergeTimes = true;
                                    }
                                    dateTracker = time;
                                  }

                                  var moment = timeAgo.format(
                                    time,
                                    allowFromNow: false,
                                    clock: DateTime.now(),
                                  );
                                  debugPrint("restaurant: ${msg.restaurantId}");
                                  debugPrint("sender: ${msg.sender}");
                                  debugPrint("userId: ${msg.userId}");
                                  return msg.sender == msg.userId
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl: customer.photo,
                                                    width: size.width * .1,
                                                    height: size.width * .1,
                                                    fit: BoxFit.cover,
                                                    alignment: Alignment.center,
                                                    filterQuality:
                                                        FilterQuality.high,
                                                    placeholder: (_, __) {
                                                      return Lottie.asset(
                                                          "assets/loading-animation.json");
                                                    },
                                                    errorWidget: (_, __, ___) =>
                                                        Lottie.asset(
                                                            "assets/no-connection2.json",
                                                            width:
                                                                size.width * .1,
                                                            height:
                                                                size.width * .1,
                                                            fit: BoxFit.cover,
                                                            reverse: true,
                                                            options: LottieOptions(
                                                                enableMergePaths:
                                                                    true)),
                                                    maxHeightDiskCache: 54,
                                                    maxWidthDiskCache:
                                                        ((size.width * .1) *
                                                                100)
                                                            .ceil(),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * .9,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: SizedBox(
                                                        child: Card(
                                                            elevation: 0,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        10),
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    231,
                                                                    66,
                                                                    0),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      12.0),
                                                              child: Text(
                                                                  msg
                                                                      .lastmessage,
                                                                  style: TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255))),
                                                            )),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            if (!mergeTimes)
                                              Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          moment,
                                                          style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      245,
                                                                      245,
                                                                      245),
                                                              fontSize: 12),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5.0),
                                                          child: ClipOval(
                                                            child: Container(
                                                              width: 5,
                                                              height: 5,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      157,
                                                                      101,
                                                                      255),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5.0),
                                                          child: Text(
                                                            customer.name
                                                                .toString(),
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                SizedBox(
                                                  width: size.width * .9,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: SizedBox(
                                                      child: Card(
                                                        elevation: 0,
                                                        margin: EdgeInsets.only(
                                                            right: 10, top: 10),
                                                        color: Color.fromARGB(
                                                            255, 10, 15, 255),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      18.0,
                                                                  vertical: 10),
                                                          child: Text(
                                                              msg.lastmessage,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (!mergeTimes)
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          moment,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      .4),
                                                              fontSize: 12),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5.0),
                                                          child: ClipOval(
                                                            child: Container(
                                                              width: 5,
                                                              height: 5,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      157,
                                                                      101,
                                                                      255),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5.0),
                                                          child: Text(
                                                            "You",
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      68,
                                                                      0,
                                                                      255),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                          ],
                                        );
                                });
                          }),
                    ),
                    TextWidget(
                        customerId: customer.userId,
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
  TextWidget({Key? key, required this.customerId, required this.update})
      : super(key: key);
  final String customerId;
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
    debugPrint("adding my name: " + restaurant.name);

    return SizedBox(
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
                    final _userData = Provider.of<Auth>(context, listen: false);
                    final Restaurant restaurant = _userData.restaurant;

                    sendMessage(chat: chat);
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
