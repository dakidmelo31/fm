// ignore_for_file: dead_code, duplicate_ignore
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration_picker_dialog_box/duration_picker_dialog_box.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/models/food_model.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:merchants/providers/global_data.dart';
import 'package:merchants/providers/restaurant_provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:uuid/uuid.dart';

import '../global.dart';
import '../providers/notification_service.dart';
import '../themes/light_theme.dart';

CollectionReference users =
    FirebaseFirestore.instance.collection("restaurants");
CollectionReference subscriptions =
    FirebaseFirestore.instance.collection("subscriptions");

class NewMeal extends StatefulWidget {
  static const routeName = "/add_meal";
  const NewMeal({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  _NewMealState createState() => _NewMealState();
}

class _NewMealState extends State<NewMeal> with TickerProviderStateMixin {
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
    "Vegetarian",
    "Casual",
    "Daily",
    "Classic"
  ];
  File? _img;
  List<File?> gallery = [];
  List<String> accessories = [],
      categories = [],
      galleryImages = [],
      _selectedCategories = [];
  bool changed = false;
  ImagePicker picker = ImagePicker();
  ScrollController _scrollController = ScrollController();

  Widget currentScreenWidget = Container(
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(flex: 3),
        Lottie.asset("assets/app/animations/upload1.json",
            fit: BoxFit.contain, alignment: Alignment.center),
        Spacer(flex: 2),
        Text("Uploading Product"),
        Spacer(flex: 1),
      ],
    ),
  );
  bool uploading = false;

  @override
  void initState() {
    auth.currentUser != null
        ? null
        : Navigator.popUntil(context, (HomeScreen) => true);

    super.initState();
    tz.initializeTimeZones();
  }

  _selectImg() async {
    XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxHeight: 500,
        maxWidth: 360);
    setState(() {
      if (image != null) _img = File(image.path);
    });
  }

  double postSize = 0.0;
  _selectGallery() async {
    postSize = 0.0;
    HapticFeedback.heavyImpact();
    List<XFile?>? myGallery = await picker.pickMultiImage(
        imageQuality: 95, maxHeight: 500, maxWidth: 360);
    for (var item in myGallery!) {
      gallery.add(
        File(item!.path),
      );

      setState(() {
        debugPrint("total gallery pictures: ${gallery.length}");
      });
    }
    Fluttertoast.showToast(
        msg: "${gallery.length} images selected",
        backgroundColor: Colors.lightGreen);

    // if (_img != null) postSize += await _img!.length() / 1000000;

    debugPrint("total gallery size is: $postSize Mb");
  }

  _uploadGallery() async {
    final uuid = const Uuid();
    if (gallery.isEmpty) {
      return "";
    } else {
      for (File? photo in gallery) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child("uploads/" + uuid.v4());
        UploadTask uploadTask = ref.putFile(File(photo!.path));
        await uploadTask.then((event) {
          event.ref.getDownloadURL().then((value) {
            galleryImages.add(value);
            debugPrint("adding new url to gallery: $value");
          });
        }).catchError((onError) {
          debugPrint("error uploading a gallery image: $onError");
        });
      }
    }
  }

  _uploadProduct(MealsData mealDetails, BuildContext context) async {
    setState(() {
      uploading = true;
    });
    const uuid = Uuid();
    HapticFeedback.heavyImpact();
    if (_img == null) {
      debugPrint("no image selected");
      Fluttertoast.showToast(
        msg: "Please select Photo",
        backgroundColor: Colors.pink,
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }
    NotificationService().showNotification(0, "title", "body", 10);

    await _uploadGallery();

    //check if user's data already exists
    debugPrint("Upload user's Photo");
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("uploads/" + uuid.v4());
    UploadTask uploadTask = ref.putFile(File(_img!.path));
    await uploadTask.then((event) {
      event.ref.getDownloadURL().then((value) async {
        debugPrint("current URL: $value");
        Food food = Food(
            foodId: "",
            ingredients: [],
            available: _available,
            description: _descriptionController.text,
            likes: 0,
            comments: 0,
            image: value,
            name: _productName.text,
            price: double.parse(_productPrice.text),
            restaurantId: auth.currentUser!.uid,
            duration: _productDuration.text,
            compliments: accessories,
            verified: false,
            averageRating: 0,
            gallery: galleryImages,
            categories: categories);

        if (duration != null) {}

        FirebaseFirestore.instance.collection("meals").add(
          {
            "name": food.name,
            "available": food.available,
            "price": food.price,
            "duration":
                "${duration?.inMinutes == null ? 0 : duration!.inMinutes} Mins",
            "categories": _selectedCategories,
            "restaurantId": food.restaurantId,
            "image": food.image,
            "description": food.description,
            "gallery": galleryImages,
            "likes": 0,
            "comments": 0,
            "accessories": accessories,
            "ingredients": food.ingredients,
            "averageRating": food.averageRating,
            "verified": food.verified,
            "score": 0,
            "created_time": FieldValue.serverTimestamp()
          },
        ).then(
          (value) async {
            // Send message to subscribers.
            debugPrint("Done Adding Meal");
            mealDetails.meals.clear();
            mealDetails.loadMeals();
            sendTopicNotification(
                type: "meal",
                typeId: value.id,
                title: widget.restaurant.companyName + " just posted meal",
                description: widget.restaurant.companyName.toUpperCase() +
                    " just added a new product to their store".toUpperCase(),
                image: food.image);
          },
        ).catchError((onError) {
          debugPrint("found error ${onError}");
        });
      }).then((value) {
        debugPrint("Now time to upload gallery");
      }).catchError((onError) {
        debugPrint("Error was found: $onError");
      }).whenComplete(() {
        debugPrint("done");
        Fluttertoast.showToast(
          msg: "Done Uploading meal",
          backgroundColor: Colors.black.withOpacity(.7),
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        Navigator.of(context).pop();
      }); //Navigator.of(context).pop()
    });
  }

  late MealsData mealDetails;
  final _mealKey = GlobalKey<FormState>();
  bool _available = false;
  Duration? duration;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _productName = TextEditingController();
  TextEditingController _productPrice = TextEditingController();
  TextEditingController _productAccesories = TextEditingController();
  TextEditingController _productDuration = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    mealDetails = Provider.of<MealsData>(context, listen: false);

    Widget productForm = SafeArea(
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  height: kToolbarHeight,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Create Meal",
                      style: Primary.bigHeading,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    color: Colors.white,
                    width: size.width - 70.0,
                    height: 220.0,
                    child: AnimatedSwitcher(
                        duration: Duration(
                          milliseconds: 700,
                        ),
                        child: _img == null
                            ? Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10.0),
                                color: Colors.grey.withOpacity(.07),
                                elevation: 0,
                                child: InkWell(
                                  onTap: _selectImg,
                                  child: Row(
                                    children: [
                                      Lottie.asset(
                                        "assets/add-image1.json",
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                        width: size.width * .4,
                                        height: size.width * .4,
                                      ),
                                      Text("Tap to pick Image",
                                          style: Primary.bigHeading)
                                    ],
                                  ),
                                ),
                              )
                            : Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 25.0),
                                    child: Material(
                                      elevation: 10.0,
                                      shadowColor: Colors.black.withOpacity(.5),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        child: Image.file(
                                          File(_img!.path),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          width: size.width * .9,
                                          height: size.width * .6,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 30.0, top: 10.0),
                                      child: Container(
                                        width: 30.0,
                                        height: 30.0,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            HapticFeedback.heavyImpact();
                                            Fluttertoast.cancel();
                                            Fluttertoast.showToast(
                                              msg: "New meal must have a photo",
                                              toastLength: Toast.LENGTH_SHORT,
                                              backgroundColor: Colors.pink,
                                            );
                                            setState(() {
                                              _img = null;
                                            });
                                          },
                                          icon: Icon(Icons.close_rounded,
                                              size: 16.0, color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                        switchInCurve: Curves.fastLinearToSlowEaseIn,
                        reverseDuration: Duration(milliseconds: 300),
                        switchOutCurve: Curves.fastOutSlowIn,
                        transitionBuilder: (child, animation) {
                          animation = CurvedAnimation(
                              parent: animation,
                              curve: Curves.fastLinearToSlowEaseIn,
                              reverseCurve: Curves.fastOutSlowIn);

                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        }),
                  ),
                ),
                Container(
                  width: size.width,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        Form(
                          key: _mealKey,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: TextFormField(
                                  controller: _productName,
                                  validator: (val) {
                                    if (val!.isEmpty || val.length < 5) {
                                      return "Enter valid name";
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    label: Text("Name of Meal"),
                                    hintText: "Name of your food",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                  maxLength: 35,
                                  autofocus: false,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: TextFormField(
                                  controller: _productPrice,
                                  validator: (val) {
                                    if (val!.isEmpty || val.length < 5) {
                                      return "Enter valid price";
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    label: const Text("Price"),
                                    hintText: "Selling Price",
                                    prefix: const Text("CFA",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.green)),
                                    border: const OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                  maxLength: 7,
                                  autofocus: false,
                                ),
                              ),
                              Card(
                                elevation: 10,
                                shadowColor: Colors.black.withOpacity(.7),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                  child: TextFormField(
                                    minLines: 3,
                                    maxLines: 5,
                                    maxLength: 100,
                                    controller: _descriptionController,
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(.7)),
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      border: UnderlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      label: Text("Add meal description"),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 40.0,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 10.0),
                                  child: Text(
                                      "Tap to select Categories that apply",
                                      style: Primary.bigHeading),
                                ),
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
                                          if (_selectedCategories
                                              .contains(cat)) {
                                            setState(() {
                                              _selectedCategories.remove(cat);
                                            });
                                          } else {
                                            if (_selectedCategories.length >=
                                                5) {
                                              Fluttertoast.cancel();
                                              Fluttertoast.showToast(
                                                msg:
                                                    "Select 5 categories Maximum",
                                                backgroundColor: Colors.pink,
                                                gravity: ToastGravity.SNACKBAR,
                                                toastLength: Toast.LENGTH_SHORT,
                                                webShowClose: true,
                                              );
                                            } else {
                                              setState(() {
                                                _selectedCategories.add(cat);
                                              });
                                            }
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
                              SizedBox(
                                height: 40.0,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 10.0),
                                  child: Text(
                                    "Things to eat With",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: TextFormField(
                                  controller: _productAccesories,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return "You can't add nothing";
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                      hintText:
                                          "Dodo, chips, Irish Potatoes, etc.",
                                      border: const OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(6),
                                        ),
                                      ),
                                      label: const Text(
                                          "E.g Dodo, Irish, Bobolo, etc."),
                                      suffixIcon: IconButton(
                                          icon: const Icon(Icons.add,
                                              color: Colors.pink),
                                          onPressed: () {
                                            if (accessories.contains(
                                                _productAccesories.text)) {
                                              debugPrint(
                                                  "already has compliment");
                                            } else {
                                              debugPrint(
                                                  "${_productAccesories.text} category added");
                                              setState(() {
                                                accessories.add(
                                                    _productAccesories.text);
                                              });
                                              _productAccesories.text = "";
                                            }
                                          })),
                                  maxLength: 30,
                                  autofocus: false,
                                ),
                              ),
                              SizedBox(
                                  height: 70.0,
                                  width: size.width,
                                  child: accessories.length == 0
                                      ? Text("Compliments show up here",
                                          style: TextStyle(color: Colors.grey))
                                      : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: accessories.length,
                                          physics: BouncingScrollPhysics(),
                                          itemBuilder: (_, index) {
                                            final item = accessories[index];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: InkWell(
                                                  onTap: () {
                                                    accessories.removeAt(index);
                                                    setState(() {
                                                      _productAccesories.text =
                                                          item;
                                                    });
                                                  },
                                                  child: Chip(
                                                      backgroundColor:
                                                          Colors.white,
                                                      elevation: 10.0,
                                                      shadowColor: Colors.black
                                                          .withOpacity(.14),
                                                      labelStyle: TextStyle(
                                                          color: Colors
                                                              .lightGreen),
                                                      label: Text(item))),
                                            );
                                          },
                                        )),
                              ListTile(
                                title: const Text("Time to get Ready"),
                                subtitle: const Text(
                                    "How long will it take to get ready?"),
                                leading: const Icon(Icons.timer),
                                trailing: Text(
                                    duration != null
                                        ? "${duration!.inMinutes} Mins"
                                        : "0 minutes",
                                    style: const TextStyle(color: Colors.blue)),
                                onTap: () async {
                                  duration = await showDurationPicker(
                                      context: context,
                                      showHead: true,
                                      confirmText: "Select",
                                      cancelText: "Cancel",
                                      durationPickerMode:
                                          DurationPickerMode.Minute,
                                      initialDuration: const Duration(
                                          hours: 0,
                                          minutes: 15,
                                          seconds: 0,
                                          milliseconds: 0,
                                          microseconds: 0));
                                  setState(() {});
                                },
                              ),
                              Card(
                                elevation: 10,
                                shadowColor: Colors.black.withOpacity(.3),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _available = !_available;
                                    });
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 70,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Meal currently Available"),
                                        CupertinoSwitch(
                                            value: _available,
                                            onChanged: (onChanged) {
                                              setState(() {
                                                _available = onChanged;
                                              });
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              AnimatedSwitcher(
                                duration: Duration(
                                  milliseconds: 800,
                                ),
                                reverseDuration: Duration(milliseconds: 600),
                                transitionBuilder: (child, animation) {
                                  animation = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.fastLinearToSlowEaseIn,
                                      reverseCurve: Curves.decelerate);
                                  return SizeTransition(
                                    sizeFactor: animation,
                                    axis: Axis.horizontal,
                                    axisAlignment: 0.0,
                                    child: child,
                                  );
                                },
                                child: gallery.isEmpty
                                    ? Card(
                                        color: Colors.white,
                                        elevation: 0,
                                        shadowColor:
                                            Colors.grey.withOpacity(.19),
                                        child: InkWell(
                                          onTap: _selectGallery,
                                          child: SizedBox(
                                            width: size.width * .9,
                                            height: size.width * .3,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Lottie.asset(
                                                  "assets/gallery1.json",
                                                  fit: BoxFit.contain,
                                                ),
                                                Text(
                                                  "Tap to add gallery",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        width: size.width,
                                        height: 170.0,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics: const BouncingScrollPhysics(
                                                parent:
                                                    AlwaysScrollableScrollPhysics()),
                                            itemCount: gallery.length,
                                            itemBuilder: (_, index) {
                                              return gallery.length - 1 != index
                                                  ? Stack(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Material(
                                                            shadowColor: Colors
                                                                .black
                                                                .withOpacity(
                                                                    .2),
                                                            elevation: 10,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    8),
                                                              ),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      PageRouteBuilder(
                                                                        transitionDuration:
                                                                            Duration(milliseconds: 1200),
                                                                        reverseTransitionDuration:
                                                                            Duration(milliseconds: 300),
                                                                        transitionsBuilder: (_,
                                                                            animation,
                                                                            anotherAnimation,
                                                                            child) {
                                                                          animation = CurvedAnimation(
                                                                              parent: animation,
                                                                              curve: Curves.fastLinearToSlowEaseIn);
                                                                          return SizeTransition(
                                                                            sizeFactor:
                                                                                animation,
                                                                            axis:
                                                                                Axis.horizontal,
                                                                            axisAlignment:
                                                                                0.0,
                                                                            child:
                                                                                child,
                                                                          );
                                                                        },
                                                                        opaque:
                                                                            false,
                                                                        barrierColor: Colors
                                                                            .black
                                                                            .withOpacity(.8),
                                                                        pageBuilder: (context,
                                                                            animation,
                                                                            secondaryAnimation) {
                                                                          animation = CurvedAnimation(
                                                                              parent: animation,
                                                                              curve: Curves.fastLinearToSlowEaseIn);
                                                                          return SizeTransition(
                                                                            sizeFactor:
                                                                                animation,
                                                                            axis:
                                                                                Axis.horizontal,
                                                                            axisAlignment:
                                                                                0.0,
                                                                            child:
                                                                                Scaffold(
                                                                              backgroundColor: Colors.black.withOpacity(.8),
                                                                              body: SizedBox(
                                                                                width: size.width,
                                                                                height: size.height,
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Spacer(),
                                                                                    Align(
                                                                                      alignment: Alignment.center,
                                                                                      child: Hero(
                                                                                        tag: gallery[index]!.path.toUpperCase(),
                                                                                        child: ClipRRect(
                                                                                          borderRadius: BorderRadius.circular(
                                                                                            6,
                                                                                          ),
                                                                                          child: Image.file(
                                                                                            File(gallery[index]!.path),
                                                                                            fit: BoxFit.cover,
                                                                                            alignment: Alignment.center,
                                                                                            width: size.width * .9,
                                                                                            height: size.width,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Spacer(),
                                                                                    Align(
                                                                                      alignment: Alignment.bottomCenter,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(bottom: 28.0),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                                                                      _img = gallery[index];
                                                                                                      if (_img != null) gallery[index] = _img;
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
                                                                child: Hero(
                                                                  tag: gallery[
                                                                          index]!
                                                                      .path
                                                                      .toUpperCase(),
                                                                  child:
                                                                      ClipOval(
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          100.0,
                                                                      height:
                                                                          100.0,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child: Image
                                                                          .file(
                                                                        File(gallery[index]!
                                                                            .path),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        alignment:
                                                                            Alignment.center,
                                                                        width:
                                                                            100,
                                                                        height:
                                                                            100,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Material(
                                                              color:
                                                                  Colors.white,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  HapticFeedback
                                                                      .heavyImpact();
                                                                  setState(() {
                                                                    gallery.remove(
                                                                        gallery[
                                                                            index]);
                                                                  });
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .pink,
                                                                    size: 30.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Material(
                                                                shadowColor: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        .2),
                                                                elevation: 10,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            8),
                                                                  ),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          PageRouteBuilder(
                                                                            transitionDuration:
                                                                                Duration(milliseconds: 1200),
                                                                            reverseTransitionDuration:
                                                                                Duration(milliseconds: 300),
                                                                            transitionsBuilder: (_,
                                                                                animation,
                                                                                anotherAnimation,
                                                                                child) {
                                                                              animation = CurvedAnimation(parent: animation, curve: Curves.fastLinearToSlowEaseIn);
                                                                              return SizeTransition(
                                                                                sizeFactor: animation,
                                                                                axis: Axis.horizontal,
                                                                                axisAlignment: 0.0,
                                                                                child: child,
                                                                              );
                                                                            },
                                                                            opaque:
                                                                                false,
                                                                            barrierColor:
                                                                                Colors.black.withOpacity(.8),
                                                                            pageBuilder: (context,
                                                                                animation,
                                                                                secondaryAnimation) {
                                                                              animation = CurvedAnimation(parent: animation, curve: Curves.fastLinearToSlowEaseIn);
                                                                              return SizeTransition(
                                                                                sizeFactor: animation,
                                                                                axis: Axis.horizontal,
                                                                                axisAlignment: 0.0,
                                                                                child: Scaffold(
                                                                                  backgroundColor: Colors.black.withOpacity(.8),
                                                                                  body: SizedBox(
                                                                                    width: size.width,
                                                                                    height: size.height,
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Spacer(),
                                                                                        Align(
                                                                                          alignment: Alignment.center,
                                                                                          child: Hero(
                                                                                            tag: gallery[index]!.path.toUpperCase(),
                                                                                            child: ClipRRect(
                                                                                              borderRadius: BorderRadius.circular(
                                                                                                6,
                                                                                              ),
                                                                                              child: Image.file(
                                                                                                File(gallery[index]!.path),
                                                                                                fit: BoxFit.cover,
                                                                                                alignment: Alignment.center,
                                                                                                width: size.width * .9,
                                                                                                height: size.width,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Spacer(),
                                                                                        Align(
                                                                                          alignment: Alignment.bottomCenter,
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.only(bottom: 28.0),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                                                                          _img = gallery[index];
                                                                                                          if (_img != null) gallery[index] = _img;
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
                                                                    child: Hero(
                                                                      tag: gallery[
                                                                              index]!
                                                                          .path
                                                                          .toUpperCase(),
                                                                      child:
                                                                          ClipOval(
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              100.0,
                                                                          height:
                                                                              100.0,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Image.file(
                                                                            File(gallery[index]!.path),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            width:
                                                                                100,
                                                                            height:
                                                                                100,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child: Material(
                                                                  color: Colors
                                                                      .white,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      HapticFeedback
                                                                          .heavyImpact();
                                                                      setState(
                                                                          () {
                                                                        gallery.remove(
                                                                            gallery[index]);
                                                                      });
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              5.0),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Colors
                                                                            .pink,
                                                                        size:
                                                                            30.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          children: [
                                                            IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  gallery
                                                                      .clear();
                                                                });
                                                              },
                                                              icon: Icon(
                                                                Icons.clear_all,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed:
                                                                  _selectGallery,
                                                              icon: Icon(
                                                                Icons
                                                                    .add_a_photo,
                                                                color: Colors
                                                                    .lightGreen,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    );
                                            }),
                                      ),
                              ),
                              if (postSize < .6 && false)
                                // ignore: dead_code
                                Text(
                                  "${gallery.length} Images selected: ${postSize * 1000} Kb (Good)",
                                  style: TextStyle(
                                      color: Colors.lightGreen,
                                      fontWeight: FontWeight.w700),
                                ),
                              if (postSize >= .6 && postSize < 2.0 && false)
                                Text(
                                    "${gallery.length} Images selected: ${postSize.toStringAsFixed(2)} Mb (Okay)",
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w700)),
                              if (postSize >= 2.0 && false)
                                Text(
                                    "${gallery.length} Images selected: ${postSize.toStringAsFixed(2)} Mb (reduce image sizes)",
                                    style: TextStyle(
                                        color: Colors.pink,
                                        fontWeight: FontWeight.w700)),
                              if (!changed)
                                Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 35.0),
                                  elevation: 15.0,
                                  color: Theme.of(context).primaryColor,
                                  child: InkWell(
                                    onTap: () {
                                      if (gallery.isNotEmpty &&
                                          _img != null &&
                                          _productName.text.length > 1) {
                                        setState(() {
                                          changed = true;
                                        });

                                        debugPrint("save meal");
                                        _uploadProduct(mealDetails, context);
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Add photo and Name",
                                          backgroundColor: Colors.pink,
                                          toastLength: Toast.LENGTH_LONG,
                                        );
                                      }

                                      HapticFeedback.heavyImpact();
                                      if (_img == null) {
                                        _scrollController.animateTo(0.0,
                                            curve: Curves.decelerate,
                                            duration:
                                                Duration(milliseconds: 800));
                                        debugPrint("no image selected");
                                        Fluttertoast.showToast(
                                          msg: "Please select Photo",
                                          backgroundColor: Colors.pink,
                                          toastLength: Toast.LENGTH_LONG,
                                        );
                                        return;
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40.0, vertical: 12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.upload_rounded,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                          Text(
                                            "Publish Meal",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );

    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: Scaffold(
              body: AnimatedSwitcher(
                duration: Duration(milliseconds: 800),
                transitionBuilder: (child, animation) {
                  animation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.fastLinearToSlowEaseIn,
                      reverseCurve: Curves.fastOutSlowIn);

                  return ScaleTransition(
                    scale: animation,
                    alignment: Alignment.bottomCenter,
                    filterQuality: FilterQuality.high,
                    child: child,
                  );
                },
                child: uploading
                    ? Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Lottie.asset("assets/uploading-animation1.json"),
                            Shimmer(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.withOpacity(.3),
                                    Colors.white,
                                    Colors.grey
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                enabled: true,
                                child: Text("Uploading Product Now")),
                          ],
                        ))
                    : productForm,
              ),
            ),
          ),
          if (!uploading)
            Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.pink,
                      size: 30,
                    ),
                    onPressed: () async {
                      bool? outcome = await showCupertinoModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          barrierColor: Colors.black.withOpacity(.7),
                          duration: Duration(milliseconds: 800),
                          isDismissible: true,
                          builder: (builder) {
                            return Material(
                              color: Colors.transparent,
                              child: Card(
                                child: SizedBox(
                                  width: size.width * .7,
                                  height: 180.0,
                                  child: Column(
                                    children: [
                                      Spacer(),
                                      Text("Are you sure?",
                                          style: Primary.bigHeading),
                                      Spacer(),
                                      Row(
                                        children: [
                                          Spacer(),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: Text("Yes")),
                                          Spacer(),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: Text("Cancel")),
                                          Spacer(),
                                        ],
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });

                      if (outcome == true) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  previousPage() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 400), curve: Curves.linearToEaseOut);
  }

  nextPage() {
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 600), curve: Curves.linearToEaseOut);
  }

  PageController _pageController = PageController(initialPage: 0);
}
