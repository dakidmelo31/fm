import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import '../models/order_model.dart';
import '../models/restaurants.dart';
import '../pages/order_details.dart';
import '../themes/light_theme.dart';

class OrderTile extends StatelessWidget {
  OrderTile(
      {Key? key,
      required this.index,
      required this.restaurant,
      required this.removeIndex,
      required this.nextList,
      required this.previousList,
      required this.animation,
      this.swipable,
      required this.order})
      : super(key: key);
  Order order;
  final int index;
  final bool? swipable;
  final Restaurant restaurant;
  final Animation<double> animation;
  final Function(String direction) nextList;
  final Function(int? index) removeIndex;
  final Function(String direction) previousList;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // final allOrders = Provider.of<OrdersData>(context, listen: false);
    // final all = Provider.of<MealsData>(context, listen: false);

    double orderTotal = 0;
    for (int i = 0; i < order.names.length; i++) {
      orderTotal += order.prices[i] * order.quantities[i];
    }

    final thisKey = GlobalKey();
    return SlideTransition(
      key: Key(order.orderId),
      position: Tween<Offset>(begin: Offset(0, -1.0), end: Offset(0.0, 0.0))
          .animate(animation),
      child: swipable != null
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.0),
                color: Colors.transparent,
              ),
              width: size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14.0, horizontal: 3),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.size,
                                  alignment: Alignment.center,
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  reverseDuration: Duration(milliseconds: 200),
                                  duration: Duration(seconds: 1),
                                  child: OrderDetails(
                                    restaurant: restaurant,
                                    color: getColor(status: order.status),
                                    order: order,
                                    total: orderTotal.toInt(),
                                  )));
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: CircleAvatar(
                                  backgroundColor:
                                      getColor(status: order.status),
                                  child: const Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 0),
                                      child: Text(
                                          "#" + order.friendlyId.toString(),
                                          style: Primary.heading),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Hero(
                                        tag: order.friendlyId,
                                        child: Material(
                                          child: Text(
                                            NumberFormat()
                                                    .format((orderTotal)) +
                                                " CFA",
                                            style: TextStyle(
                                              color: Colors.black.withOpacity(
                                                .9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  FittedBox(
                                      child: Hero(
                                    tag: order.restaurantId.toString() +
                                        order.friendlyId.toString(),
                                    child: Material(
                                      child: Text(
                                        getTime(
                                          order.time.toDate(),
                                        ),
                                      ),
                                    ),
                                  )),
                                  const SizedBox(height: 5),
                                  _dots()
                                ],
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Dismissible(
              key: thisKey,
              secondaryBackground:
                  swipable != null ? null : _secondaryBackground(order.status),
              background: swipable != null
                  ? null
                  : _background(order.status.toLowerCase()),
              confirmDismiss: (dismissDirection) async {
                String direction = 'right';
                if (order.status == 'completed' &&
                    dismissDirection == DismissDirection.startToEnd) {
                  return Future.delayed(Duration.zero, () {
                    return false;
                  });
                }
                if (dismissDirection == DismissDirection.endToStart) {
                  direction = "left";
                  bool outcome = await showCupertinoDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) {
                        return Material(
                          color: Colors.black.withOpacity(.3),
                          child: Center(
                            child: Card(
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 80,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text("Rollback order Status?",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              return Navigator.pop(
                                                  context, true);
                                            },
                                            child: Text("Switch",
                                                style: TextStyle(
                                                    color: Colors.lightGreen)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              return Navigator.pop(
                                                  context, false);
                                            },
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.lightGreen),
                                            ),
                                          ),
                                        ]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                  if (outcome) {
                    previousList(direction);
                  }

                  return outcome;
                } else {
                  nextList(direction);
                  return await Future.delayed(Duration.zero, () {
                    return true;
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  color: Colors.white,
                ),
                width: size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 3),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            int? index = await Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.size,
                                    alignment: Alignment.topRight,
                                    curve: Curves.fastLinearToSlowEaseIn,
                                    reverseDuration:
                                        Duration(milliseconds: 400),
                                    duration: Duration(seconds: 1),
                                    child: OrderDetails(
                                      restaurant: restaurant,
                                      color: getColor(status: order.status),
                                      order: order,
                                      total: orderTotal.toInt(),
                                    )));
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: CircleAvatar(
                                    backgroundColor:
                                        getColor(status: order.status),
                                    child: const Icon(
                                      Icons.restaurant_menu_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 0),
                                        child: Text(
                                            "#" + order.friendlyId.toString(),
                                            style: Primary.heading),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Hero(
                                          tag: order.friendlyId,
                                          child: Material(
                                            child: Text(
                                              NumberFormat()
                                                      .format((orderTotal)) +
                                                  " CFA",
                                              style: TextStyle(
                                                color: Colors.black.withOpacity(
                                                  .9,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                        child: Hero(
                                      tag: order.restaurantId.toString() +
                                          order.friendlyId.toString(),
                                      child: Material(
                                        child: Text(
                                          timeAgo.format(
                                            order.time.toDate(),
                                          ),
                                        ),
                                      ),
                                    )),
                                    const SizedBox(height: 5),
                                    _dots()
                                  ],
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
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

  Color nextColor({required String status}) {
    return status.toLowerCase() == "pending"
        ? Colors.blue
        : status.toLowerCase() == "takeout"
            ? Colors.deepPurple
            : status.toLowerCase() == "processing"
                ? Colors.lightGreen
                : status.toLowerCase() == "cancel"
                    ? Colors.grey
                    : status.toLowerCase() == "completed"
                        ? Colors.lightGreen
                        : Colors.deepPurple;
  }

  Widget _dots() {
    bool pending = order.status == "pending";
    bool processing = order.status == "processing";
    bool takeout = order.status == "takeout";
    bool completed = order.status == "completed";
    bool cancelled = order.status == "cancelled";

    Color _color = cancelled
        ? Colors.pink
        : pending
            ? Colors.grey
            : processing
                ? Colors.blue
                : takeout
                    ? Colors.lightGreen
                    : completed
                        ? Colors.deepPurple
                        : Colors.grey.withOpacity(.3);
    int count = cancelled
        ? 1
        : pending
            ? 2
            : processing
                ? 3
                : takeout
                    ? 4
                    : 5;
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6, right: 4),
          child: ClipOval(
            child: Container(
              color: count > 0 ? _color : Colors.grey.withOpacity(.2),
              height: cancelled ? 20 : 8,
              width: cancelled ? 20 : 8,
              child: cancelled
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 6, right: 4),
          child: ClipOval(
            child: Container(
              color: count > 1 ? _color : Colors.grey.withOpacity(.2),
              height: pending ? 20 : 8,
              width: pending ? 20 : 8,
              child: pending
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 6, right: 4),
          child: ClipOval(
            child: Container(
              color: count > 2 ? _color : Colors.grey.withOpacity(.2),
              height: processing ? 20 : 8,
              width: processing ? 20 : 8,
              child: processing
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 6, right: 4),
          child: ClipOval(
            child: Container(
              color: count > 3 ? _color : Colors.grey.withOpacity(.2),
              height: takeout ? 20 : 8,
              width: takeout ? 20 : 8,
              child: takeout
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 6, right: 4),
          child: ClipOval(
            child: Container(
              color: count > 4 ? _color : Colors.grey.withOpacity(.2),
              height: completed ? 20 : 8,
              width: completed ? 20 : 8,
              child: completed
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _background(String status) {
    Color _color = status == "pending"
        ? Colors.blue
        : "processing" == status
            ? Colors.lightGreen
            : status == "takeout"
                ? Colors.deepPurple
                : status == "completed"
                    ? Colors.pink
                    : Colors.grey.withOpacity(.3);
    return Container(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Lottie.asset(
                "assets/arrows/right5.json",
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                options: LottieOptions(enableMergePaths: true),
                reverse: true,
              ),
            ),
            Text(
              "Next Status",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      width: double.infinity,
      height: double.infinity,
      color: _color,
    );
  }

  Widget _secondaryBackground(String status) {
    Color _color = status == "pending"
        ? Colors.pink
        : "processing" == status
            ? Colors.grey
            : status == "takeout"
                ? Colors.blue
                : status == "completed"
                    ? Colors.lightGreen
                    : Colors.grey.withOpacity(.3);
    return Container(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Previous Status",
              style: TextStyle(color: _color),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Lottie.asset(
                "assets/arrows/left2.json",
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                options: LottieOptions(enableMergePaths: true),
                reverse: true,
              ),
            ),
          ],
        ),
      ),
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.withOpacity(.2),
    );
  }

  String getTime(DateTime date) {
    var overADay = DateTime.now().difference(date);
    debugPrint("Number of hours" + overADay.inHours.toString());

    return overADay.inDays > 1
        ? "${date.day}/${date.month <= 9 ? 0 : ""}${date.month}/${date.year}"
        : timeAgo.format(
            order.time.toDate(),
          );
  }
}
