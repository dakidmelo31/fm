import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration_picker_dialog_box/duration_picker_dialog_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/models/food_model.dart';
import 'package:merchants/providers/restaurant_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:uuid/uuid.dart';

import '../providers/notification_service.dart';
import '../widgets/create_service.dart';

CollectionReference users =
    FirebaseFirestore.instance.collection("restaurants");
CollectionReference subscriptions =
    FirebaseFirestore.instance.collection("subscriptions");
FirebaseAuth auth = FirebaseAuth.instance;

class NewMeal extends StatefulWidget {
  static const routeName = "/add_meal";
  const NewMeal({Key? key}) : super(key: key);

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
      _img = File(image!.path);
    });
  }

  _selectGallery() async {
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
    const uuid = Uuid();
    if (_img == null) {
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
            comments: 32,
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

        FirebaseFirestore.instance.collection("meals").doc().set(
          {
            "name": food.name,
            "available": food.available,
            "price": food.price,
            "duration":
                "${duration?.inMinutes == null ? 0 : duration!.inMinutes} Mins",
            "categories": categories,
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
            "created_time": FieldValue.serverTimestamp()
          },
          SetOptions(merge: true),
        ).then(
          (value) async {
            // Send message to subscribers.
            debugPrint("Done Adding Meal");
            mealDetails.loadMeals();
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

    Widget productForm = InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              InkWell(
                onTap: nextPage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: const Text(
                          "Create Meal",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text("Service"),
                        Icon(
                          Icons.chevron_right_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  color: Colors.white,
                  width: size.width - 70.0,
                  height: 220.0,
                  child: InkWell(
                    onTap: _selectImg,
                    child: AnimatedSwitcher(
                        duration: Duration(
                          milliseconds: 700,
                        ),
                        child: _img == null
                            ? Lottie.asset(
                                "assets/add-image1.json",
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.file(
                                File(_img!.path),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: double.infinity,
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
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
                                  "Category(s)",
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
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
                                        if (_selectedCategories.contains(cat)) {
                                          setState(() {
                                            _selectedCategories.remove(cat);
                                          });
                                        } else {
                                          setState(() {
                                            _selectedCategories.add(cat);
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
                                                color: Colors
                                                    .primaries[_categories
                                                            .indexOf(cat) >
                                                        Colors.primaries
                                                                .length -
                                                            1
                                                    ? _categories.indexOf(cat) -
                                                        Colors.primaries.length
                                                    : _categories
                                                        .indexOf(cat)]),
                                            labelPadding: EdgeInsets.symmetric(
                                                vertical: 5.0, horizontal: 8.0),
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
                                  style: TextStyle(fontWeight: FontWeight.w700),
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
                                    label: const Text("On the side"),
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
                                              accessories
                                                  .add(_productAccesories.text);
                                            });
                                            _productAccesories.text = "";
                                          }
                                        })),
                                maxLength: 30,
                                autofocus: false,
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 700),
                              curve: Curves.fastOutSlowIn,
                              width: double.infinity,
                              height: accessories.isEmpty ? 0.0 : 60.0,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                scrollDirection: Axis.horizontal,
                                itemCount: accessories.length,
                                itemBuilder: (_, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Chip(
                                      deleteButtonTooltipMessage: "remove",
                                      visualDensity: VisualDensity.comfortable,
                                      label: Text(
                                        accessories[index],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      avatar: const Icon(
                                          Icons.fastfood_outlined,
                                          color: Colors.white,
                                          size: 16),
                                      backgroundColor: Colors.lightGreen,
                                      deleteIcon: const Icon(
                                          Icons.close_outlined,
                                          color: Colors.amber),
                                      elevation: 8,
                                      shadowColor:
                                          Colors.black.withOpacity(.11),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 10),
                                      deleteIconColor: Colors.pink,
                                      onDeleted: () {
                                        setState(() {
                                          accessories
                                              .remove(accessories[index]);
                                        });
                                        debugPrint("remove item from list");
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
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
                            ListTile(
                              title: const Text("Pick Gallery Images"),
                              subtitle: const Text(
                                  "Pick multiple photos of this meal to showcase"),
                              onTap: _selectGallery,
                              trailing: const Icon(Icons.chevron_right),
                            ),
                            GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                        crossAxisCount: 2),
                                itemCount: gallery.length,
                                itemBuilder: (_, index) {
                                  return InkWell(
                                    onLongPress: () {
                                      HapticFeedback.mediumImpact();
                                      setState(() {
                                        gallery.remove(gallery[index]);
                                      });
                                    },
                                    child: Material(
                                      shadowColor: Colors.black.withOpacity(.2),
                                      elevation: 10,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                        child: Image.file(
                                          File(gallery[index]!.path),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          width: 100,
                                          height: 122,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
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

                                      _uploadProduct(mealDetails, context);
                                    }

                                    HapticFeedback.mediumImpact();
                                    debugPrint("save meal");
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
                            CupertinoButton(
                                child: const Text(
                                  "Cancel Product",
                                  style: const TextStyle(color: Colors.pink),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                })
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
    );

    return SafeArea(
      child: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Scaffold(
            body: AnimatedSwitcher(
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.bounceInOut,
              child: changed
                  ? currentScreenWidget
                  : AnimatedOpacity(
                      duration: Duration(milliseconds: 350),
                      opacity: changed ? 0 : 1.0,
                      child: productForm,
                    ),
            ),
          ),
          CreateService()
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
