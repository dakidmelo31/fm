// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/models/overview.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:merchants/pages/see_distance.dart';
import 'package:merchants/transitions/transitions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:merchants/global.dart';
import 'package:merchants/pages/all_messages.dart';
import 'package:merchants/providers/restaurant_provider.dart';

import '../models/customer.dart';
import '../models/order_model.dart';

class OrderDetails extends StatefulWidget {
  int? total;
  Order? order;
  Color? color;
  OrderDetails({
    Key? key,
    this.total,
    this.userId,
    this.fromPush,
    this.restaurant,
    this.order,
    this.color,
  }) : super(key: key);
  Restaurant? restaurant;
  String? userId;
  bool? fromPush;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails>
    with TickerProviderStateMixin {
  late var chatStream;
  late var orderStream;
  bool callUpdate = false;

  double total = 0.0;
  var i = 0;
  late Color _color;
  Customer? customer;
  String? phone;
  Overview? overview;
  double lat = 0.0, lng = 0.0;

  Future<void> getLocation() async {
    var locationStatus = await Permission.location.status;
    if (locationStatus.isGranted) {
      debugPrint("granted");
    } else if (locationStatus.isDenied) {
      debugPrint("Not granted");
      Map<Permission, PermissionStatus> status =
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

  late final AnimationController _animationController;
  late final Animation<double> mainAnimation;
  getOverview() async {
    FirebaseFirestore.instance
        .collection("overviews")
        .doc(auth.currentUser!.uid)
        .collection("chats")
        .where("userId", isEqualTo: widget.order!.userId)
        .get();
  }

  getTotal() {
    for (var i = 0; i < order.names.length; i++) {
      total += order.quantities[i] * order.prices[i];
    }
  }

  bool visible = true;

  loadUser() async {
    customer = await getUser(userId: order.userId);
    List<String> tmp = customer!.phone.split("");
    for (var c = 0; c < tmp.length; c++) {
      if (c == 0) {
        phone = "(";
      }
      if (c < 3) {
        debugPrint(tmp[c]);
        phone = "$phone${tmp[c]}";
      }

      if (c == 3) {
        phone = "$phone${tmp[c]}) ";
      }
      if (c > 3) {
        if (c % 2 == 0) {
          phone = "$phone${tmp[c]} ";
        } else {
          phone = "$phone${tmp[c]}";
        }
      }
    }
    setState(() {
      _animationController.forward();
    });
  }

  ScreenshotController _screenshotController = ScreenshotController();
  late Order order;
  @override
  void initState() {
    _color = widget.color!;
    order = widget.order!;
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 3000,
        ),
        reverseDuration: Duration(milliseconds: 300));
    mainAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
    loadUser();
    getTotal();
    super.initState();

    chatStream = FirebaseFirestore.instance
        .collection("messages")
        .where("restaurantId", isEqualTo: auth.currentUser!.uid)
        .snapshots();
    orderStream = FirebaseFirestore.instance
        .collection("orders")
        .where("restaurantId", isEqualTo: auth.currentUser!.uid)
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy("time", descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<MealsData>(context, listen: false);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 245),
      body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: Duration(
              milliseconds: 1500,
            ),
            reverseDuration: Duration(milliseconds: 700),
            transitionBuilder: (child, animation) {
              animation = CurvedAnimation(
                parent: animation,
                curve: Curves.fastLinearToSlowEaseIn,
                reverseCurve: Curves.fastOutSlowIn,
              );
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  filterQuality: FilterQuality.high,
                  child: child,
                  alignment: Alignment.bottomCenter,
                ),
              );
            },
            child: customer == null
                ? Container(
                    alignment: Alignment.center,
                    width: size.width,
                    height: size.height,
                    child: Lottie.asset(
                      "assets/loading5.json",
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      reverse: true,
                    ),
                  )
                : Stack(children: [
                    Positioned(
                      left: 0.0,
                      top: 0.0,
                      width: size.width,
                      height: 160,
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color: _color,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.location_pin,
                                      color: Colors.transparent)),
                              Column(
                                children: [
                                  ClipOval(
                                    child: Container(
                                      color: _color,
                                      width: 58,
                                      height: 58,
                                      child: Center(
                                        child: ClipOval(
                                          child: Container(
                                            width: 55,
                                            height: 55,
                                            color: _color,
                                            child: Center(
                                                child: FaIcon(
                                                    FontAwesomeIcons.bowlFood,
                                                    color: Colors.white,
                                                    size: 30)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    order.status,
                                    style:
                                        TextStyle(fontSize: 20, color: _color),
                                  )
                                ],
                              ),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      CustomScaleTransition(
                                        alignment: Alignment.bottomCenter,
                                        child: SeeLocation(
                                          restaurant: widget.restaurant!,
                                          customer: customer!,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.location_pin,
                                    color: Colors.pink,
                                  )),
                              IconButton(
                                  onPressed: () async {
                                    debugPrint("share information");
                                    setState(() {
                                      visible = false;
                                    });
                                    await _screenshotController
                                        .capture(
                                            delay: const Duration(
                                                milliseconds: 10))
                                        .then((Uint8List? image) async {
                                      if (image != null) {
                                        final directory =
                                            await getApplicationDocumentsDirectory();
                                        final imagePath = await File(
                                                '${directory.path}/image.png')
                                            .create();
                                        await imagePath.writeAsBytes(image);

                                        /// Share Plugin
                                        await Share.shareFiles([imagePath.path],
                                            text: "${customer!.name} Receipt");
                                      }
                                    });

                                    setState(() {
                                      visible = true;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.ios_share_rounded,
                                    color: _color,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 130,
                      width: size.width,
                      height: size.height - 130,
                      child: Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35),
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 35, horizontal: 10),
                                  itemCount: order.names.length,
                                  itemBuilder: (_, index) {
                                    List<String> names = order.names;
                                    List<int> quantities = order.quantities;
                                    List<double> prices = order.prices;

                                    double currentTotal =
                                        quantities[index] * prices[index];
                                    double myTotal = 0;
                                    for (i; i < quantities.length; i++) {
                                      myTotal += quantities[i] * prices[i];
                                    }
                                    total = myTotal;
                                    return ListTile(
                                        leading: Column(
                                          children: [
                                            Text(
                                              quantities[index].toString(),
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              "Qty",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.5),
                                                  fontSize: 12),
                                            )
                                          ],
                                        ),
                                        dense: true,
                                        enableFeedback: true,
                                        title: Text(
                                          names[index],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: Text(
                                          NumberFormat().format(currentTotal) +
                                              " CFA",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ));
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Divider(
                                  color: _color,
                                  height: 2,
                                  thickness: 2,
                                ),
                              ),
                              SizedBox(
                                width: size.width,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          ClipOval(
                                            child: Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  Colors.white,
                                                  _color,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )),
                                              child: Center(
                                                child: ClipOval(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showCupertinoDialog(
                                                        context: context,
                                                        builder: (_) {
                                                          return Container(
                                                            width: size.width,
                                                            height:
                                                                double.infinity,
                                                            color: Colors.black,
                                                            child: Center(
                                                              child:
                                                                  CachedNetworkImage(
                                                                      imageUrl:
                                                                          customer!
                                                                              .image,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      width: size
                                                                          .width,
                                                                      filterQuality:
                                                                          FilterQuality
                                                                              .high,
                                                                      errorWidget: (_,
                                                                              __,
                                                                              ___) =>
                                                                          Lottie.asset(
                                                                              "assets/no-connection.json"),
                                                                      placeholder:
                                                                          (
                                                                        _,
                                                                        __,
                                                                      ) =>
                                                                              Lottie.asset(
                                                                                  "assets/loading7.json"),
                                                                      fadeInCurve:
                                                                          Curves
                                                                              .fastLinearToSlowEaseIn,
                                                                      fit: BoxFit
                                                                          .cover),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: CachedNetworkImage(
                                                        imageUrl:
                                                            customer!.image,
                                                        alignment:
                                                            Alignment.center,
                                                        width: size.width,
                                                        filterQuality:
                                                            FilterQuality.high,
                                                        errorWidget: (_, __,
                                                                ___) =>
                                                            Lottie.asset(
                                                                "assets/no-connection.json"),
                                                        placeholder: (
                                                          _,
                                                          __,
                                                        ) =>
                                                            Lottie.asset(
                                                                "assets/loading7.json"),
                                                        fadeInCurve: Curves
                                                            .fastLinearToSlowEaseIn,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Column(
                                              children: [
                                                TextButton.icon(
                                                    onPressed: () async {
                                                      Uri url = Uri.parse(
                                                          "tel:" +
                                                              customer!.phone);
                                                      if (await launchUrl(url))
                                                        throw "Could not launch $url";
                                                    },
                                                    label: Text(
                                                      "Call Now",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14),
                                                    ),
                                                    icon: Icon(Icons.call,
                                                        color: Colors.green)),
                                                TextButton.icon(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          transitionDuration:
                                                              Duration(
                                                                  milliseconds:
                                                                      1500),
                                                          reverseTransitionDuration:
                                                              Duration(
                                                                  milliseconds:
                                                                      200),
                                                          pageBuilder: (_,
                                                              animation,
                                                              anotherAnimation) {
                                                            return AllMessages(
                                                                restaurant: widget
                                                                    .restaurant,
                                                                chatsStream:
                                                                    chatStream,
                                                                customer: Overview(
                                                                    deviceId:
                                                                        customer!
                                                                            .deviceId,
                                                                    name: customer!
                                                                        .name,
                                                                    you: false,
                                                                    messageId:
                                                                        "messageId",
                                                                    message: "",
                                                                    photo: customer!
                                                                        .image,
                                                                    time: DateTime
                                                                        .now(),
                                                                    unreadCount:
                                                                        false,
                                                                    userId: order
                                                                        .userId),
                                                                ordersStream:
                                                                    orderStream,
                                                                callUpdate:
                                                                    callUpdate);
                                                          },
                                                          transitionsBuilder: (_,
                                                              animation,
                                                              anotherAnimation,
                                                              child) {
                                                            animation = CurvedAnimation(
                                                                parent:
                                                                    animation,
                                                                curve: Curves
                                                                    .fastLinearToSlowEaseIn,
                                                                reverseCurve: Curves
                                                                    .fastOutSlowIn);
                                                            return Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child:
                                                                  SizeTransition(
                                                                sizeFactor:
                                                                    animation,
                                                                axis: Axis
                                                                    .horizontal,
                                                                axisAlignment:
                                                                    0.0,
                                                                child: child,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ).then((value) {});
                                                    },
                                                    label: Text(
                                                      "Message Now",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14),
                                                    ),
                                                    icon: Icon(Icons.message,
                                                        color: Colors.blue)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text("name"),
                                          FittedBox(
                                            child: Text(
                                              customer!.name,
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          Text("Phone Number"),
                                          FittedBox(
                                            child: Text(
                                              phone.toString(),
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          Text("Delivery Address"),
                                          FittedBox(
                                            child: Text(
                                              customer!.address.isEmpty
                                                  ? "Not set"
                                                  : customer!.address,
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                  child: Column(
                                children: [
                                  Text(
                                    NumberFormat().format(total) + " CFA",
                                    style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: _color),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text("Home Delivery"),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          order.homeDelivery ? "Yes" : "No",
                                          style: TextStyle(
                                            color: order.homeDelivery
                                                ? Colors.blue
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text("Total Cost"),
                                      Text(
                                        NumberFormat().format(total) + " CFA",
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 100,
                                    width: size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Visibility(
                                            visible: visible,
                                            child: IconButton(
                                              onPressed: () {
                                                late String title;
                                                late String message;

                                                switch (order.status) {
                                                  case "pending":
                                                    debugPrint(
                                                        "Pending changed to Processing");
                                                    ordersData.pendingOrders
                                                        .remove(order);

                                                    order.status = "cancelled";
                                                    title =
                                                        "Order got cancelled";
                                                    message =
                                                        "${widget.restaurant!.companyName} cancelled ❌ your order. try talking to them if their reason is unclear.";

                                                    ordersData.cancelledOrders
                                                        .add(order);
                                                    setState(() {});
                                                    break;
                                                  case "processing":
                                                    debugPrint(
                                                        "Pending changed to Processing");
                                                    title =
                                                        "Your rder status updated";
                                                    message =
                                                        "${widget.restaurant!.companyName} changed your back to PENDING🚨🚨🚨. try talking to them if their reason is unclear.";
                                                    ordersData.processingOrders
                                                        .remove(order);
                                                    order.status = "pending";
                                                    ordersData.pendingOrders
                                                        .add(order);
                                                    setState(() {});
                                                    break;

                                                  case "takeout":
                                                    title =
                                                        "Your rder status updated";
                                                    String home = order
                                                            .homeDelivery
                                                        ? "We advise you to delay your visit to pickup your meal or call ahead to know what's up"
                                                        : "This means your meal is likely not ready yet. Try calling them for more information.";
                                                    message =
                                                        "${widget.restaurant!.companyName} changed your back to Processing🚨🚨🚨. $home";

                                                    ordersData.takeoutOrders
                                                        .remove(order);
                                                    order.status = "processing";
                                                    ordersData.processingOrders
                                                        .add(order);
                                                    setState(() {});
                                                    break;

                                                  case "completed":
                                                    debugPrint(
                                                        "nothing to be done");
                                                    title =
                                                        "Mistake, your order is not complete yet";
                                                    message = widget.restaurant!
                                                            .companyName +
                                                        " just rolled back your order status, please contact them for clarification if needed.";
                                                    ordersData.completedOrders
                                                        .remove(order);
                                                    order.status = "takeout";
                                                    ordersData.takeoutOrders
                                                        .add(order);
                                                    setState(() {});
                                                    break;

                                                  default:
                                                    debugPrint(
                                                        "doesn't belong to any category");

                                                    ordersData.cancelledOrders
                                                        .add(order);
                                                    setState(() {});
                                                    break;
                                                }
                                                setState(() {
                                                  _color = getColor(
                                                      status: order.status);
                                                });

                                                FirebaseFirestore.instance
                                                    .collection("orders")
                                                    .doc(order.orderId)
                                                    .update({
                                                      "status": order.status
                                                    })
                                                    .then((value) => sendNotif(
                                                        channel: 3,
                                                        title:
                                                            "Order #${order.friendlyId} status Changed back",
                                                        description:
                                                            "You changed the status back to ${order.status}. We'll Inform the user instantly."))
                                                    .catchError((onError) {
                                                      debugPrint(
                                                          "Error while changing: $onError");
                                                    });

                                                SnackBar snackBar = SnackBar(
                                                  backgroundColor: Colors.black,
                                                  content: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 25,
                                                            vertical: 0),
                                                    width: size.width - 100,
                                                    height: 50,
                                                    alignment: Alignment.center,
                                                    child: Row(
                                                      children: [
                                                        Lottie.asset(
                                                            "assets/arrows/blue-alert.json",
                                                            width: 50,
                                                            height: 50,
                                                            fit: BoxFit.contain,
                                                            alignment: Alignment
                                                                .center),
                                                        Text(
                                                            "Switched successfully"),
                                                      ],
                                                    ),
                                                  ),
                                                  action: SnackBarAction(
                                                      label: "Undo",
                                                      onPressed: () {
                                                        switch (order.status) {
                                                          case "cancelled":
                                                            //remove from new list
                                                            ordersData
                                                                .cancelledOrders
                                                                .remove(order);
                                                            order.status =
                                                                "pending";
                                                            //add back to current list
                                                            ordersData
                                                                .pendingOrders
                                                                .add(order);
                                                            break;
                                                          case "pending":
                                                            //remove from new list
                                                            ordersData
                                                                .pendingOrders
                                                                .remove(order);
                                                            order.status =
                                                                "processing";
                                                            //add back to current list
                                                            ordersData
                                                                .processingOrders
                                                                .add(order);
                                                            break;
                                                          case "processing":
                                                            //remove from new list
                                                            ordersData
                                                                .processingOrders
                                                                .remove(order);
                                                            order.status =
                                                                "takeout";
                                                            //add back to current list
                                                            ordersData
                                                                .takeoutOrders
                                                                .add(order);
                                                            break;
                                                          case "takeout":
                                                            //remove from new list
                                                            ordersData
                                                                .takeoutOrders
                                                                .remove(order);
                                                            order.status =
                                                                "completed";
                                                            //add back to current list
                                                            ordersData
                                                                .completedOrders
                                                                .add(order);
                                                            break;
                                                          case "completed":
                                                            debugPrint(
                                                                "Nothing to recover here");
                                                            break;
                                                          default:
                                                        }

                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "orders")
                                                            .doc(order.orderId)
                                                            .update({
                                                          "status": order.status
                                                        }).catchError(
                                                                (onError) {
                                                          debugPrint(
                                                              "Error while changing: $onError");
                                                        });

                                                        setState(() {
                                                          _color = getColor(
                                                              status:
                                                                  order.status);
                                                        });
                                                      },
                                                      textColor: Colors.blue),
                                                );

                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              },
                                              icon: Icon(
                                                  Icons.chevron_left_rounded),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              ClipOval(
                                                child: Container(
                                                  color: _color,
                                                  width: 58,
                                                  height: 58,
                                                  child: Center(
                                                    child: ClipOval(
                                                      child: Container(
                                                        width: 55,
                                                        height: 55,
                                                        color: _color,
                                                        child: Center(
                                                            child: FaIcon(
                                                                FontAwesomeIcons
                                                                    .bowlFood,
                                                                color: Colors
                                                                    .white,
                                                                size: 30)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                order.status,
                                                style: TextStyle(
                                                  color: _color,
                                                  fontSize: 18.0,
                                                ),
                                              )
                                            ],
                                          ),
                                          Visibility(
                                            visible: visible,
                                            child: IconButton(
                                                onPressed: () {
                                                  switch (order.status) {
                                                    case "cancelled":
                                                      debugPrint(
                                                          "Pending changed to Processing");
                                                      ordersData.cancelledOrders
                                                          .remove(order);
                                                      order.status = "pending";
                                                      ordersData.pendingOrders
                                                          .add(order);
                                                      setState(() {});
                                                      break;

                                                    case "pending":
                                                      debugPrint(
                                                          "Pending changed to Processing");
                                                      ordersData.pendingOrders
                                                          .remove(order);
                                                      order.status =
                                                          "processing";
                                                      ordersData
                                                          .processingOrders
                                                          .add(order);
                                                      setState(() {});
                                                      break;

                                                    case "processing":
                                                      ordersData
                                                          .processingOrders
                                                          .remove(order);
                                                      order.status = "takeout";
                                                      ordersData.takeoutOrders
                                                          .add(order);
                                                      setState(() {});
                                                      break;

                                                    case "takeout":
                                                      ordersData.takeoutOrders
                                                          .remove(order);
                                                      order.status =
                                                          "completed";
                                                      ordersData.completedOrders
                                                          .add(order);
                                                      setState(() {});
                                                      break;

                                                    case "completed":
                                                      debugPrint(
                                                          "nothing to be done");
                                                      break;

                                                    default:
                                                      debugPrint(
                                                          "doesn't belong to any category");

                                                      ordersData.cancelledOrders
                                                          .add(order);
                                                      setState(() {});
                                                      break;
                                                  }
                                                  setState(() {
                                                    order.status = order.status;
                                                    _color = getColor(
                                                        status: order.status);
                                                    debugPrint(
                                                        "order status is now: " +
                                                            order.status);
                                                  });

                                                  if (order.status !=
                                                      "completed") {
                                                    FirebaseFirestore.instance
                                                        .collection("orders")
                                                        .doc(order.orderId)
                                                        .update({
                                                          "status": order.status
                                                        })
                                                        .then((value) => sendNotif(
                                                            channel: 3,
                                                            title:
                                                                "You changed Order #${order.friendlyId} status",
                                                            description:
                                                                "Order status changed to ${order.status}. We'll Inform the user instantly."))
                                                        .catchError((onError) {
                                                          debugPrint(
                                                              "Error while changing: $onError");
                                                        });
                                                  }

                                                  SnackBar snackBar = SnackBar(
                                                    backgroundColor:
                                                        Colors.black,
                                                    content: Container(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 25,
                                                              vertical: 0),
                                                      width: size.width - 100,
                                                      height: 50,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Row(
                                                        children: [
                                                          Lottie.asset(
                                                              "assets/arrows/blue-alert.json",
                                                              width: 50,
                                                              height: 50,
                                                              fit: BoxFit
                                                                  .contain,
                                                              alignment:
                                                                  Alignment
                                                                      .center),
                                                          Text(
                                                              "Switched successfully"),
                                                        ],
                                                      ),
                                                    ),
                                                    action: SnackBarAction(
                                                        label: "Undo",
                                                        onPressed: () {
                                                          switch (
                                                              order.status) {
                                                            case "processing":
                                                              //remove from new list
                                                              ordersData
                                                                  .processingOrders
                                                                  .remove(
                                                                      order);
                                                              order.status =
                                                                  "pending";
                                                              //add back to current list
                                                              ordersData
                                                                  .pendingOrders
                                                                  .add(order);
                                                              break;
                                                            case "takeout":
                                                              //remove from new list
                                                              ordersData
                                                                  .takeoutOrders
                                                                  .remove(
                                                                      order);
                                                              order.status =
                                                                  "processing";
                                                              //add back to current list
                                                              ordersData
                                                                  .processingOrders
                                                                  .add(order);
                                                              break;
                                                            case "completed":
                                                              //remove from new list
                                                              ordersData
                                                                  .completedOrders
                                                                  .remove(
                                                                      order);
                                                              order.status =
                                                                  "takeout";
                                                              //add back to current list
                                                              ordersData
                                                                  .takeoutOrders
                                                                  .add(order);
                                                              break;
                                                            default:
                                                          }
                                                          order.status =
                                                              order.status;
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "orders")
                                                              .doc(
                                                                  order.orderId)
                                                              .update({
                                                            "status":
                                                                order.status
                                                          }).catchError(
                                                                  (onError) {
                                                            debugPrint(
                                                                "Error while changing: $onError");
                                                          });

                                                          _color = getColor(
                                                              status:
                                                                  order.status);
                                                        },
                                                        textColor: Colors.blue),
                                                  );

                                                  ScaffoldMessenger.of(context)
                                                      .hideCurrentSnackBar();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);

                                                  debugPrint(
                                                      "order status is now: " +
                                                          order.status);
                                                },
                                                icon: Icon(Icons
                                                    .chevron_right_rounded)),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                              SizedBox(
                                height: 35,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ]),
          )),
    );
  }
}
