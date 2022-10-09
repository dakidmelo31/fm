import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/global.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:merchants/providers/global_data.dart';
import 'package:merchants/widgets/order_tile.dart';
import 'package:merchants/widgets/orders_app_bar.dart';
import 'package:merchants/widgets/search_screen.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/restaurant_provider.dart';

// ignore: must_be_immutable
class AllOrders extends StatefulWidget {
  AllOrders(
      {Key? key,
      /*required this.allOrders,*/ required this.name,
      required this.restaurant})
      : super(key: key);
  final String name;
  Restaurant restaurant;
  // List<Order> allOrders;

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> with TickerProviderStateMixin {
  final orderListKey = GlobalKey<AnimatedListState>();
  final listKey = GlobalKey<AnimatedListState>();
  late String currentStatus;
  late AnimationController _searchController;
  late Animation<double> animation;
  bool allowBack = true;
  DateTimeRange? _dateRange;
  @override
  void initState() {
    _searchController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1300),
        reverseDuration: Duration(milliseconds: 300));
    animation = CurvedAnimation(
        parent: _searchController,
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
    currentStatus = widget.name.toLowerCase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final ordersData = Provider.of<MealsData>(context, listen: true);
    return WillPopScope(
      onWillPop: () => Future.delayed(Duration.zero, () {
        if (!allowBack) {
          _searchController.reverse();
          allowBack = true;
          return false;
        }
        return allowBack;
      }),
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
        body: Stack(
          children: [
            Container(
                width: size.width,
                height: size.height,
                child: Column(
                  children: [
                    OrdersAppBar(
                        range: (range) {
                          setState(() {
                            _dateRange = range;
                          });
                        },
                        callback: () {
                          allowBack = !allowBack;

                          _searchController.forward();
                        },
                        color: currentStatus == "cancelled"
                            ? Colors.pink
                            : currentStatus == "pending"
                                ? Colors.grey
                                : currentStatus == "processing"
                                    ? Colors.blue
                                    : currentStatus == "takeouts"
                                        ? Colors.lightGreen
                                        : currentStatus == "completed"
                                            ? Colors.deepPurple
                                            : Colors.grey.withOpacity(.3)),
                    Expanded(
                      child: AnimatedList(
                          key: listKey,
                          physics: BouncingScrollPhysics(),
                          initialItemCount: _dateRange == null
                              ? currentStatus == "pending"
                                  ? ordersData.pendingOrders.length
                                  : currentStatus == "processing"
                                      ? ordersData.processingOrders.length
                                      : currentStatus == "takeouts"
                                          ? ordersData.takeoutOrders.length
                                          : currentStatus == "complete" ||
                                                  currentStatus == "completed"
                                              ? ordersData
                                                  .completedOrders.length
                                              : ordersData
                                                  .cancelledOrders.length
                              : currentStatus == "pending"
                                  ? ordersData.pendingOrders.length
                                  : currentStatus == "processing"
                                      ? ordersData.processingOrders.length
                                      : currentStatus == "takeouts"
                                          ? ordersData.takeoutOrders.length
                                          : currentStatus == "complete" ||
                                                  currentStatus == "completed"
                                              ? ordersData
                                                  .completedOrders.length
                                              : ordersData
                                                  .cancelledOrders.length,
                          itemBuilder: (_, index, animation) {
                            Order order = currentStatus == "pending"
                                ? ordersData.pendingOrders[index]
                                : currentStatus == "processing"
                                    ? ordersData.processingOrders[index]
                                    : currentStatus == "takeouts"
                                        ? ordersData.takeoutOrders[index]
                                        : ordersData.completedOrders[index];

                            // debugPrint(order.status);

                            if (_dateRange != null) {
                              DateTime myDate = order.time.toDate();
                              Duration diff =
                                  _dateRange!.start.difference(myDate);
                              if (!diff.isNegative) {
                                return SizedBox.shrink();
                              }
                              Duration secondDiff =
                                  _dateRange!.end.difference(myDate);
                              if (secondDiff.isNegative) {
                                return SizedBox.shrink();
                              }
                            }

                            return OrderTile(
                                restaurant: widget.restaurant,
                                removeIndex: ((itemIndex) {
                                  if (itemIndex != null) {
                                    listKey.currentState!.removeItem(
                                        index,
                                        (context, animation) => OrderTile(
                                            restaurant: widget.restaurant,
                                            removeIndex: (index) {},
                                            index: index,
                                            nextList: (direction) {},
                                            previousList: (direction) {},
                                            animation: animation,
                                            order: order));
                                  }
                                }),
                                previousList: (direction) {
                                  debugPrint("Todo back list");
                                  listKey.currentState!.removeItem(
                                      index,
                                      (context, animation) => OrderTile(
                                          restaurant: widget.restaurant,
                                          removeIndex: (index) {},
                                          index: index,
                                          nextList: (direction) {},
                                          previousList: (direction) {},
                                          animation: animation,
                                          order: order));

                                  // order.status = "processing";
                                  late String title;
                                  late String message;

                                  switch (order.status) {
                                    case "pending":
                                      debugPrint(
                                          "Pending changed to Processing");
                                      ordersData.pendingOrders.remove(order);

                                      order.status = "cancelled";
                                      title = "Order got cancelled";
                                      message =
                                          "${widget.restaurant.companyName} cancelled ❌ your order. try talking to them if their reason is unclear.";

                                      ordersData.cancelledOrders.add(order);
                                      setState(() {});
                                      break;
                                    case "processing":
                                      debugPrint(
                                          "Pending changed to Processing");
                                      title = "Your order status updated";
                                      message =
                                          "${widget.restaurant.companyName} changed your back to PENDING🚨🚨🚨. try talking to them if their reason is unclear.";
                                      ordersData.processingOrders.remove(order);
                                      order.status = "pending";
                                      ordersData.pendingOrders.add(order);
                                      setState(() {});
                                      break;

                                    case "takeout":
                                      title = "Your order status updated";
                                      String home = order.homeDelivery
                                          ? "We advise you to delay your visit to pickup your meal or call ahead to know what's up"
                                          : "This means your meal is likely not ready yet. Try calling them for more information.";
                                      message =
                                          "${widget.restaurant.companyName} changed your back to Processing🚨🚨🚨. $home";

                                      ordersData.takeoutOrders.remove(order);
                                      order.status = "processing";
                                      ordersData.processingOrders.add(order);
                                      setState(() {});
                                      break;

                                    case "completed":
                                      debugPrint("nothing to be done");
                                      title =
                                          "Mistake, your order is not complete yet";
                                      message = widget.restaurant.companyName +
                                          " just rolled back your order status, please contact them for clarification if needed.";
                                      ordersData.completedOrders.remove(order);
                                      order.status = "takeout";
                                      ordersData.takeoutOrders.add(order);
                                      setState(() {});
                                      break;

                                    default:
                                      debugPrint(
                                          "doesn't belong to any category");

                                      ordersData.cancelledOrders.add(order);
                                      setState(() {});
                                      break;
                                  }
                                  FirebaseFirestore.instance
                                      .collection("orders")
                                      .doc(order.orderId)
                                      .update({"status": order.status})
                                      .then((value) => sendNotif(
                                          channel: 3,
                                          title:
                                              "Order #${order.friendlyId} status Changed back",
                                          description:
                                              "You changed the status back to ${order.status}. We'll Inform the user instantly."))
                                      .then((value) {
                                        sendOrderNotification(
                                            userId: order.userId,
                                            type: "order",
                                            message: message,
                                            title: title,
                                            restaurant: widget.restaurant,
                                            extra: widget.restaurant.phone);
                                      })
                                      .catchError((onError) {
                                        debugPrint(
                                            "Error while changing: $onError");
                                      });

                                  SnackBar snackBar = SnackBar(
                                    backgroundColor: Colors.black,
                                    content: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 0),
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
                                              alignment: Alignment.center),
                                          Text("Switched successfully"),
                                        ],
                                      ),
                                    ),
                                    action: SnackBarAction(
                                        label: "Undo",
                                        onPressed: () {
                                          switch (order.status) {
                                            case "cancelled":
                                              //remove from new list
                                              ordersData.cancelledOrders
                                                  .remove(order);
                                              order.status = "pending";
                                              //add back to current list
                                              ordersData.pendingOrders
                                                  .insert(index, order);
                                              break;
                                            case "pending":
                                              //remove from new list
                                              ordersData.pendingOrders
                                                  .remove(order);
                                              order.status = "processing";
                                              //add back to current list
                                              ordersData.processingOrders
                                                  .insert(index, order);
                                              break;
                                            case "processing":
                                              //remove from new list
                                              ordersData.processingOrders
                                                  .remove(order);
                                              order.status = "takeout";
                                              //add back to current list
                                              ordersData.takeoutOrders
                                                  .insert(index, order);
                                              break;
                                            case "takeout":
                                              //remove from new list
                                              ordersData.takeoutOrders
                                                  .remove(order);
                                              order.status = "completed";
                                              //add back to current list
                                              ordersData.completedOrders
                                                  .insert(index, order);
                                              break;
                                            case "completed":
                                              debugPrint(
                                                  "Nothing to recover here");
                                              // //remove from new list
                                              // ordersData.completedOrders
                                              //     .remove(order);
                                              // order.status = "completed";
                                              // //add back to current list
                                              // ordersData.takeoutOrders
                                              //     .insert(index, order);
                                              break;
                                            default:
                                          }
                                          listKey.currentState!.insertItem(
                                            index,
                                          );
                                          FirebaseFirestore.instance
                                              .collection("orders")
                                              .doc(order.orderId)
                                              .update({
                                            "status": order.status
                                          }).then((value) {
                                            sendOrderNotification(
                                                type: "order",
                                                userId: order.userId,
                                                restaurant: widget.restaurant,
                                                title: widget.restaurant
                                                        .companyName +
                                                    " updated your order status📝",
                                                message:
                                                    "#${order.friendlyId} status has been updated to ${order.status}. come check it out👌",
                                                extra: widget.restaurant.phone);
                                          }).catchError((onError) {
                                            debugPrint(
                                                "Error while changing: $onError");
                                          });

                                          setState(() {});
                                        },
                                        textColor: Colors.blue),
                                  );

                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                                nextList: (direction) {
                                  debugPrint("next list");

                                  listKey.currentState!.removeItem(
                                      index,
                                      (context, animation) => OrderTile(
                                          restaurant: widget.restaurant,
                                          removeIndex: (index) {},
                                          index: index,
                                          nextList: (direction) {},
                                          previousList: (direction) {},
                                          animation: animation,
                                          order: order));

                                  // order.status = "processing";
                                  String message = '', title = '';

                                  switch (order.status) {
                                    case "pending":
                                      debugPrint(
                                          "Pending changed to Processing");
                                      ordersData.pendingOrders.remove(order);
                                      order.status = "processing";
                                      title =
                                          "Order #${order.friendlyId} updated";
                                      message = widget.restaurant.companyName +
                                          " have accepted your order, your food being processed 🥘";
                                      ordersData.processingOrders.add(order);
                                      setState(() {});
                                      break;

                                    case "processing":
                                      ordersData.processingOrders.remove(order);
                                      order.status = "takeout";

                                      title =
                                          "Order #${order.friendlyId} updated";
                                      message = widget.restaurant.companyName +
                                          " has finished processing your order, and is ready for you 🍴";

                                      ordersData.takeoutOrders.add(order);
                                      setState(() {});
                                      break;

                                    case "takeout":
                                      ordersData.takeoutOrders.remove(order);
                                      order.status = "completed";

                                      title =
                                          "Order #${order.friendlyId} updated";
                                      message =
                                          "Happy with your service? then consider leaving a review for the food you just bought 😁👌";

                                      ordersData.completedOrders.add(order);
                                      setState(() {});
                                      break;

                                    case "completed":
                                      debugPrint("nothing to be done");
                                      break;

                                    default:
                                      debugPrint(
                                          "doesn't belong to any category");

                                      ordersData.cancelledOrders.add(order);
                                      setState(() {});
                                      break;
                                  }

                                  if (currentStatus != "completed") {
                                    FirebaseFirestore.instance
                                        .collection("orders")
                                        .doc(order.orderId)
                                        .update({"status": order.status}).then(
                                            (value) {
                                      sendNotif(
                                          channel: 3,
                                          title:
                                              "You changed Order #${order.friendlyId} status",
                                          description:
                                              "Order status changed to ${order.status}. We'll Inform the user instantly.");

                                      if (message.isNotEmpty &&
                                          title.isNotEmpty)
                                        sendOrderNotification(
                                            userId: order.userId,
                                            type: "order",
                                            message: message,
                                            title: title,
                                            restaurant: widget.restaurant,
                                            extra: widget.restaurant.phone);
                                    }).catchError((onError) {
                                      debugPrint(
                                          "Error while changing: $onError");
                                    });
                                  }

                                  SnackBar snackBar = SnackBar(
                                    backgroundColor: Colors.black,
                                    content: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 0),
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
                                              alignment: Alignment.center),
                                          Text("Switched successfully"),
                                        ],
                                      ),
                                    ),
                                    action: SnackBarAction(
                                        label: "Undo",
                                        onPressed: () {
                                          switch (order.status) {
                                            case "processing":
                                              //remove from new list
                                              ordersData.processingOrders
                                                  .remove(order);
                                              order.status = "pending";
                                              //add back to current list
                                              ordersData.pendingOrders
                                                  .insert(index, order);
                                              break;
                                            case "takeout":
                                              //remove from new list
                                              ordersData.takeoutOrders
                                                  .remove(order);
                                              order.status = "processing";
                                              //add back to current list
                                              ordersData.processingOrders
                                                  .insert(index, order);
                                              break;
                                            case "completed":
                                              //remove from new list
                                              ordersData.completedOrders
                                                  .remove(order);
                                              order.status = "completed";
                                              //add back to current list
                                              ordersData.takeoutOrders
                                                  .insert(index, order);
                                              break;
                                            default:
                                          }
                                          listKey.currentState!.insertItem(
                                            index,
                                          );
                                          FirebaseFirestore.instance
                                              .collection("orders")
                                              .doc(order.orderId)
                                              .update({
                                            "status": {currentStatus}
                                          }).catchError((onError) {
                                            debugPrint(
                                                "Error while changing: $onError");
                                          });

                                          setState(() {});
                                        },
                                        textColor: Colors.blue),
                                  );

                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },

                                //  () {
                                //   ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                //   switch (currentStatus) {
                                //     case "pending":
                                //       ordersData.pendingOrders.removeAt(index);
                                //       order.status = "processing";
                                //       ordersData.processingOrders.add(order);
                                //       // setState(() {});
                                //       break;

                                //     case "processing":
                                //       ordersData.processingOrders.removeAt(index);
                                //       order.status = "takeout";
                                //       ordersData.takeoutOrders.add(order);
                                //       setState(() {
                                //         listKey.currentState!.removeItem(
                                //             index,
                                //             (context, animation) => OrderTile(
                                //                 index: index,
                                //                 nextList: () {},
                                //                 previousList: () {},
                                //                 bringBack: (data) {},
                                //                 animation: animation,
                                //                 order: order));
                                //       });
                                //       break;

                                //     case "takeout":
                                //       ordersData.takeoutOrders.removeAt(index);
                                //       order.status = "completed";
                                //       ordersData.completedOrders.add(order);
                                //       setState(() {});
                                //       break;

                                //     default:
                                //       ordersData.cancelledOrders.add(order);
                                //       setState(() {});
                                //       break;
                                //   }
                                // },

                                index: index,
                                animation: animation,
                                order: currentStatus == "pending"
                                    ? ordersData.pendingOrders[index]
                                    : currentStatus == "processing"
                                        ? ordersData.processingOrders[index]
                                        : currentStatus == "takeouts"
                                            ? ordersData.takeoutOrders[index]
                                            : ordersData
                                                .completedOrders[index]);
                          }),
                    )
                  ],
                )),
            SearchWidget(
                restaurant: widget.restaurant,
                reverse: () {
                  allowBack = !allowBack;
                  _searchController.reverse();
                },
                animation: animation,
                color: currentStatus == "cancelled"
                    ? Colors.pink
                    : currentStatus == "pending"
                        ? Colors.grey
                        : currentStatus == "processing"
                            ? Colors.blue
                            : currentStatus == "takeouts"
                                ? Colors.lightGreen
                                : currentStatus == "completed"
                                    ? Colors.deepPurple
                                    : Colors.grey.withOpacity(.3))
          ],
        ),
      ),
    );
  }
}
