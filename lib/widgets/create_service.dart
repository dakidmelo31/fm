import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:merchants/providers/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:uuid/uuid.dart';
import '../global.dart';
import '../providers/global_data.dart';

class CreateService extends StatefulWidget {
  const CreateService({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  State<CreateService> createState() => _CreateServiceState();
}

class _CreateServiceState extends State<CreateService> {
  File? _img;
  List<File?> gallery = [];
  List<String> accessories = [], categories = [], galleryImages = [];
  bool changed = false;
  ImagePicker picker = ImagePicker();
  bool uploading = false;

  Widget currentScreenWidget = Container(
    alignment: Alignment.center,
    child: Lottie.asset("assets/app/animations/upload1.json",
        fit: BoxFit.contain, alignment: Alignment.center),
  );

  final _serviceKey = GlobalKey<FormState>();
  bool _available = false;
  Duration? duration;
  TextEditingController _serviceDescription = TextEditingController();
  TextEditingController _serviceName = TextEditingController();
  TextEditingController _categoriesController = TextEditingController();
  TextEditingController _servicePrice = TextEditingController();
  TextEditingController _serviceDuration = TextEditingController();
  TextEditingController _serviceCoverage = TextEditingController();
  TextEditingController _serviceCity = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Create new Service"),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 700),
        switchInCurve: Curves.easeInToLinear,
        transitionBuilder: (child, animation) {
          animation =
              CurvedAnimation(parent: animation, curve: Curves.bounceIn);
          return SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              axisAlignment: 0.0,
              child: child);
        },
        child: uploading
            ? Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      child: Lottie.asset(
                        "assets/animation1.json",
                        width: size.width,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Shimmer(
                        gradient: LinearGradient(colors: [
                          Colors.white,
                          Colors.grey.withOpacity(.4)
                        ]),
                        enabled: true,
                        direction: ShimmerDirection.ltr,
                        period: Duration(milliseconds: 1000),
                        child: Text(
                          "Uploading",
                          style: TextStyle(fontSize: 50.0),
                        ))
                  ],
                ),
              )
            : Form(
                key: _serviceKey,
                child: Container(
                  color: Colors.white,
                  width: size.width,
                  height: size.height,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    physics: BouncingScrollPhysics(),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          color: Colors.white,
                          width: size.width,
                          height: 180,
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
                      Card(
                        margin: EdgeInsets.only(bottom: 20.0, top: 15.0),
                        elevation: 10,
                        shadowColor: Colors.grey.withOpacity(.3),
                        child: TextFormField(
                          controller: _serviceName,
                          validator: ((value) {
                            if (value == null || value.isEmpty)
                              return "Please enter your Service Name";
                            return null;
                          }),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: "Service Name",
                            label: Text("Name"),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10.0),
                            fillColor: Colors.white,
                            filled: true,
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 3,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 20.0),
                        elevation: 10,
                        shadowColor: Colors.grey.withOpacity(.3),
                        child: TextFormField(
                          controller: _serviceDescription,
                          validator: ((value) {
                            if (value == null || value.isEmpty)
                              return "Please describe your service";
                            return null;
                          }),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10.0),
                            hintText: "Describe the service",
                            label: Text("Description"),
                            hintMaxLines: 5,
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 3,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          maxLines: 5,
                        ),
                      ),
                      Card(
                        elevation: 10,
                        shadowColor: Colors.grey.withOpacity(.3),
                        margin: EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          controller: _servicePrice,
                          validator: ((value) {
                            if (value == null || value.isEmpty)
                              return "You need to add a price";
                            return null;
                          }),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.numberWithOptions(
                              signed: false, decimal: true),
                          decoration: InputDecoration(
                            hintText: "How much do you charge",
                            label: Text("Cost"),
                            suffix: Text("CFA"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 3,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 20.0),
                        elevation: 10,
                        shadowColor: Colors.grey.withOpacity(.3),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty)
                              return "Please enter Duration";
                            return null;
                          }),
                          controller: _serviceDuration,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: "How long will it take?",
                            label: Text("Duration"),
                            hintMaxLines: 5,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 3,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 10,
                        shadowColor: Colors.grey.withOpacity(.3),
                        margin: EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          validator: ((value) {
                            if (value == null || value.isEmpty)
                              return "Please enter your coverage";
                            return null;
                          }),
                          controller: _serviceCoverage,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "Where do you Operate? e.g Buea",
                            label: Text("Coverage"),
                            hintMaxLines: 5,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 3,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SwitchListTile(
                        value: negociable,
                        activeColor: Colors.green,
                        enableFeedback: true,
                        visualDensity: VisualDensity.comfortable,
                        title: Text("Is the price negociable?"),
                        onChanged: (vals) {
                          setState(() {
                            negociable = vals;
                          });
                        },
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
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  crossAxisCount: 3),
                          itemCount: gallery.length,
                          itemBuilder: (_, index) {
                            return InkWell(
                              onLongPress: () {
                                HapticFeedback.heavyImpact();
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
                                    width: 60,
                                    height: 50,
                                  ),
                                ),
                              ),
                            );
                          }),
                      Card(
                        color: Colors.lightGreen,
                        elevation: 10,
                        margin: EdgeInsets.symmetric(
                            horizontal: 22.0, vertical: 12.0),
                        child: InkWell(
                          onTap: () {
                            if (_serviceKey.currentState!.validate()) {
                              saveService(context: context);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Create Service",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(Icons.add_business_rounded,
                                    color: Colors.white)
                              ],
                            ),
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

  bool negociable = false;

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

  saveService({required BuildContext context}) async {
    final provider = Provider.of<ServicesData>(context, listen: false);

    String name = _serviceName.text;
    String description = _serviceDescription.text;
    String duration = _serviceDuration.text;
    String coverage = _serviceCoverage.text;
    Fluttertoast.showToast(
      msg: "Creating Service...",
      backgroundColor: Colors.lightGreen,
      fontSize: 14.0,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    setState(() {
      uploading = true;
    });
    Fluttertoast.showToast(
      msg: "Uploading pictures...",
      backgroundColor: Colors.lightGreen,
      fontSize: 14.0,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    await _uploadGallery();

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("uploads/" + Uuid().v4());
    UploadTask uploadTask = ref.putFile(File(_img!.path));

    await uploadTask.then((event) {
      event.ref.getDownloadURL().then((img) async {
        debugPrint("current URL: $img");

        Map<String, dynamic> data = {
          "restaurantId": auth.currentUser!.uid,
          "image": img,
          "name": name,
          "description": description,
          "coverage": coverage,
          "duration": duration,
          "cost": _servicePrice.text,
          "verified": false,
          "gallery": galleryImages
        };

        debugPrint("about to upload map: $data");

        firestore.collection("services").add(data).then((value) {
          firestore
              .collection("followers")
              .doc(auth.currentUser!.uid)
              .get()
              .then((value) {
            var tokens = List<String>.from(value["tokens"]);
            debugPrint("tokens: $tokens");
            tokens.map((e) {
              sendTopicNotification(
                  title: widget.restaurant.companyName + " just posted a dish",
                  description: widget.restaurant.companyName.toUpperCase() +
                      " just added a new product to their store".toUpperCase(),
                  image: img);
              ;
            });
          });
        }).catchError((onError) {
          debugPrint(onError.toString());
        }).then((value) => provider.loadServices());
      });
    });
    setState(() {
      uploading = false;
    });
    Fluttertoast.cancel();
    HapticFeedback.heavyImpact();
    Fluttertoast.showToast(
      msg: "Done creating service...",
      backgroundColor: Colors.lightGreen,
      fontSize: 14.0,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    sendNotif(
        title: "Your service is Published",
        description: name + " is published");
    Navigator.pop(context, true);
  }
}
