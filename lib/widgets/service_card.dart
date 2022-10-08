import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/global.dart';
import 'package:merchants/models/service.dart';
import 'package:merchants/pages/service_details.dart';
import 'package:merchants/providers/reviews.dart';
import 'package:merchants/transitions/transitions.dart';
import 'package:provider/provider.dart';

import '../pages/review_screen.dart';

class ServiceCard extends StatefulWidget {
  ServiceCard({Key? key, required this.service}) : super(key: key);
  ServiceModel service;

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    service = widget.service;
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  late ServiceModel service;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewData = Provider.of<ReviewProvider>(context, listen: true);
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Card(
        color: service.negociable ? Colors.white : Colors.lightGreen,
        elevation: 8.0,
        shadowColor: service.negociable ? Colors.white : Colors.lightGreen,
        child: SizedBox(
          width: size.width,
          height: 150.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    width: 100,
                    height: 140,
                    color: Colors.white,
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              CustomScaleTransition(
                                  alignment: Alignment.centerLeft,
                                  child: ServiceDetails(service: service)));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Hero(
                            tag: service.image,
                            child: CachedNetworkImage(
                              imageUrl: service.image,
                              errorWidget: (_, __, ___) =>
                                  Lottie.asset("assets/no-connection.json"),
                              placeholder: (
                                _,
                                __,
                              ) =>
                                  Lottie.asset("assets/loading7.json"),
                              fadeInCurve: Curves.fastLinearToSlowEaseIn,
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              width: 90,
                              height: 120,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width - 125.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FittedBox(
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              service.name,
                              style: TextStyle(
                                color: service.negociable
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            AbsorbPointer(
                              absorbing: true,
                              child: TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(
                                    service.negociable
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_outline_rounded,
                                    color: service.negociable
                                        ? Colors.pink
                                        : Colors.white,
                                    size: 22.0,
                                  ),
                                  label: Text(service.likes.toString(),
                                      style: TextStyle(
                                        color: service.negociable
                                            ? Colors.pink
                                            : Colors.white,
                                      ))),
                            ),
                            TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                          opaque: false,
                                          barrierColor: Colors.transparent,
                                          transitionDuration: Duration(
                                            milliseconds: 1200,
                                          ),
                                          reverseTransitionDuration: Duration(
                                            milliseconds: 300,
                                          ),
                                          pageBuilder:
                                              (_, animation, anotherAnimation) {
                                            animation = CurvedAnimation(
                                                parent: animation,
                                                curve: Curves
                                                    .fastLinearToSlowEaseIn);
                                            return ScaleTransition(
                                              scale: animation,
                                              alignment: Alignment.bottomCenter,
                                              filterQuality: FilterQuality.high,
                                              child: SizeTransition(
                                                  sizeFactor: animation,
                                                  axis: Axis.vertical,
                                                  axisAlignment: 0.0,
                                                  child: ReviewScreen(
                                                    isMeal: false,
                                                    name: service.name,
                                                    totalReviews:
                                                        service.comments,
                                                    foodId: service.serviceId,
                                                  )),
                                            );
                                          },
                                          transitionsBuilder: (_, animation,
                                              anotherAnimation, child) {
                                            animation = CurvedAnimation(
                                                parent: animation,
                                                curve: Curves
                                                    .fastLinearToSlowEaseIn);
                                            return ScaleTransition(
                                              scale: animation,
                                              alignment: Alignment.bottomCenter,
                                              filterQuality: FilterQuality.high,
                                              child: SizeTransition(
                                                sizeFactor: CurvedAnimation(
                                                    parent: animation,
                                                    curve: Interval(0.5, 1.0,
                                                        curve: Curves
                                                            .fastLinearToSlowEaseIn)),
                                                axis: Axis.vertical,
                                                axisAlignment: 0.0,
                                                child: child,
                                              ),
                                            );
                                          }));
                                },
                                icon: Icon(
                                  Icons.star_rounded,
                                  color: service.negociable
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                                  size: 22.0,
                                ),
                                label: Text(
                                  service.comments.toString(),
                                  style: TextStyle(
                                    color: service.negociable
                                        ? Theme.of(context).primaryColor
                                        : Colors.white,
                                  ),
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("negociable"),
                            Switch(
                                value: service.negociable,
                                onChanged: (onChanged) {
                                  updateData(
                                      collection: "meals",
                                      data: {"negociable": onChanged},
                                      doc: service.serviceId);
                                  setState(() {
                                    service.negociable = onChanged;
                                  });
                                })
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
