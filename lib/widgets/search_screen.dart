import 'package:flutter/material.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:merchants/providers/restaurant_provider.dart';
import 'package:merchants/widgets/order_tile.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget(
      {Key? key,
      required this.reverse,
      required this.restaurant,
      required this.color,
      required this.animation})
      : super(key: key);
  final Animation<double> animation;
  final Color color;
  final VoidCallback reverse;
  final Restaurant restaurant;

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<MealsData>(context, listen: true);
    final List<Order> searchResult = ordersData.orderSearches;

    Size size = MediaQuery.of(context).size;
    return AnimatedBuilder(
        animation: widget.animation,
        builder: (_, animation) {
          return Positioned(
              child: ClipRRect(
            borderRadius:
                BorderRadius.circular(60 * (1 - widget.animation.value)),
            child: Container(
              alignment: Alignment.bottomCenter,
              width: size.width * widget.animation.value,
              height: size.height * widget.animation.value,
              color: Colors.white,
              child: SafeArea(
                bottom: true,
                top: true,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            widget.reverse();
                          },
                          icon: Icon(Icons.arrow_back_rounded,
                              color: widget.color),
                        ),
                        Flexible(
                          child: Card(
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(.15),
                            child: InkWell(
                              onTap: () {},
                              child: TextField(
                                controller: searchController,
                                textInputAction: TextInputAction.send,
                                onChanged: (val) {
                                  if (val.isNotEmpty) {
                                    setState(() {
                                      ordersData.searchOrders(keyword: val);
                                    });
                                  }
                                },
                                onEditingComplete: () {
                                  if (searchController.text.isNotEmpty) {
                                    ordersData.searchOrders(
                                        keyword: searchController.text);
                                  }
                                },
                                onSubmitted: (val) {
                                  if (val.isNotEmpty) {
                                    ordersData.searchOrders(keyword: val);
                                  }
                                },
                                autofocus: false,
                                decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(0),
                                        borderSide: BorderSide(
                                            color: Colors.orange, width: 2)),
                                    hintText: "Search",
                                    border: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(00),
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 2),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          itemCount: searchResult.length,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          itemBuilder: (context, index) {
                            Order order = searchResult[index];
                            return OrderTile(
                                restaurant: widget.restaurant,
                                removeIndex: (index) {},
                                swipable: false,
                                index: index,
                                nextList: (dir) {},
                                previousList: (dir) {},
                                animation: widget.animation,
                                order: order);
                          }),
                    )
                  ],
                ),
              ),
            ),
          ));
        });
  }
}
