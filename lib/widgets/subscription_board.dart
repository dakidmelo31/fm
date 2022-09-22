import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SubscriptionBoard extends StatelessWidget {
  SubscriptionBoard({Key? key, required this.callback, required this.animation})
      : super(key: key);
  final Animation<double> animation;
  final VoidCallback callback;
  final PageController _pageController =
      PageController(initialPage: 0, viewportFraction: 1.0);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
        animation: animation,
        builder: (_, child) {
          return Positioned(
              height: size.height,
              width: size.width,
              left: size.width * (1 - animation.value),
              top: size.height * (1 - animation.value),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    size.height * size.height * (1 - animation.value)),
                child: Material(
                    child: Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 80.0,
                            ),
                            Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Our Subscription Plan",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18.0),
                                  ),
                                )),
                            Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15.0),
                              elevation: 20,
                              shadowColor: Colors.grey.withOpacity(.15),
                              child: InkWell(
                                onTap: () {
                                  Fluttertoast.cancel();
                                  Fluttertoast.showToast(
                                      msg:
                                          "Start Free and move your business online",
                                      backgroundColor: Colors.lightGreen);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                      "We offer a free plan and a subscription plan as well. You can start using our system free for up to 6 months and tap into the food community in your area and beyond with no serious marketting plan. We connect your business with the right people for you."),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: kToolbarHeight,
                              width: size.width,
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Card(
                                      elevation: 6.0,
                                      shadowColor: Colors.grey.withOpacity(.1),
                                      color: Colors.lightGreen,
                                      child: InkWell(
                                        onTap: () {
                                          _pageController.animateToPage(0,
                                              duration:
                                                  Duration(milliseconds: 500),
                                              curve: Curves
                                                  .fastLinearToSlowEaseIn);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Free Plan",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                    Card(
                                      shadowColor: Colors.grey.withOpacity(.1),
                                      elevation: 6.0,
                                      color: Color.fromARGB(255, 228, 228, 228),
                                      child: InkWell(
                                        onTap: () {
                                          _pageController.animateToPage(1,
                                              duration:
                                                  Duration(milliseconds: 1000),
                                              curve: Curves
                                                  .fastLinearToSlowEaseIn);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Premium Plan",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                    )
                                  ]),
                            ),
                            Expanded(
                              child: PageView(
                                physics: BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                controller: _pageController,
                                allowImplicitScrolling: true,
                                padEnds: true,
                                scrollDirection: Axis.horizontal,
                                pageSnapping: true,
                                children: [
                                  Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                            "Your posts are available immediately After review"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Your business will be in front of the market"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Receive and update Orders Notifications Immediately"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Notify subscribers immediately on shortages"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Get fast customer support from us"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      ListTile(
                                        title:
                                            Text("Sell with or without a shop"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Post Catering your Expert services for hire"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      ListTile(
                                        title: Text("All Free Plan Features"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Get verification banner on your Business"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Get AI driven exposure to consumers for higher conversion"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Get enhanced metric details on your business success"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            "Get map tracking available to both you and your customers during deliveries"),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Card(
                                elevation: 20,
                                shadowColor: Colors.grey.withOpacity(.15),
                                margin: EdgeInsets.only(bottom: 15.0),
                                child: InkWell(
                                  onTap: callback,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 18.0),
                                    child: Text("Don't Think, Start free"),
                                  ),
                                ))
                          ],
                        ))),
              ));
        });
  }
}
