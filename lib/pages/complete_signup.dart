import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/global.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../animations/slideup_tween.dart';
import 'home_screen.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile(
      {Key? key,
      required this.completedAnimation,
      required this.reverseAnimation,
      required this.completedCallback})
      : super(key: key);
  final Animation<double> completedAnimation;
  final VoidCallback completedCallback;
  final VoidCallback reverseAnimation;

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

CollectionReference users =
    FirebaseFirestore.instance.collection("restaurants");

class _CompleteProfileState extends State<CompleteProfile> {
  var locationMessage;
  String location = "";
  double lat = 0.0, lng = 0.0;

  Future<bool> getLocation() async {
    var locationStatus = await Permission.location.status;
    if (locationStatus.isGranted) {
      debugPrint("granted");
    } else if (locationStatus.isDenied) {
      debugPrint("Not granted");

      await [Permission.location].request();
    } else if (locationStatus.isPermanentlyDenied) {
      openAppSettings().then((value) {
        setState(() {});
      });
    }
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    var lastPosition = await Geolocator.getLastKnownPosition();
    print("position is $lastPosition");

    setState(() {
      lat = position.latitude;
      lng = position.longitude;
    });
    debugPrint("latitude: $lat, and logitude: $lng");
    return locationStatus.isGranted ? true : locationStatus.isLimited;
  }

  int currentStep = 0;
  double _deliveryCost = 0;
  TextEditingController _nameController = TextEditingController(),
      _usernameController = TextEditingController(),
      _emailController = TextEditingController(),
      _companyNameController = TextEditingController(),
      _companyAddressController = TextEditingController();

  final _generalKey = GlobalKey<FormState>();
  final _shopKey = GlobalKey<FormState>();
  final _extraKey = GlobalKey<FormState>();
  int limit = 3;
  int selectionCount = 0;
  String category = "";
  List<String> _categories = [
        "Normal",
        "Cafe",
        "Street Food",
        "Hotel",
        "Catery",
        "Special Restaurant",
        "Dessert",
        "Home Delivery"
      ],
      _selectedCategories = [];
  late final List<GlobalKey<FormState>> _keys = [
    _generalKey,
    _shopKey,
    _extraKey
  ];
  String _openingTime = "0:00";
  String _closingTime = "0:00";

