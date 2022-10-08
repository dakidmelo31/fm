import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/models/review_models.dart';
import 'package:merchants/providers/auth_provider.dart';

import '../global.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen(
      {Key? key,
      required this.name,
      required this.foodId,
      required this.isMeal,
      required this.totalReviews})
      : super(key: key);
  final String foodId;
  final String name;
  final bool isMeal;
  final int totalReviews;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late var _stream;
  @override
  void initState() {
    super.initState();
    _stream = firestore
        .collection("reviews")
        .where("foodId", isEqualTo: widget.foodId)
        .snapshots();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: CustomScrollView(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            dragStartBehavior: DragStartBehavior.down,
            slivers: [
              SliverAppBar(
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                      ))
                ],
                title: Text("All Reviews"),
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                expandedHeight: 160.0,
                centerTitle: true,
                forceElevated: false,
                elevation: 0.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 77.0,
                          ),
                          Text(widget.totalReviews.toString())
                        ],
                      ),
                      SizedBox(
                        width: size.width * .65,
                        child: Text(
                          widget.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 24.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  StreamBuilder<QuerySnapshot>(
                    stream: _stream,
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Lottie.asset("assets/hat-review.json"),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Lottie.asset("assets/hat-review.json"),
                        );
                      }
                      List<ReviewModel> list = [];

                      snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        ReviewModel rev = ReviewModel.fromMap(data);
                        rev.reviewId = document.id;
                        return list.add(rev);
                      }).toList();

                      return ListView.builder(
                          physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (_, index) {
                            ReviewModel item = list[index];

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 30.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: item.avatar,
                                                alignment: Alignment.center,
                                                fit: BoxFit.cover,
                                                errorWidget: (_, __, ___) =>
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
                                                width: 45.0,
                                                height: 45.0,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            item.username,
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          HapticFeedback.heavyImpact();
                                          firestore
                                              .collection("reviews")
                                              .doc(item.reviewId)
                                              .delete()
                                              .then(
                                                (value) =>
                                                    Fluttertoast.showToast(
                                                  msg: "Review deleted",
                                                  backgroundColor: Colors.black,
                                                ),
                                              )
                                              .then((value) {
                                            firestore
                                                .collection(widget.isMeal
                                                    ? "meals"
                                                    : "services")
                                                .doc(widget.foodId)
                                                .update({
                                              "comments":
                                                  FieldValue.increment(-1)
                                            });
                                          });
                                        },
                                        icon: Icon(Icons.delete_rounded,
                                            size: 15),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              for (var i = 0; i < 5; i++)
                                                Icon(
                                                  Icons.star_rounded,
                                                  color: i <= item.rating
                                                      ? Colors.green
                                                      : Colors.grey
                                                          .withOpacity(.3),
                                                  size: 15.0,
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          item.created_at.day.toString() +
                                              "/" +
                                              item.created_at.month.toString() +
                                              "/" +
                                              item.created_at.year.toString(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w400),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          size.width - ((size.width / 30) * 2),
                                      child: Text(item.description))
                                ],
                              ),
                            );
                          });
                    },
                  )
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
