// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/global.dart';
import 'package:merchants/pages/review_screen.dart';
import 'package:merchants/providers/meals.dart';
import 'package:merchants/transitions/transitions.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/food_model.dart';
import 'home_screen.dart';

class MealDetails extends StatefulWidget {
  static const routeName = "/details_screen";
  Food? food;
  String? foodId;
  MealDetails({this.foodId, this.food});

  @override
  State<MealDetails> createState() => _MealDetailsState();
}

class _MealDetailsState extends State<MealDetails> {
  final _listState = GlobalKey<AnimatedListState>();
  final List<String> _categories = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Road side",
    "Beef",
    "Dessert",
    "Groceries",
    "Specials",
    "Simple",
    "Traditional",
    "Home Delivery",
    "Vegitarian",
    "Casual",
    "Classic"
  ];
  List<String> _selectedCompliments = [],
      _selectedCategories = [],
      _ingredients = [];

  bool loading = false;

  late TextEditingController _descriptionController;
  late TextEditingController _complimentsController, _titleController;
  late TextEditingController _productPrice;
  late TextEditingController _productDuration;

  bool _editingDescription = false,
      _editingCompliments = false,
      _editingPrice = false,
      _editingTitle = false;
  late List<String> categoriesList, accessoriesList, galleryList;
  Food? localFood;
  initiateLists() async {
    if (widget.foodId != null) {
      setState(() {
        loading = true;
      });
      var data = await firestore.collection("meals").doc(widget.foodId).get();
      if (!data.exists) {
        navigatorKey.currentState
            ?.pushReplacement(CustomFadeTransition(child: Home()));
      } else {
        String documentID = data.id;

        localFood = Food(
          foodId: documentID,
          verified: data["verified"],
          ingredients: List<String>.from(data['ingredients']),
          likes: data['likes'] as int,
          description: data['description'],
          comments: data['comments'] as int,
          name: data["name"],
          available: data["available"],
          image: data['image'],
          averageRating:
              data["averageRating"] as int, //int.parse(data['averageRating'])
          price: data["price"] as double, //double.parse(data['price'])
          restaurantId: data['restaurantId'],
          gallery: List<String>.from(data['gallery']),
          compliments: List<String>.from(data['accessories']),
          duration: data['duration'],
          categories: List<String>.from(data['categories']),
        );
      }
      setState(() {
        loading = false;
      });
    } else {
      localFood = widget.food;
    }

    setState(() {
      _categories.sort();

      _selectedCategories = localFood!.categories;
      _selectedCompliments = localFood!.compliments;
    });

    _descriptionController =
        TextEditingController(text: localFood!.description);

    _complimentsController = TextEditingController(text: "");
    _titleController = TextEditingController(text: localFood!.name);

    _productDuration = TextEditingController(text: localFood!.duration);
    _productPrice = TextEditingController(text: localFood!.price.toString());
    _productPrice.text = localFood!.price.toString();
    _productPrice.text = localFood!.price.toString();
    _ingredients = localFood!.ingredients;
    _productDuration.text = localFood!.duration;
  }

  @override
  void initState() {
    initiateLists();

    super.initState();
  }

  bool edited = false;

  @override
  Widget build(BuildContext context) {
    final _mealsData = Provider.of<Meals>(context, listen: true);
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (widget.foodId != null) {
          Navigator.pushReplacement(
              context,
              VerticalSizeTransition(
                  child: Home(
                index: 0,
              )));
        }
        return true;
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 1200),
        switchInCurve: Curves.fastLinearToSlowEaseIn,
        switchOutCurve: Curves.fastOutSlowIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              filterQuality: FilterQuality.high,
              alignment: Alignment.bottomRight,
              child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  axisAlignment: 1.0,
                  child: child),
            ),
          );
        },
        child: loading
            ? Center(
                child: Lottie.asset("assets/loading5.json",
                    width: size.width,
                    height: size.width,
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high),
              )
            : SafeArea(
                child: Scaffold(
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endFloat,
                  floatingActionButton: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: Colors.white,
                    elevation: 15,
                    shadowColor: Colors.grey.withOpacity(.3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          Fluttertoast.cancel();
                          Fluttertoast.showToast(
                              msg: "this post has gotten " +
                                  localFood!.likes.toString() +
                                  " likes 💫");
                        },
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                            Icons.favorite_rounded,
                            color: Colors.pink,
                            size: 45.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                NumberFormat.compactCurrency(
                                  decimalDigits: 2,
                                  symbol:
                                      '', // if you want to add currency symbol then pass that in this else leave it empty.
                                ).format(localFood!.likes),
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.pink)),
                          ),
                          Text("Likes", style: TextStyle(color: Colors.pink))
                        ]),
                      ),
                    ),
                  ),
                  body: Stack(
                    children: [
                      Positioned(
                        child: CustomScrollView(
                          physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          slivers: [
                            SliverAppBar(
                              backgroundColor: Colors.transparent,
                              leading: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.arrow_back_rounded)),
                              expandedHeight: 215.0,
                              flexibleSpace: FlexibleSpaceBar(
                                stretchModes: [
                                  StretchMode.blurBackground,
                                  StretchMode.fadeTitle,
                                  StretchMode.zoomBackground
                                ],
                                background: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Center(
                                          child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration:
                                                    Duration(milliseconds: 800),
                                                reverseTransitionDuration:
                                                    Duration(milliseconds: 300),
                                                transitionsBuilder: (_,
                                                    animation,
                                                    anotherAnimation,
                                                    child) {
                                                  animation = CurvedAnimation(
                                                      parent: animation,
                                                      curve: Curves
                                                          .fastLinearToSlowEaseIn);
                                                  return SizeTransition(
                                                    sizeFactor: animation,
                                                    axis: Axis.horizontal,
                                                    axisAlignment: 0.0,
                                                    child: child,
                                                  );
                                                },
                                                opaque: false,
                                                barrierColor: Colors.black
                                                    .withOpacity(.6),
                                                pageBuilder: (context,
                                                    animation,
                                                    secondaryAnimation) {
                                                  animation = CurvedAnimation(
                                                      parent: animation,
                                                      curve: Curves
                                                          .fastLinearToSlowEaseIn);
                                                  return SizeTransition(
                                                    sizeFactor: animation,
                                                    axis: Axis.horizontal,
                                                    axisAlignment: 1.0,
                                                    child: Scaffold(
                                                      backgroundColor:
                                                          Colors.black,
                                                      body: Center(
                                                        child: Hero(
                                                          tag: localFood!.image,
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: localFood!
                                                                .image,
                                                            width: size.width,
                                                            height: size.width,
                                                            fit: BoxFit.cover,
                                                            errorWidget:
                                                                (_, __, ___) =>
                                                                    errorWidget,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ));
                                        },
                                        child: Hero(
                                          tag: localFood!.image,
                                          child: ClipOval(
                                            child: Container(
                                              width: 200.0,
                                              height: 200.0,
                                              alignment: Alignment.center,
                                              child: CachedNetworkImage(
                                                imageUrl: localFood!.image,
                                                errorWidget: (_, __, ___) =>
                                                    errorWidget,
                                                placeholder: (
                                                  _,
                                                  __,
                                                ) =>
                                                    Lottie.asset(
                                                        "assets/loading7.json"),
                                                fadeInCurve: Curves
                                                    .fastLinearToSlowEaseIn,
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Card(
                                        margin: EdgeInsets.only(left: 50.0),
                                        elevation: 10,
                                        shadowColor:
                                            Colors.grey.withOpacity(.6),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 15.0),
                                          child: Text("Feedback"),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Card(
                                        margin: EdgeInsets.only(
                                          right: 50.0,
                                        ),
                                        elevation: 10,
                                        shadowColor:
                                            Colors.grey.withOpacity(.6),
                                        child: InkWell(
                                          onTap: () =>
                                              showCupertinoModalBottomSheet(
                                                  context: context,
                                                  builder: (_) => ReviewScreen(
                                                        isMeal: true,
                                                        name: localFood!.name,
                                                        foodId:
                                                            localFood!.foodId,
                                                        totalReviews:
                                                            localFood!.comments,
                                                      )),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(NumberFormat().format(
                                                    localFood!.comments) +
                                                " Reviews"),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SliverList(
                                delegate: SliverChildListDelegate([
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: localFood!.gallery.isEmpty
                                        ? InkWell(
                                            onTap: uploadPictures,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                      Icons
                                                          .add_a_photo_outlined,
                                                      size: 30.0),
                                                ),
                                                Text("Add Gallery Photos"),
                                              ],
                                            ),
                                          )
                                        : CarouselSlider.builder(
                                            itemCount:
                                                localFood!.gallery.length,
                                            itemBuilder:
                                                (_, index, anotherIndex) {
                                              String image =
                                                  localFood!.gallery[index];
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      PageRouteBuilder(
                                                        transitionDuration:
                                                            Duration(
                                                                milliseconds:
                                                                    1200),
                                                        reverseTransitionDuration:
                                                            Duration(
                                                                milliseconds:
                                                                    300),
                                                        transitionsBuilder: (_,
                                                            animation,
                                                            anotherAnimation,
                                                            child) {
                                                          animation =
                                                              CurvedAnimation(
                                                                  parent:
                                                                      animation,
                                                                  curve: Curves
                                                                      .fastLinearToSlowEaseIn);
                                                          return SizeTransition(
                                                            sizeFactor:
                                                                animation,
                                                            axis:
                                                                Axis.horizontal,
                                                            axisAlignment: 0.0,
                                                            child: child,
                                                          );
                                                        },
                                                        opaque: false,
                                                        barrierColor: Colors
                                                            .black
                                                            .withOpacity(.6),
                                                        pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) {
                                                          animation =
                                                              CurvedAnimation(
                                                                  parent:
                                                                      animation,
                                                                  curve: Curves
                                                                      .fastLinearToSlowEaseIn);
                                                          return SizeTransition(
                                                            sizeFactor:
                                                                animation,
                                                            axis:
                                                                Axis.horizontal,
                                                            axisAlignment: 0.0,
                                                            child: Scaffold(
                                                              backgroundColor:
                                                                  Colors.black
                                                                      .withOpacity(
                                                                          .6),
                                                              body: SizedBox(
                                                                width:
                                                                    size.width,
                                                                height:
                                                                    size.height,
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Spacer(),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          Hero(
                                                                        tag:
                                                                            image,
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          imageUrl:
                                                                              image,
                                                                          errorWidget: (_, __, ___) =>
                                                                              errorWidget,
                                                                          placeholder: (
                                                                            _,
                                                                            __,
                                                                          ) =>
                                                                              Lottie.asset("assets/loading7.json"),
                                                                          fadeInCurve:
                                                                              Curves.fastLinearToSlowEaseIn,
                                                                          width:
                                                                              size.width,
                                                                          height:
                                                                              size.width,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Spacer(),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .bottomCenter,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(bottom: 28.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            IconButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              icon: Icon(
                                                                                Icons.arrow_back_rounded,
                                                                                color: Colors.white,
                                                                                size: 30.0,
                                                                              ),
                                                                            ),
                                                                            Card(
                                                                                elevation: 10,
                                                                                color: Colors.white,
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      localFood!.gallery.removeAt(index);
                                                                                      localFood!.image = image;
                                                                                      localFood!.gallery.add(image);
                                                                                      updateData(collection: "meals", doc: localFood!.foodId, data: {
                                                                                        "gallery": localFood!.gallery,
                                                                                        "image": localFood!.image
                                                                                      });
                                                                                    });
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                                                                    child: Text("Make This Main Picture"),
                                                                                  ),
                                                                                ))
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ));
                                                },
                                                child: ClipOval(
                                                  child: Container(
                                                    width: 100.0,
                                                    height: 100.0,
                                                    alignment: Alignment.center,
                                                    child: CachedNetworkImage(
                                                      imageUrl: image,
                                                      errorWidget:
                                                          (_, __, ___) =>
                                                              errorWidget,
                                                      placeholder: (
                                                        _,
                                                        __,
                                                      ) =>
                                                          loadingWidget,
                                                      fadeInCurve: Curves
                                                          .fastLinearToSlowEaseIn,
                                                      width: 100.0,
                                                      height: 100.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            options: CarouselOptions(
                                                height: 100.0,
                                                scrollPhysics:
                                                    BouncingScrollPhysics(),
                                                enlargeCenterPage: true,
                                                enableInfiniteScroll: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                viewportFraction: .3)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Gallery Images"),
                                      ),
                                      if (localFood!.gallery.isNotEmpty)
                                        IconButton(
                                          onPressed: uploadPictures,
                                          icon: Icon(Icons.add_a_photo_outlined,
                                              size: 30.0),
                                        )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(""),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: size.width - 70.0,
                                          child: Text(
                                            localFood!.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18.0),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _editingTitle = !_editingTitle;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  _editingTitle
                                      ? TweenAnimationBuilder(
                                          duration:
                                              Duration(milliseconds: 1000),
                                          child: TextField(
                                            controller: _titleController,
                                            autocorrect: true,
                                            autofocus: true,
                                            enableSuggestions: true,
                                            enabled: true,
                                            decoration: InputDecoration(
                                              hintText: "Edit Title...",
                                              border: UnderlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              label: Text("Name"),
                                              filled: true,
                                              suffixIcon: AvatarGlow(
                                                duration:
                                                    Duration(milliseconds: 900),
                                                repeatPauseDuration: Duration(
                                                    milliseconds: 2500),
                                                endRadius: 25.0,
                                                glowColor:
                                                    Colors.blue.withOpacity(.1),
                                                curve: Curves
                                                    .fastLinearToSlowEaseIn,
                                                shape: BoxShape.circle,
                                                child: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        if (_titleController
                                                            .text.isNotEmpty) {
                                                          localFood!.name =
                                                              _titleController
                                                                  .text;
                                                          edited = true;
                                                        }
                                                      });
                                                    },
                                                    icon: Icon(
                                                        Icons.check_rounded,
                                                        size: 25.0,
                                                        color: Colors.blue)),
                                              ),
                                              fillColor: Colors.white,
                                              isDense: true,
                                            ),
                                          ),
                                          builder: (context, double animation,
                                              child) {
                                            return Opacity(
                                              opacity: animation,
                                              child: Container(
                                                  height: 60.0 * animation,
                                                  child: child),
                                            );
                                          },
                                          tween: Tween(begin: 0.0, end: 1.0),
                                        )
                                      : AnimatedContainer(
                                          duration: Duration(
                                            milliseconds: 300,
                                          ),
                                          height:
                                              _editingCompliments ? 0.0 : 60.0,
                                          curve: Curves.slowMiddle,
                                        ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: size.width * .86,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            localFood!.description,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _editingDescription =
                                                  !_editingDescription;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  _editingDescription
                                      ? TweenAnimationBuilder(
                                          duration:
                                              Duration(milliseconds: 1000),
                                          child: TextField(
                                            controller: _descriptionController,
                                            autocorrect: true,
                                            autofocus: true,
                                            enableSuggestions: true,
                                            enabled: true,
                                            maxLines: 6,
                                            minLines: 3,
                                            style: TextStyle(fontSize: 14.0),
                                            decoration: InputDecoration(
                                              hintText: "Edit Description...",
                                              border: UnderlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              label: Text("Description"),
                                              filled: true,
                                              suffixIcon: AvatarGlow(
                                                duration:
                                                    Duration(milliseconds: 900),
                                                repeatPauseDuration: Duration(
                                                    milliseconds: 2500),
                                                endRadius: 25.0,
                                                glowColor:
                                                    Colors.blue.withOpacity(.1),
                                                curve: Curves
                                                    .fastLinearToSlowEaseIn,
                                                shape: BoxShape.circle,
                                                child: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        if (_descriptionController
                                                            .text.isNotEmpty) {
                                                          _editingDescription =
                                                              !_editingDescription;
                                                          localFood!
                                                                  .description =
                                                              _descriptionController
                                                                  .text;
                                                          edited = true;
                                                        }
                                                      });
                                                    },
                                                    icon: Icon(
                                                        Icons.check_rounded,
                                                        size: 25.0,
                                                        color: Colors.blue)),
                                              ),
                                              fillColor: Colors.white,
                                              isDense: true,
                                            ),
                                          ),
                                          builder: (context, double animation,
                                              child) {
                                            return Opacity(
                                              opacity: animation,
                                              child: Container(
                                                  height: 60.0 * animation,
                                                  child: child),
                                            );
                                          },
                                          tween: Tween(begin: 0.0, end: 1.0),
                                        )
                                      : AnimatedContainer(
                                          duration: Duration(
                                            milliseconds: 300,
                                          ),
                                          height:
                                              _editingDescription ? 0.0 : 60.0,
                                          curve: Curves.slowMiddle,
                                        ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                          elevation: 10.0,
                                          color: localFood!.available
                                              ? Colors.green
                                              : Colors.pink,
                                          child: SizedBox(
                                            height: 50.0,
                                            width: 150.0,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  localFood!.available =
                                                      !localFood!.available;
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      localFood!.available
                                                          ? "In Stock"
                                                          : "Out of Stock",
                                                      style: TextStyle(
                                                        color:
                                                            localFood!.available
                                                                ? Colors.white
                                                                : Colors.amber,
                                                      ),
                                                    ),
                                                  ),
                                                  Switch(
                                                      activeColor: Colors.white,
                                                      inactiveThumbColor:
                                                          Colors.amber,
                                                      value:
                                                          localFood!.available,
                                                      onChanged: (onChanged) {
                                                        setState(() {
                                                          localFood!.available =
                                                              !localFood!
                                                                  .available;
                                                        });
                                                      })
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_editingPrice)
                                        Flexible(
                                            child: TextField(
                                          controller: _productPrice,
                                          onChanged: (e) {
                                            setState(() {
                                              edited = true;
                                            });
                                          },
                                          onSubmitted: (e) {
                                            setState(() {
                                              _editingPrice = !_editingPrice;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            label: Text("Change Price"),
                                            hintText:
                                                localFood!.price.toString(),
                                          ),
                                        )),
                                      if (!_editingPrice)
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                NumberFormat().format(
                                                        double.tryParse(
                                                            _productPrice
                                                                .text)) +
                                                    " CFA",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.lightGreen,
                                                    fontSize: 30.0),
                                              ),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _editingPrice =
                                                        !_editingPrice;
                                                  });
                                                },
                                                icon: Icon(Icons.edit_rounded,
                                                    color: Colors.blue))
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              "Compliments to eat with This"),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _editingCompliments =
                                                  !_editingCompliments;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.add,
                                            color: Colors.green,
                                          ),
                                          iconSize: 30.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_editingCompliments)
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 3600),
                                      switchOutCurve:
                                          Curves.fastLinearToSlowEaseIn,
                                      transitionBuilder: (child, animation) {
                                        animation = CurvedAnimation(
                                            parent: animation,
                                            curve:
                                                Curves.fastLinearToSlowEaseIn);

                                        return SizeTransition(
                                          sizeFactor: animation,
                                          axis: Axis.horizontal,
                                          child: child,
                                          axisAlignment: 0.0,
                                        );
                                      },
                                      reverseDuration:
                                          Duration(milliseconds: 300),
                                      switchInCurve:
                                          Curves.fastLinearToSlowEaseIn,
                                      child: _editingCompliments
                                          ? TweenAnimationBuilder(
                                              duration:
                                                  Duration(milliseconds: 1000),
                                              child: TextField(
                                                controller:
                                                    _complimentsController,
                                                autocorrect: true,
                                                autofocus: true,
                                                enableSuggestions: true,
                                                enabled: true,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "Add Compliment... E.g Irish Potatoes",
                                                  border: UnderlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  label: Text("Compliment"),
                                                  filled: true,
                                                  suffixIcon: AvatarGlow(
                                                    duration: Duration(
                                                        milliseconds: 900),
                                                    repeatPauseDuration:
                                                        Duration(
                                                            milliseconds: 2500),
                                                    endRadius: 25.0,
                                                    glowColor: Colors.blue
                                                        .withOpacity(.1),
                                                    curve: Curves
                                                        .fastLinearToSlowEaseIn,
                                                    shape: BoxShape.circle,
                                                    child: IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            if (_complimentsController
                                                                    .text
                                                                    .isNotEmpty &&
                                                                !localFood!
                                                                    .compliments
                                                                    .contains(
                                                                        _complimentsController
                                                                            .text)) {
                                                              localFood!
                                                                  .compliments
                                                                  .add(_complimentsController
                                                                      .text);
                                                              edited = true;
                                                            }
                                                            _complimentsController
                                                                .text = "";
                                                          });
                                                        },
                                                        icon: Icon(
                                                            Icons.check_rounded,
                                                            size: 25.0,
                                                            color:
                                                                Colors.blue)),
                                                  ),
                                                  fillColor: Colors.white,
                                                  isDense: true,
                                                ),
                                              ),
                                              builder: (context,
                                                  double animation, child) {
                                                return Opacity(
                                                  opacity: animation,
                                                  child: Container(
                                                      height: 60.0 * animation,
                                                      child: child),
                                                );
                                              },
                                              tween:
                                                  Tween(begin: 0.0, end: 1.0),
                                            )
                                          : AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              height: _editingCompliments
                                                  ? 0.0
                                                  : 60.0,
                                              curve: Curves.slowMiddle,
                                            ),
                                    ),
                                ]),
                              ),
                              SizedBox(
                                height: 60,
                                width: size.width,
                                child: AnimatedList(
                                  initialItemCount:
                                      localFood!.compliments.length,
                                  key: _listState,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (_, index, anotherIndex) {
                                    String compliment =
                                        localFood!.compliments[index];
                                    return InkWell(
                                      onTap: () {
                                        if (_selectedCompliments
                                            .contains(compliment)) {
                                          setState(() {
                                            _selectedCompliments
                                                .remove(compliment);
                                            _listState.currentState?.removeItem(
                                                index, (_, animation) {
                                              return AnimatedOpacity(
                                                curve: Curves
                                                    .fastLinearToSlowEaseIn,
                                                duration:
                                                    Duration(milliseconds: 600),
                                                opacity: _selectedCompliments
                                                        .contains(compliment)
                                                    ? 1.0
                                                    : 0.3,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Chip(
                                                    backgroundColor:
                                                        Colors.white,
                                                    label: Text(compliment),
                                                    avatar: Icon(Icons
                                                        .food_bank_rounded),
                                                    labelPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5.0,
                                                            horizontal: 8.0),
                                                    elevation: 12.0,
                                                    shadowColor: Colors.black
                                                        .withOpacity(.4),
                                                  ),
                                                ),
                                              );
                                            },
                                                duration: Duration(
                                                    milliseconds: 300));
                                          });
                                        } else {
                                          setState(() {
                                            _selectedCompliments
                                                .add(compliment);
                                            _listState.currentState!.insertItem(
                                                index,
                                                duration: Duration(
                                                    milliseconds: 300));
                                          });
                                        }
                                        HapticFeedback.heavyImpact();
                                        debugPrint(_selectedCompliments.length
                                            .toString());
                                      },
                                      child: AnimatedOpacity(
                                        duration: Duration(milliseconds: 300),
                                        opacity: _selectedCompliments
                                                .contains(compliment)
                                            ? 1.0
                                            : 0.3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Chip(
                                            backgroundColor: Colors.white,
                                            label: Text(compliment),
                                            avatar:
                                                Icon(Icons.food_bank_rounded),
                                            labelPadding: EdgeInsets.symmetric(
                                                vertical: 5.0, horizontal: 8.0),
                                            elevation: 12.0,
                                            shadowColor:
                                                Colors.black.withOpacity(.4),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Selected Categories"),
                                        ),
                                      ),
                                    ]),
                              ),
                              Wrap(
                                children: [
                                  for (String cat in _categories)
                                    AnimatedScale(
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.fastOutSlowIn,
                                      filterQuality: FilterQuality.high,
                                      alignment: Alignment.centerLeft,
                                      scale: _selectedCategories.contains(cat)
                                          ? 1.0
                                          : 0.8,
                                      child: InkWell(
                                        onTap: () {
                                          edited = true;
                                          if (_selectedCategories
                                              .contains(cat)) {
                                            setState(() {
                                              _selectedCategories.remove(cat);
                                            });
                                          } else {
                                            setState(() {
                                              if (_selectedCategories.length >=
                                                  5) {
                                                Fluttertoast.cancel();
                                                Fluttertoast.showToast(
                                                  msg:
                                                      "Select 5 categories Maximum",
                                                  backgroundColor: Colors.pink,
                                                  gravity:
                                                      ToastGravity.SNACKBAR,
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  webShowClose: true,
                                                );
                                              } else {
                                                setState(() {
                                                  _selectedCategories.add(cat);
                                                });
                                              }
                                            });
                                          }
                                          HapticFeedback.heavyImpact();
                                          debugPrint(_selectedCategories.length
                                              .toString());
                                        },
                                        child: AnimatedOpacity(
                                          duration: Duration(milliseconds: 300),
                                          opacity:
                                              _selectedCategories.contains(cat)
                                                  ? 1.0
                                                  : 0.3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Chip(
                                              backgroundColor: Colors.white,
                                              label: Text(cat),
                                              avatar: Icon(
                                                  Icons.food_bank_rounded,
                                                  color:
                                                      Colors.primaries[_categories
                                                                  .indexOf(
                                                                      cat) >
                                                              Colors.primaries
                                                                      .length -
                                                                  1
                                                          ? _categories.indexOf(
                                                                  cat) -
                                                              Colors.primaries
                                                                  .length
                                                          : _categories
                                                              .indexOf(cat)]),
                                              labelPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 8.0),
                                              elevation: 12.0,
                                              shadowColor:
                                                  Colors.black.withOpacity(.4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ]))
                          ],
                        ),
                      ),
                      if (edited)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 25.0,
                              top: 30.0,
                            ),
                            child: AvatarGlow(
                              endRadius: 30,
                              animate: true,
                              duration: Duration(seconds: 1),
                              glowColor: Colors.green,
                              repeatPauseDuration: Duration(seconds: 1),
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      edited = false;

                                      localFood!.name =
                                          _titleController.text.toString();
                                      localFood!.price = double.tryParse(
                                              _productPrice.text.toString()) ??
                                          localFood!.price;
                                      localFood!.ingredients = _ingredients;
                                      localFood!.compliments =
                                          _selectedCompliments;
                                      localFood!.categories =
                                          _selectedCategories;
                                      localFood!.description =
                                          _descriptionController.text;

                                      _mealsData.updateMeal(
                                          foodId: localFood!.foodId,
                                          data: localFood!.toMap());

                                      updateAllData(
                                          collection: "meals",
                                          doc: localFood!.foodId,
                                          data: {
                                            "available": localFood!.available,
                                            "categories": _selectedCategories,
                                            "ingredients": _ingredients,
                                            "compliments": _selectedCompliments,
                                            "description":
                                                _descriptionController.text,
                                            "name": _titleController.text,
                                            "price": double.tryParse(
                                                _productPrice.text),
                                          });
                                    });
                                  },
                                  icon: Icon(
                                    Icons.check_rounded,
                                    color: Colors.green,
                                    size: 30.0,
                                  )),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String category = "Choose Main Category";
  bool deleteIngredients = false;
  updateAllData(
      {required String collection,
      required String doc,
      required Map<String, dynamic> data}) async {
    // await FirebaseFirestore.instance.collection("reviews").doc(doc).delete();
    FirebaseFirestore.instance
        .collection(collection)
        .doc(doc)
        .set(data, SetOptions(merge: true))
        .then(
          (value) => debugPrint("update info"),
        );
  }

  uploadPictures() async {
    await Navigator.push(
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
            pageBuilder: (_, animation, anotherAnimation) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return FadeTransition(
                  opacity: animation,
                  child: AddGallery(food: localFood!, type: "meal"));
            },
            transitionsBuilder: (_, animation, anotherAnimation, child) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            })).then((value) => setState(() {}));
  }
}