  Future<TimeOfDay> _timePicker() async {
    debugPrint("show time picker dialog");

    final TimeOfDay time = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TimePickerDialog(
            initialTime: TimeOfDay.now(),
            cancelText: "Cancel",
            confirmText: "Now",
          );
        });
    return time;
  }

  File? image;
  bool _imageSet = false;
  // _imageFromCamera() async {
  //   XFile? _image = await ImagePicker().pickImage(
  //     source: ImageSource.camera,
  //     imageQuality: 50,
  //   );
  //   setState(() {
  //     image = File(_image!.path);
  //     _imageSet = true;
  //   });
  // }

  Future uploadFile() async {
    if (image == null) {
      return;
    }
    String url = "";

    //check if user's data already exists
    bool outcome = await getLocation();

    if (outcome) {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref =
          storage.ref().child("uploads/" + DateTime.now().toString());
      UploadTask uploadTask = ref.putFile(File(image!.path));
      await uploadTask.then((res) {
        res.ref.getDownloadURL().then((value) async {
          debugPrint(_openingTime);

          debugPrint("now about to add users.");

          String? phoneNumber;
          var token = await getFirebaseToken();
          String deviceToken = token.toString();
          final prefs = await SharedPreferences.getInstance();
          if (prefs.containsKey("tmpNumber")) {
            phoneNumber = await prefs.getString("tmpNumber");
          } else {
            setState(() {
              widget.reverseAnimation();
            });
          }

          prefs.setBool("account_created", true);

          await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
                "name": _nameController.text,
                "username": _usernameController.text,
                "avatar": value,
                "email": _emailController.text,
                "phone": phoneNumber,
                "lat": lat,
                "long": lng,
                "totalOrders": 0,
                "blockList": [],
                "companyName": _companyNameController.text,
                "categories": _selectedCategories,
                "gallery": [],
                "address": _companyAddressController.text,
                "businessPhoto": value,
                "openTime": _openingTime,
                "closingTime": _closingTime,
                "score": 0,
                "foodReservation": _foodReservation,
                "homeDelivery": _homeDelivery,
                "specialOrders": _specialOrders,
                "cash": _cash,
                "ghostKitchen": _ghostKitchen,
                "momo": _momo,
                "days": [],
                "variants": ["general"],
                'costs': [_deliveryCost.toInt()],
                "tableReservation": _tableReservation,
                "totalFollowers": 0,
                "deliveryCost": _deliveryCost,
                "comments": 0,
                "verified": false,
                "likes": 0,
                "totalMeals": 0,
                "followers": 0,
                "deviceToken": deviceToken,
                "created_at": FieldValue.serverTimestamp()
              }, SetOptions(merge: true))
              .then((value) async {
                debugPrint("Done signing up user");
                debugPrint("so move then");
                firestore
                    .collection("followers")
                    .doc(auth.currentUser!.uid)
                    .set({"myFollowers": [], "tokens": []}).then(
                        (value) => debugPrint("followers now set"));
                prefs.setString("phone", phoneNumber!);
                Navigator.pushReplacement(
                  // move on.
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(
                      milliseconds: 1200,
                    ),
                    reverseTransitionDuration: Duration(
                      milliseconds: 700,
                    ),
                    opaque: false,
                    transitionsBuilder:
                        (_, animation, anotherAnimation, child) {
                      animation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.fastLinearToSlowEaseIn,
                          reverseCurve: Curves.fastOutSlowIn);
                      return Align(
                        alignment: Alignment.centerRight,
                        child: child,
                      );
                    },
                    pageBuilder: (_, animation, child) {
                      animation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.fastLinearToSlowEaseIn,
                          reverseCurve: Curves.fastOutSlowIn);
                      return SizeTransition(
                        axis: Axis.horizontal,
                        sizeFactor: animation,
                        axisAlignment: 0,
                        child: Home(),
                      );
                    },
                  ),
                );
              })
              .whenComplete(() {})
              .catchError((onError) {
                debugPrint(
                    "found error adding to firebase Firestore: ${onError}");
              });
        });
      });
      return url;
    } else {
      Fluttertoast.showToast(msg: "Your customers need to know where you are.");
    }
  }

  _imageFromGallery() async {
    XFile? _image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    setState(() {
      image = File(_image!.path);
      _imageSet = true;
    });
  }

  TextStyle valueColor = TextStyle(color: Colors.orange);
  @override
  void initState() {
    super.initState();
  }

  String photoURL = "";
  @override
  void dispose() {
    super.dispose();
  }

  bool uploading = false;

  TextStyle whiteText =
      const TextStyle(color: Colors.black, fontWeight: FontWeight.w700);
  TextStyle greenAccent = const TextStyle(color: Colors.lightGreen);
  bool _homeDelivery = false,
      _foodReservation = false,
      _tableReservation = false,
      _specialOrders = false,
      _momo = true,
      _cash = true,
      _ghostKitchen = true,
      _selectAll = false;

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return AnimatedBuilder(
        animation: widget.completedAnimation,
        builder: (_, child) {
          final topHeight =
              0 - (1 - widget.completedAnimation.value) * size.height;

          if (selectionCount >= 3) {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            Future.delayed(
              Duration(seconds: 5),
              () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
            );
          }

          return Positioned(
              top: topHeight,
              width: size.width,
              height: size.height,
              left: 0,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 900),
                reverseDuration: Duration(milliseconds: 300),
                switchInCurve: Curves.fastLinearToSlowEaseIn,
                transitionBuilder: (child, animation) {
                  return SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: animation,
                      curve: Curves.fastLinearToSlowEaseIn,
                    ),
                    axis: Axis.vertical,
                    axisAlignment: 0.0,
                    child: child,
                  );
                },
                child: uploading
                    ? Center(
                        child: Lottie.asset("assets/uploading-animation1.json",
                            width: size.width,
                            fit: BoxFit.contain,
                            alignment: Alignment.center),
                      )
                    : InkWell(
                        onTap: () =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        child: Opacity(
                          opacity: widget.completedAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(170 *
                                  (0.1 + 1 - widget.completedAnimation.value)),
                            ),
                            child: ListView(
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                            height: 70,
                                            width: size.width,
                                            child: Row(
                                              children: [],
                                            )),
                                        Text(
                                          "Create Your Store!",
                                          style: TextStyle(
                                            color: Colors.brown,
                                            fontSize: 35,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 30),
                                        ),
                                        Text(
                                          "Let's get You started",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Stepper(
                                      elevation: 10,
                                      type: StepperType.vertical,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      currentStep: currentStep,
                                      onStepTapped: (int newStep) =>
                                          setState(() {
                                        currentStep = newStep;
                                      }),
                                      onStepContinue: () async {
                                        if (currentStep < 3) {
                                          if (_keys[currentStep]
                                              .currentState!
                                              .validate()) {
                                            debugPrint(
                                                "form number $currentStep is valid");
                                            setState(() {
                                              if (currentStep < 3) {
                                                currentStep++;
                                                debugPrint(
                                                    currentStep.toString());
                                              } else {
                                                debugPrint("completed form");
                                              }
                                            });
                                          } else {
                                            debugPrint("Errors found");
                                          }
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                                "Signing you up, please wait...",
                                            backgroundColor: Colors.lightGreen,
                                            fontSize: 14.0,
                                            textColor: Colors.white,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                          await uploadFile();
                                        }
                                      },
                                      onStepCancel: () {
                                        setState(() {
                                          if (currentStep == 0) {
                                            currentStep = 0;
                                            debugPrint(
                                                "back on the first item");
                                          } else {
                                            currentStep--;
                                          }
                                        });
                                      },
                                      steps: [
                                        Step(
                                            title: Text(
                                              "General Information",
                                              style: whiteText,
                                            ),
                                            content: Form(
                                              key: _generalKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 8.0),
                                                    child: SlideUpTween(
                                                      begin: Offset(100, 50),
                                                      child: TextFormField(
                                                        validator:
                                                            (String? val) {
                                                          if (val!.isEmpty) {
                                                            return "enter full name";
                                                          }
                                                          return null;
                                                        },
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        maxLength: 35,
                                                        controller:
                                                            _nameController,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                        decoration:
                                                            const InputDecoration(
                                                          prefixIcon: Icon(
                                                              Icons.person),
                                                          border:
                                                              UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          enabledBorder:
                                                              UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          label: Text(
                                                              "Full Name",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ),
                                                        keyboardType:
                                                            TextInputType.text,
                                                      ),
                                                    ),
                                                  ),
                                                  SlideUpTween(
                                                    begin: Offset(100, 100),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8.0),
                                                      child: TextFormField(
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        controller:
                                                            _usernameController,
                                                        validator:
                                                            (String? val) {
                                                          if (val!.isEmpty) {
                                                            return "enter valid Username";
                                                          }
                                                          return null;
                                                        },
                                                        maxLength: 35,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                        decoration:
                                                            const InputDecoration(
                                                          prefixIcon:
                                                              Icon(Icons.email),
                                                          border:
                                                              UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          enabledBorder:
                                                              UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          label: Text(
                                                              "Username",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .emailAddress,
                                                      ),
                                                    ),
                                                  ),
                                                  SlideUpTween(
                                                    begin: Offset(100, -100),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8.0),
                                                      child: TextFormField(
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                        controller:
                                                            _emailController,
                                                        validator:
                                                            (String? val) {
                                                          if (val!.isEmpty) {
                                                            return "enter valid Email";
                                                          }
                                                          return null;
                                                        },
                                                        maxLength: 35,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                        decoration:
                                                            const InputDecoration(
                                                          prefixIcon:
                                                              Icon(Icons.email),
                                                          border:
                                                              UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          enabledBorder:
                                                              UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          focusedBorder:
                                                              UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          label: Text("email",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .emailAddress,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            state: currentStep == 0
                                                ? StepState.editing
                                                : StepState.complete,
                                            isActive:
                                                currentStep == 0 ? true : false,
                                            subtitle: Text(
                                              "This is about your personal profile.",
                                              style: whiteText,
                                            )),
                                        Step(
                                            title: Text(
                                              "Company Information",
                                              style: whiteText,
                                            ),
                                            content: Form(
                                              key: _shopKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(8)),
                                                    child: Card(
                                                      elevation: 10.0,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10.0,
                                                              vertical: 10.0),
                                                      shadowColor: Colors
                                                          .lightGreen
                                                          .withOpacity(.8),
                                                      child: InkWell(
                                                        onTap:
                                                            _imageFromGallery,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                size.height *
                                                                    .22,
                                                            child: Center(
                                                              child: _imageSet
                                                                  ? Image.file(
                                                                      image!,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: double
                                                                          .infinity,
                                                                      height: double
                                                                          .infinity,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                    )
                                                                  : const Text(
                                                                      "Choose Company Photo",
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 8.0),
                                                    child: TextFormField(
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      controller:
                                                          _companyNameController,
                                                      validator: (String? val) {
                                                        if (val!.isEmpty) {
                                                          return "enter valid Company Name";
                                                        }
                                                        return null;
                                                      },
                                                      maxLength: 35,
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      decoration:
                                                          const InputDecoration(
                                                        prefixIcon:
                                                            Icon(Icons.house),
                                                        border:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        enabledBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        label: Text("Company",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black)),
                                                      ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 8.0),
                                                    child: TextFormField(
                                                      controller:
                                                          _companyAddressController,
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      validator: (String? val) {
                                                        if (val!.isEmpty) {
                                                          return "enter valid address";
                                                        }
                                                        return null;
                                                      },
                                                      maxLength: 35,
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      decoration:
                                                          const InputDecoration(
                                                        prefixIcon: Icon(
                                                            Icons.location_pin),
                                                        border:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        enabledBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        label: Text("Address",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black)),
                                                      ),
                                                      keyboardType:
                                                          TextInputType
                                                              .streetAddress,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height: 80,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        //opening time
                                                        InkWell(
                                                          onTap: () async {
                                                            TimeOfDay time =
                                                                await _timePicker();
                                                            setState(() {
                                                              _openingTime = time
                                                                      .hour
                                                                      .toString() +
                                                                  ":" +
                                                                  time.minute
                                                                      .toString() +
                                                                  (time.hour >
                                                                          11
                                                                      ? " PM"
                                                                      : " AM");
                                                            });
                                                          },
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                "Opening Time",
                                                              ),
                                                              Text(
                                                                _openingTime,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .lightGreen),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        //opening time
                                                        InkWell(
                                                          onTap: () async {
                                                            TimeOfDay time =
                                                                await _timePicker();
                                                            setState(() {
                                                              _closingTime = (time.hour > 12
                                                                          ? time.hour -
                                                                              12
                                                                          : time
                                                                              .hour)
                                                                      .toString() +
                                                                  ":" +
                                                                  time.minute
                                                                      .toString() +
                                                                  (time.hour >
                                                                          11
                                                                      ? " PM"
                                                                      : " AM");
                                                            });
                                                          },
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                "Closing Time",
                                                              ),
                                                              Text(
                                                                _closingTime,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .lightGreen),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 15),
                                                  Text(
                                                    "Choose restaurant types",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Wrap(
                                                    spacing: 2.0,
                                                    runSpacing: 1.0,
                                                    children: [
                                                      for (String cat
                                                          in _categories)
                                                        AnimatedScale(
                                                          duration: Duration(
                                                              milliseconds:
                                                                  500),
                                                          curve: Curves
                                                              .fastOutSlowIn,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .high,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          scale:
                                                              _selectedCategories
                                                                      .contains(
                                                                          cat)
                                                                  ? 1.0
                                                                  : 0.8,
                                                          child: InkWell(
                                                            onTap: () {
                                                              if (_selectedCategories
                                                                  .contains(
                                                                      cat)) {
                                                                setState(() {
                                                                  _selectedCategories
                                                                      .remove(
                                                                          cat);
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  _selectedCategories
                                                                      .add(cat);
                                                                });
                                                              }
                                                              HapticFeedback
                                                                  .heavyImpact();
                                                              debugPrint(
                                                                  _selectedCategories
                                                                      .length
                                                                      .toString());
                                                            },
                                                            child:
                                                                AnimatedOpacity(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      300),
                                                              opacity: _selectedCategories
                                                                      .contains(
                                                                          cat)
                                                                  ? 1.0
                                                                  : 0.3,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Chip(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  label:
                                                                      Text(cat),
                                                                  avatar: Icon(
                                                                      Icons
                                                                          .food_bank_rounded,
                                                                      color: Colors
                                                                          .primaries[_categories.indexOf(cat) >
                                                                              Colors.primaries.length -
                                                                                  1
                                                                          ? _categories.indexOf(cat) -
                                                                              Colors.primaries.length
                                                                          : _categories.indexOf(cat)]),
                                                                  labelPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          5.0,
                                                                      horizontal:
                                                                          8.0),
                                                                  elevation:
                                                                      12.0,
                                                                  shadowColor: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          .4),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            state: currentStep == 1
                                                ? StepState.editing
                                                : currentStep > 1
                                                    ? StepState.complete
                                                    : StepState.indexed,
                                            isActive:
                                                currentStep == 1 ? true : false,
                                            subtitle: Text(
                                              "Address your company details.",
                                              style: whiteText,
                                            )),
                                        Step(
                                          title: Text(
                                            "Fine tune Your Business",
                                            style: whiteText,
                                          ),
                                          subtitle: Text(
                                            "Go closer to your customers",
                                            style: whiteText,
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              LimitedBox(
                                                child: SwitchListTile.adaptive(
                                                    enableFeedback: true,
                                                    title: Text(
                                                      "Home Delivery",
                                                      style: greenAccent,
                                                    ),
                                                    subtitle: _homeDelivery
                                                        ? null
                                                        : Text(
                                                            "Deliver meals to customers",
                                                            style: whiteText),
                                                    value: _homeDelivery,
                                                    onChanged: (bool data) {
                                                      setState(() {
                                                        _homeDelivery = data;
                                                      });
                                                    }),
                                              ),
                                              if (_homeDelivery)
                                                TextField(
                                                  autofocus: _homeDelivery,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  decoration: InputDecoration(
                                                      hintText:
                                                          "How much for delivery"),
                                                  onChanged: ((value) {
                                                    if (value.isNotEmpty) {
                                                      _deliveryCost =
                                                          double.parse(value);
                                                    } else {
                                                      _deliveryCost = 0.0;
                                                    }
                                                  }),
                                                ),
                                              LimitedBox(
                                                child: SwitchListTile.adaptive(
                                                  title: Text(
                                                    "Table Reservations",
                                                    style: greenAccent,
                                                  ),
                                                  subtitle: _tableReservation
                                                      ? null
                                                      : Text(
                                                          "Reserve tables for paying customers",
                                                          style: whiteText),
                                                  value: _tableReservation,
                                                  onChanged: (bool data) {
                                                    setState(() {
                                                      _tableReservation = data;
                                                    });
                                                  },
                                                  enableFeedback: true,
                                                ),
                                              ),
                                              LimitedBox(
                                                child: SwitchListTile.adaptive(
                                                    enableFeedback: true,
                                                    title: Text(
                                                      "Food Reservation",
                                                      style: greenAccent,
                                                    ),
                                                    subtitle: _foodReservation
                                                        ? null
                                                        : Text(
                                                            "Reserve meals for paying customers",
                                                            style: whiteText),
                                                    value: _foodReservation,
                                                    onChanged: (bool data) {
                                                      setState(() {
                                                        _foodReservation = data;
                                                      });
                                                    }),
                                              ),
                                              SwitchListTile.adaptive(
                                                  title: Text(
                                                    "Take Special Orders",
                                                    style: greenAccent,
                                                  ),
                                                  subtitle: _specialOrders
                                                      ? null
                                                      : Text(
                                                          "Customers can contact you for bulk orders",
                                                          style: whiteText),
                                                  value: _specialOrders,
                                                  enableFeedback: true,
                                                  onChanged: (bool data) {
                                                    setState(() {
                                                      _specialOrders = data;
                                                    });
                                                  }),
                                              SwitchListTile.adaptive(
                                                  title: Text(
                                                    "Do you have a Restaurant Eatery?",
                                                    style: greenAccent,
                                                  ),
                                                  enableFeedback: true,
                                                  subtitle: _specialOrders
                                                      ? null
                                                      : Text(
                                                          "Select this if you do deliveries directly from.",
                                                          style: whiteText),
                                                  value: _ghostKitchen,
                                                  onChanged: (bool data) {
                                                    setState(() {
                                                      _ghostKitchen = data;
                                                    });
                                                  }),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          setState(() {
                                                            bool val =
                                                                !_selectAll;
                                                            _specialOrders =
                                                                val;
                                                            _tableReservation =
                                                                val;
                                                            _foodReservation =
                                                                val;
                                                            _homeDelivery = val;
                                                            _selectAll = val;
                                                          });
                                                        });
                                                      },
                                                      child: Text("Select all",
                                                          style: whiteText)),
                                                  Checkbox(
                                                      value: _selectAll,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          _specialOrders = val!;
                                                          _tableReservation =
                                                              val;
                                                          _foodReservation =
                                                              val;
                                                          _homeDelivery = val;
                                                          _selectAll = val;
                                                          _ghostKitchen = val;
                                                        });
                                                      })
                                                ],
                                              )
                                            ],
                                          ),
                                          state: currentStep == 2
                                              ? StepState.editing
                                              : currentStep > 2
                                                  ? StepState.complete
                                                  : StepState.indexed,
                                          isActive:
                                              currentStep == 2 ? true : false,
                                        ),
                                        Step(
                                            title: Text(
                                              "Payment Methods",
                                              style: whiteText,
                                            ),
                                            content: Form(
                                              key: _extraKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  LimitedBox(
                                                    child:
                                                        SwitchListTile.adaptive(
                                                            title: Text(
                                                              "Pay With Cash",
                                                              style:
                                                                  greenAccent,
                                                            ),
                                                            subtitle: _cash
                                                                ? null
                                                                : Text(
                                                                    "Collect Cash Payments From Customers",
                                                                    style:
                                                                        whiteText),
                                                            value: _cash,
                                                            onChanged:
                                                                (bool data) {
                                                              setState(() {
                                                                _cash = data;
                                                              });
                                                            }),
                                                  ),
                                                  LimitedBox(
                                                    child:
                                                        SwitchListTile.adaptive(
                                                            title: Text(
                                                              "Mobile Money Payment",
                                                              style:
                                                                  greenAccent,
                                                            ),
                                                            subtitle: _momo
                                                                ? null
                                                                : Text(
                                                                    "Receive Payments With MTN & Orange Mobile Money",
                                                                    style:
                                                                        whiteText),
                                                            value: _momo,
                                                            onChanged:
                                                                (bool data) {
                                                              setState(() {
                                                                _momo = data;
                                                              });
                                                            }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            state: StepState.disabled,
                                            isActive: false,
                                            subtitle: Text(
                                              "How you would like to receive your payment",
                                              style: whiteText,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ));
        });
  }
}
