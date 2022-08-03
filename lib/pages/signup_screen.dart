import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:merchants/animations/opacity_tween.dart';
import 'package:merchants/animations/slideup_tween.dart';
import '../widgets/main_screen.dart';
import '../theme/main_theme.dart';

CollectionReference users =
    FirebaseFirestore.instance.collection("restaurants");
FirebaseAuth auth = FirebaseAuth.instance;
firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

class CreateAccount extends StatefulWidget {
  static const routeName = "/signup";
  CreateAccount({Key? key, this.formType}) : super(key: key);
  VoidCallback? formType;

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  int currentStep = 0;
  TextEditingController _nameController = TextEditingController(),
      _usernameController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController(),
      _companyNameController = TextEditingController(),
      _companyAddressController = TextEditingController(),
      _companyWebsiteController = TextEditingController(),
      _phoneController = TextEditingController(),
      _companyPhoneController = TextEditingController();
  late final bool _canContinue = currentStep < 4;
  final _generalKey = GlobalKey<FormState>();
  final _shopKey = GlobalKey<FormState>();
  final _extraKey = GlobalKey<FormState>();
  String category = "";
  List<String> categories = [
    "Street Food",
    "Shawarma",
    "Groceries",
    "Spices",
    "Restaurant",
    "Catery",
    "Cafe",
  ];
  late final List<GlobalKey<FormState>> _keys = [
    _generalKey,
    _shopKey,
    _extraKey
  ];
  bool _showPassword = false;
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
  _imageFromCamera() async {
    XFile? _image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    setState(() {
      image = File(_image!.path);
      _imageSet = true;
    });
  }