class AddGallery extends StatefulWidget {
  AddGallery({Key? key, required this.food, required this.type})
      : super(key: key);
  Food food;
  String type;

  @override
  State<AddGallery> createState() => _AddGalleryState();
}

class _AddGalleryState extends State<AddGallery> with TickerProviderStateMixin {
  late AnimationController _mainAnimation;
  late Animation<double> animation;
  List<File> _localGallery = [];
  final picker = ImagePicker();
  pickImages() async {
    List<XFile>? _images = await picker.pickMultiImage(imageQuality: 90);
    if (_images != null) {
      _images.forEach((element) {
        _localGallery.add(File(element.path));
      });
      setState(() {});
    }
  }

  @override
  void initState() {
    pickImages();
    _mainAnimation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    animation = CurvedAnimation(
        parent: _mainAnimation, curve: Curves.fastLinearToSlowEaseIn);
    _mainAnimation.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(
          .6,
        ),
        body: AnimatedSwitcher(
          switchOutCurve: Curves.fastLinearToSlowEaseIn,
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.bounceInOut,
          child: changed
              ? Lottie.asset(
                  "assets/loading5.json",
                  fit: BoxFit.contain,
                )
              : Column(
                  children: [
                    Spacer(),
                    CarouselSlider.builder(
                        itemCount: _localGallery.length,
                        itemBuilder: (_, index, anotherIndex) {
                          File file = _localGallery[index];
                          Size size = MediaQuery.of(context).size;
                          globalIndex = index;
                          return Material(
                            elevation: 12.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.file(
                                File(file.path),
                                width: size.width,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          onScrolled: (value) {
                            if (value != null) globalIndex = value.floor();
                          },
                          enableInfiniteScroll: false,
                          aspectRatio: 16 / 9,
                          height: 350,
                          enlargeCenterPage: true,
                        )),
                    Spacer(),
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 25.0),
                      elevation: 10.0,
                      color: Colors.white,
                      child: InkWell(
                        onTap: () async {
                          setState(() {
                            changed = true;
                          });
                          final uuid = Uuid();
                          for (File? photo in _localGallery) {
                            FirebaseStorage storage = FirebaseStorage.instance;
                            Reference ref =
                                storage.ref().child("uploads/" + uuid.v4());
                            UploadTask uploadTask =
                                ref.putFile(File(photo!.path));
                            await uploadTask.then((event) {
                              event.ref.getDownloadURL().then((value) {
                                galleryImages.add(value);
                                debugPrint("adding new url to gallery: $value");
                              });
                            }).catchError((onError) {
                              debugPrint(
                                  "error uploading a gallery image: $onError");
                            });
                          }
                          List<String> total = widget.food.gallery
                            ..addAll(galleryImages);
                          FirebaseFirestore.instance
                              .collection("meals")
                              .doc(widget.food.foodId)
                              .update({"gallery": total.join(",")}).then(
                                  (value) {
                            widget.food.gallery = total;
                            Navigator.pop(context, true);
                          }).catchError((onError) {
                            debugPrint("Error found adding Gallery");
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload,
                                size: 30.0,
                                color: Colors.black,
                              ),
                              Text("Upload Selected Images"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _localGallery.removeAt(globalIndex);
                          });
                        },
                        child: Text("Delete this Picture"))
                  ],
                ),
        ));
  }

  int globalIndex = 0;
  List<String> galleryImages = [];
  bool changed = false;
}
