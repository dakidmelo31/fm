import 'dart:io';
import 'dart:math';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/restaurants.dart';
import '../providers/auth_provider.dart';

class UploadGallery extends StatefulWidget {
  const UploadGallery({Key? key}) : super(key: key);

  @override
  State<UploadGallery> createState() => _UploadGalleryState();
}

class _UploadGalleryState extends State<UploadGallery>
    with TickerProviderStateMixin {
  List<File?> gallery = [];
  List<String> galleryImages = [];
  var _index = 0;
  bool uploading = false;
  late AnimationController _controller;
  List<String> selected = [];
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    Future.delayed(Duration(milliseconds: 100), () {
      _controller.forward();
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ImagePicker picker = ImagePicker();

  addToGallery() async {
    List<XFile>? _images = await picker.pickMultiImage(imageQuality: 90);
    if (_images != null) {
      _images.forEach((element) {
        gallery.add(File(element.path));
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _userData = Provider.of<Auth>(context, listen: true);
    final Restaurant restaurant = _userData.restaurant;

    Size size = MediaQuery.of(context).size;
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return AnimatedSwitcher(
            transitionBuilder: ((child, animation) {
              return FadeTransition(
                opacity: CurvedAnimation(
                    curve: Curves.fastLinearToSlowEaseIn,
                    parent: animation,
                    reverseCurve: Curves.fastOutSlowIn),
                child: child,
              );
            }),
            duration: Duration(milliseconds: 1200),
            child: uploading
                ? Scaffold(
                    body: Center(
                      child: Lottie.asset("assets/uploading-animation1.json",
                          width: size.width,
                          fit: BoxFit.contain,
                          alignment: Alignment.center),
                    ),
                  )
                : SafeArea(
                    child: Scaffold(
                      backgroundColor:
                          gallery.isEmpty ? Colors.white : Colors.black,
                      body: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                              child: Opacity(
                            opacity: (1 - _controller.value),
                            child: ListView(
                              children: [
                                Lottie.asset(
                                  "assets/data.json",
                                  alignment: Alignment.center,
                                  width: size.width,
                                ),
                                Lottie.asset(
                                  "assets/data.json",
                                  alignment: Alignment.center,
                                  width: size.width,
                                ),
                              ],
                            ),
                          )),
                          Container(
                              width: size.width,
                              height: size.height,
                              child: Column(
                                children: [
                                  if (gallery.isNotEmpty)
                                    SizedBox(
                                      width: size.width,
                                      height: 80,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    gallery.removeAt(_index);
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.delete_forever_outlined,
                                                  color: Colors.pink,
                                                )),
                                          ]),
                                    ),
                                  if (gallery.isEmpty && selected.isNotEmpty)
                                    SizedBox(
                                      width: size.width,
                                      height: 80,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  selected.clear();
                                                  setState(() {});
                                                },
                                                icon: Icon(
                                                  Icons.refresh,
                                                  size: 30.0,
                                                  color: Colors.blue,
                                                )),
                                            AvatarGlow(
                                              endRadius: 45.0,
                                              animate: true,
                                              showTwoGlows: true,
                                              curve: Curves.fastOutSlowIn,
                                              duration:
                                                  Duration(milliseconds: 800),
                                              glowColor: Colors.pink,
                                              shape: BoxShape.circle,
                                              startDelay:
                                                  Duration(milliseconds: 900),
                                              repeatPauseDuration:
                                                  Duration(milliseconds: 1000),
                                              child: IconButton(
                                                  onPressed: () {
                                                    //delete files
                                                    for (String path
                                                        in selected) {
                                                      FirebaseStorage.instance
                                                          .refFromURL(path)
                                                          .delete()
                                                          .then((value) =>
                                                              debugPrint(
                                                                  "photo deleted successfully"))
                                                          .catchError((er) =>
                                                              debugPrint(
                                                                  "$er"));
                                                    }

                                                    setState(() {
                                                      restaurant.gallery
                                                          .removeWhere(
                                                        (element) => selected
                                                            .any((data) =>
                                                                data ==
                                                                element),
                                                      );
                                                      firestore
                                                          .collection(
                                                              "restaurants")
                                                          .doc(restaurant
                                                              .restaurantId)
                                                          .update(
                                                        {
                                                          "gallery":
                                                              restaurant.gallery
                                                        },
                                                      ).then(
                                                        (value) => debugPrint(
                                                            "remove this information"),
                                                      );
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.check_circle_outline,
                                                    size: 30.0,
                                                    color: Colors.pink,
                                                  )),
                                            ),
                                          ]),
                                    ),
                                  if (gallery.isEmpty)
                                    Expanded(
                                      child: Center(
                                        child: MasonryGridView.count(
                                          shrinkWrap: true,
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 4,
                                          crossAxisSpacing: 10.0,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: restaurant.gallery.length,
                                          itemBuilder: (context, index) {
                                            String image =
                                                restaurant.gallery[index];

                                            return InkWell(
                                              onLongPress: () {
                                                HapticFeedback.heavyImpact();
                                                if (selected.contains(image)) {
                                                  selected.remove(image);
                                                } else {
                                                  selected.add(image);
                                                }
                                                setState(() {});
                                              },
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  AnimatedOpacity(
                                                    duration: Duration(
                                                        milliseconds: 400),
                                                    opacity:
                                                        selected.contains(image)
                                                            ? 0.125
                                                            : 1.0,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius
                                                          .circular(Random()
                                                                  .nextBool()
                                                              ? 12
                                                              : 20.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          debugPrint(image);
                                                          Navigator.push(
                                                            context,
                                                            PageRouteBuilder(
                                                              barrierColor: Colors
                                                                  .transparent,
                                                              barrierDismissible:
                                                                  true,
                                                              opaque: false,
                                                              transitionDuration:
                                                                  Duration(
                                                                      milliseconds:
                                                                          900),
                                                              reverseTransitionDuration:
                                                                  Duration(
                                                                      milliseconds:
                                                                          300),
                                                              pageBuilder: (BuildContext
                                                                      context,
                                                                  Animation<
                                                                          double>
                                                                      animation,
                                                                  Animation<
                                                                          double>
                                                                      secondaryAnimation) {
                                                                animation = CurvedAnimation(
                                                                    parent:
                                                                        animation,
                                                                    curve: Curves
                                                                        .fastLinearToSlowEaseIn);
                                                                return FadeTransition(
                                                                  opacity:
                                                                      animation,
                                                                  child:
                                                                      Scaffold(
                                                                    backgroundColor: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            .6),
                                                                    body:
                                                                        Center(
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Hero(
                                                                            tag:
                                                                                image,
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              imageUrl: image,
                                                                              placeholder: (_, __) => Lottie.asset("assets/loading7.json"),
                                                                              alignment: Alignment.center,
                                                                              fit: BoxFit.cover,
                                                                              errorWidget: (_, __, ___) => Lottie.asset(
                                                                                "assets/no-connection.json",
                                                                                alignment: Alignment.center,
                                                                                fit: BoxFit.fitHeight,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.bottomCenter,
                                                                            child:
                                                                                Hero(
                                                                              tag: "button",
                                                                              child: ElevatedButton(
                                                                                  onPressed: () {
                                                                                    _userData.setBusinessPhoto(image);
                                                                                    firestore.collection("restaurants").doc(restaurant.restaurantId).update({"gallery": restaurant.gallery, "businessPhoto": image}).then((value) => debugPrint("successful Printing")).catchError((er) {
                                                                                          debugPrint("Error during switch $er");
                                                                                        });
                                                                                    setState(() {});
                                                                                  },
                                                                                  child: Text("Make This Profile Photo")),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        child: Hero(
                                                          tag: image,
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: image,
                                                            placeholder: (_,
                                                                    __) =>
                                                                Lottie.asset(
                                                                    "assets/loading7.json"),
                                                            alignment: Alignment
                                                                .center,
                                                            fit: BoxFit.cover,
                                                            errorWidget: (_, __,
                                                                    ___) =>
                                                                Lottie.asset(
                                                              "assets/no-connection2.json",
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (selected.contains(image))
                                                    Center(
                                                      child: Column(
                                                        children: [
                                                          Text("Removed",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .pink,
                                                                  fontSize:
                                                                      20.0)),
                                                          Text(
                                                              "Hold to bring back"),
                                                        ],
                                                      ),
                                                    )
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  if (gallery.isEmpty)
                                    Text("Hold pictures down to remove them"),
                                  if (gallery.isNotEmpty)
                                    Expanded(
                                      child: CarouselSlider.builder(
                                        itemCount: gallery.length,
                                        itemBuilder: (_, index, nextInt) {
                                          File image = gallery[index]!;
                                          _index = index;

                                          return Image.file(
                                            image,
                                            alignment: Alignment.center,
                                            width: size.width,
                                          );
                                        },
                                        options: CarouselOptions(
                                          onScrolled: (data) {
                                            _index = data!.floor();
                                          },
                                          enableInfiniteScroll: false,
                                          height: double.infinity,
                                          padEnds: true,
                                          scrollPhysics: BouncingScrollPhysics(
                                              parent:
                                                  AlwaysScrollableScrollPhysics()),
                                          enlargeCenterPage: true,
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    width: size.width,
                                    height: 80,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          BackButton(
                                            color: Colors.orange,
                                          ),
                                          FloatingActionButton(
                                              backgroundColor: Colors.blue,
                                              onPressed: addToGallery,
                                              child: Icon(
                                                Icons.add_business_rounded,
                                                color: Colors.white,
                                              )),
                                          Hero(
                                            tag: "button",
                                            child: Material(
                                              color: Colors.transparent,
                                              child: IconButton(
                                                  onPressed: () async {
                                                    HapticFeedback
                                                        .heavyImpact();
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Uploading pictures...",
                                                      backgroundColor:
                                                          Colors.lightGreen,
                                                      fontSize: 14.0,
                                                      textColor: Colors.white,
                                                      toastLength:
                                                          Toast.LENGTH_LONG,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                    );
                                                    setState(() {
                                                      uploading = true;
                                                    });
                                                    final uuid = Uuid();
                                                    for (File? photo
                                                        in gallery) {
                                                      FirebaseStorage storage =
                                                          FirebaseStorage
                                                              .instance;
                                                      Reference ref = storage
                                                          .ref()
                                                          .child("uploads/" +
                                                              uuid.v4());
                                                      UploadTask uploadTask =
                                                          ref.putFile(File(
                                                              photo!.path));
                                                      await uploadTask
                                                          .then((event) {
                                                        event.ref
                                                            .getDownloadURL()
                                                            .then((value) {
                                                          galleryImages
                                                              .add(value);
                                                          debugPrint(
                                                              "adding new url to gallery: $value");
                                                        });
                                                      }).catchError((onError) {
                                                        debugPrint(
                                                            "error uploading a gallery image: $onError");
                                                      });
                                                    }
                                                    firestore
                                                        .collection(
                                                            "restaurants")
                                                        .doc(restaurant
                                                            .restaurantId)
                                                        .update({
                                                          "gallery": List<
                                                                  String>.from(
                                                              restaurant
                                                                  .gallery)
                                                            ..addAll(
                                                                galleryImages)
                                                        })
                                                        .then((value) =>
                                                            restaurant.gallery =
                                                                galleryImages)
                                                        .then((value) =>
                                                            Navigator.pop(
                                                                context, true))
                                                        .catchError((onError) {
                                                          debugPrint(
                                                              "Error found adding Gallery");
                                                        });
                                                  },
                                                  icon: Icon(
                                                    Icons.upload_rounded,
                                                    color: Colors.green,
                                                  )),
                                            ),
                                          ),
                                        ]),
                                  )
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
          );
        });
  }
}