  Future uploadFile() async {
    if (image == null) {
      return;
    }
    String url = "";

    //check if user's data already exists

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("uploads/" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(File(image!.path));
    await uploadTask.then((res) {
      res.ref.getDownloadURL().then((value) async {
        await users.doc(auth.currentUser!.uid).set({
          "phone": _phoneController.text,
          "name": _nameController.text,
          "username": _usernameController.text,
          "avatar": value,
          "email": _emailController.text,
          "password": _passwordController.text,
          "companyName": _companyNameController.text,
          "address": _companyAddressController.text,
          "businessPhoto": value,
          "openTime": _openingTime,
          "closingTime": _closingTime,
          "foodReservation": _foodReservation,
          "homeDelivery": _homeDelivery,
          "specialOrders": _specialOrders,
          "cash": _cash,
          "ghostKitchen": _ghostKitchen,
          "momo": _momo,
          "tableReservation": _tableReservation,
          "created_at": FieldValue.serverTimestamp()
        }, SetOptions(merge: true)).then((value) async {
          debugPrint("Done signing up user");
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        }).catchError((onError) => debugPrint("found error ${onError}"));
      });
    });
    return url;
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
    // TODO: implement dispose
    super.dispose();
  }

  TextStyle whiteText = const TextStyle(color: Colors.white);
  TextStyle greenAccent = const TextStyle(color: Colors.lightGreenAccent);
  bool _homeDelivery = false,
      _foodReservation = false,
      _tableReservation = false,
      _specialOrders = false,
      _momo = true,
      _cash = true,
      _ghostKitchen = true,
      _selectAll = false;

  _doesUserExist() async {
    // check if user already exists
    await auth
        .createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text)
        .whenComplete(() {
      debugPrint("done signing up user");
      uploadFile();
      Navigator.pushNamed(context, HomeScreen.routeName);
    }).catchError((error) {
      // Login user
      debugPrint("error signing up: $error");
      showCupertinoModalPopup(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              content: Text(
                  "Sorry, your email already exists, try logging in or resetting your password instead"),
              actions: [
                TextButton(
                    onPressed: () {
                      debugPrint("back to login");
                    },
                    child: Text("Login")),
                TextButton(
                    onPressed: () {
                      debugPrint("Forgot password");
                    },
                    child: Text("Forgot password")),
              ],
            );
          });
    }).timeout(
      Duration(seconds: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Material(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/splash_bg.png"),
            colorFilter: ColorFilter.linearToSrgbGamma(),
            alignment: Alignment.center,
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.black,
              Color.fromARGB(255, 0, 0, 0).withOpacity(.17),
              Color.fromARGB(255, 0, 0, 0).withOpacity(.83),
            ], begin: Alignment.bottomRight, end: Alignment.topLeft),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: ListView(
            physics: const ClampingScrollPhysics(
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
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios_new_outlined,
                                    color: Colors.orange),
                                onPressed: widget.formType,
                              )
                            ],
                          )),
                      Text(
                        "Create Your Store!",
                        style: TextStyle(
                          color: Colors.white,
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
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Stepper(
                    elevation: 10,
                    type: StepperType.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    currentStep: currentStep,
                    onStepTapped: (int newStep) => setState(() {
                      currentStep = newStep;
                    }),
                    onStepContinue: () async {
                      if (currentStep < 3) {
                        if (_keys[currentStep].currentState!.validate()) {
                          debugPrint("form number $currentStep is valid");
                          setState(() {
                            if (currentStep < 3) {
                              currentStep++;
                              debugPrint(currentStep.toString());
                            } else {
                              debugPrint("completed form");
                            }
                          });
                        } else {
                          debugPrint("Errors found");
                        }
                      } else {
                        await _doesUserExist();
                      }
                    },
                    onStepCancel: () {
                      setState(() {
                        if (currentStep == 0) {
                          currentStep = 0;
                          debugPrint("back on the first item");
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: SlideUpTween(
                                    begin: Offset(100, 50),
                                    child: TextFormField(
                                      validator: (String? val) {
                                        if (val!.isEmpty) {
                                          return "enter full name";
                                        }
                                        return null;
                                      },
                                      controller: _nameController,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.person),
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        label: Text("Full Name",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                ),
                                SlideUpTween(
                                  begin: Offset(100, 100),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: TextFormField(
                                      controller: _phoneController,
                                      validator: (String? val) {
                                        if (val!.isEmpty) {
                                          return "enter valid phone number";
                                        }
                                        return null;
                                      },
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.person),
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        label: Text("Phone Number",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                ),
                                SlideUpTween(
                                  begin: Offset(100, -100),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      controller: _emailController,
                                      validator: (String? val) {
                                        if (val!.isEmpty) {
                                          return "enter valid Email";
                                        }
                                        return null;
                                      },
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.email),
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        label: Text("email",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                  ),
                                ),
                                OpacityTween(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: TextFormField(
                                      textInputAction: TextInputAction.done,
                                      controller: _passwordController,
                                      validator: (String? val) {
                                        if (val!.isEmpty || val.length < 6) {
                                          return "Password is weak";
                                        }
                                        return null;
                                      },
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.lock),
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        label: Text("Password",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                      keyboardType: TextInputType.text,
                                      obscureText: !_showPassword,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            _showPassword = !_showPassword;
                                          });
                                        },
                                        child: Text("Show Password",
                                            style: greyText)),
                                    Checkbox(
                                        value: _showPassword,
                                        onChanged: (val) {
                                          setState(() {
                                            _showPassword = val!;
                                          });
                                        })
                                  ],
                                )
                              ],
                            ),
                          ),
                          state: currentStep == 0
                              ? StepState.editing
                              : StepState.complete,
                          isActive: currentStep == 0 ? true : false,
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  child: Card(
                                    child: InkWell(
                                      onTap: _imageFromGallery,
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: size.height * .22,
                                        child: Center(
                                          child: _imageSet
                                              ? Image.file(
                                                  image!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  alignment: Alignment.center,
                                                )
                                              : const Text(
                                                  "Choose Company Photo",
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: TextFormField(
                                    textInputAction: TextInputAction.next,
                                    controller: _companyNameController,
                                    validator: (String? val) {
                                      if (val!.isEmpty) {
                                        return "enter valid Company Name";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.house),
                                      border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      label: Text("Company",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: TextFormField(
                                    controller: _companyAddressController,
                                    onEditingComplete: () async {
                                      bool outcome =
                                          await showCupertinoModalPopup(
                                              context: context,
                                              builder: (_) {
                                                return Material(
                                                    child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: FractionallySizedBox(
                                                    heightFactor: .8,
                                                    widthFactor: 1.0,
                                                    alignment: Alignment.center,
                                                    child: Stack(
                                                      children: [
                                                        Column(children: [
                                                          Text("show map here"),
                                                          Spacer(),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {},
                                                                    child: Text(
                                                                      "Yes Use my Location",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.blue),
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {},
                                                                    child: Text(
                                                                        "I'll Pick Later"),
                                                                  ),
                                                                ]),
                                                          )
                                                        ]),
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                              });
                                    },
                                    textInputAction: TextInputAction.next,
                                    validator: (String? val) {
                                      if (val!.isEmpty) {
                                        return "enter valid address";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.location_pin),
                                      border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      label: Text("Address",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    keyboardType: TextInputType.streetAddress,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: TextFormField(
                                    validator: (String? val) {
                                      if (val!.isEmpty) {
                                        return "enter valid phone Number";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.computer),
                                      border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      label: Text("Website (optional)",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    keyboardType: TextInputType.url,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 80,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      //opening time
                                      InkWell(
                                        onTap: () async {
                                          TimeOfDay time = await _timePicker();
                                          setState(() {
                                            _openingTime =
                                                time.hour.toString() +
                                                    ":" +
                                                    time.minute.toString() +
                                                    (time.hour > 11
                                                        ? " PM"
                                                        : " AM");
                                          });
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Opening Time",
                                                style: greenAccent),
                                            Text(
                                              _openingTime,
                                              style: whiteText,
                                            ),
                                          ],
                                        ),
                                      ),

                                      //opening time
                                      InkWell(
                                        onTap: () async {
                                          TimeOfDay time = await _timePicker();
                                          setState(() {
                                            _closingTime = (time.hour > 12
                                                        ? time.hour - 12
                                                        : time.hour)
                                                    .toString() +
                                                ":" +
                                                time.minute.toString() +
                                                (time.hour > 11
                                                    ? " PM"
                                                    : " AM");
                                          });
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Closing Time",
                                              style: TextStyle(
                                                  color:
                                                      Colors.lightGreenAccent),
                                            ),
                                            Text(
                                              _closingTime,
                                              style: whiteText,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          state: currentStep == 1
                              ? StepState.editing
                              : currentStep > 1
                                  ? StepState.complete
                                  : StepState.indexed,
                          isActive: currentStep == 1 ? true : false,
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
                                  title: Text(
                                    "Home Delivery",
                                    style: greenAccent,
                                  ),
                                  subtitle: _homeDelivery
                                      ? null
                                      : Text("Deliver meals to customers",
                                          style: whiteText),
                                  value: _homeDelivery,
                                  onChanged: (bool data) {
                                    setState(() {
                                      _homeDelivery = data;
                                    });
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
                                  }),
                            ),
                            LimitedBox(
                              child: SwitchListTile.adaptive(
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
                                onChanged: (bool data) {
                                  setState(() {
                                    _specialOrders = data;
                                  });
                                }),
                            SwitchListTile.adaptive(
                                title: Text(
                                  "Do you have a kitchen?",
                                  style: greenAccent,
                                ),
                                subtitle: _specialOrders
                                    ? null
                                    : Text(
                                        "Select this if you do only Home deliveries.",
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
                                          bool val = !_selectAll;
                                          _specialOrders = val;
                                          _tableReservation = val;
                                          _foodReservation = val;
                                          _homeDelivery = val;
                                          _selectAll = val;
                                        });
                                      });
                                    },
                                    child:
                                        Text("Select all", style: whiteText)),
                                Checkbox(
                                    value: _selectAll,
                                    onChanged: (val) {
                                      setState(() {
                                        _specialOrders = val!;
                                        _tableReservation = val;
                                        _foodReservation = val;
                                        _homeDelivery = val;
                                        _selectAll = val;
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
                        isActive: currentStep == 2 ? true : false,
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
                                  child: SwitchListTile.adaptive(
                                      title: Text(
                                        "Pay With Cash",
                                        style: greenAccent,
                                      ),
                                      subtitle: _cash
                                          ? null
                                          : Text(
                                              "Collect Cash Payments From Customers",
                                              style: whiteText),
                                      value: _cash,
                                      onChanged: (bool data) {
                                        setState(() {
                                          _cash = data;
                                        });
                                      }),
                                ),
                                LimitedBox(
                                  child: SwitchListTile.adaptive(
                                      title: Text(
                                        "Mobile Money Payment",
                                        style: greenAccent,
                                      ),
                                      subtitle: _momo
                                          ? null
                                          : Text(
                                              "Receive Payments With MTN & Orange Mobile Money",
                                              style: whiteText),
                                      value: _momo,
                                      onChanged: (bool data) {
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
    );
  }
}
