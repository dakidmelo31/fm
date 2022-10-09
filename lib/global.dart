import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:merchants/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/customer.dart';

const Duration transitionDuration = Duration(milliseconds: 400);
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

enum OrderStatus { pending, processing, ready, complete }

const TextStyle headingStyle =
    TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
AndroidNotificationChannelGroup channelGroup = AndroidNotificationChannelGroup(
    "online.foodincity.foodin_merchant", "messages");

void groupNotications() async {
  debugPrint("grouping notifications");
  const String groupKey = 'online.foodincity.foodin_merchant';
  const String groupChannelId = 'all_notifications';
  const String groupChannelName = 'Latest Updates';
  const String groupChannelDescription = 'All Your Updates';
// example based on https://developer.android.com/training/notify-user/group.html
  const AndroidNotificationDetails firstNotificationAndroidSpecifics =
      AndroidNotificationDetails(groupChannelId, groupChannelName,
          channelDescription: groupChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.lightGreen,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          groupKey: groupKey);

  const NotificationDetails firstNotificationPlatformSpecifics =
      NotificationDetails(android: firstNotificationAndroidSpecifics);
  await flutterLocalNotificationsPlugin.show(1, 'Alex Faarborg',
      'You will not believe...', firstNotificationPlatformSpecifics);
  const AndroidNotificationDetails secondNotificationAndroidSpecifics =
      AndroidNotificationDetails(groupChannelId, groupChannelName,
          channelDescription: groupChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          groupKey: groupKey);
  const NotificationDetails secondNotificationPlatformSpecifics =
      NotificationDetails(android: secondNotificationAndroidSpecifics);
  await flutterLocalNotificationsPlugin.show(
      2,
      'Jeff Chang',
      'Please join us to celebrate the...',
      secondNotificationPlatformSpecifics);

// Create the summary notification to support older devices that pre-date
  /// Android 7.0 (API level 24).
  ///
  /// Recommended to create this regardless as the behaviour may vary as
  /// mentioned in https://developer.android.com/training/notify-user/group
  const List<String> lines = <String>[
    'Alex Faarborg  Check this out',
    'Jeff Chang    Launch Party'
  ];
  const InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: '2 messages',
      summaryText: 'janedoe@example.com');
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(groupChannelId, groupChannelName,
          channelDescription: groupChannelDescription,
          styleInformation: inboxStyleInformation,
          groupKey: groupKey,
          setAsGroupSummary: true);
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      3, 'Attention', 'Two messages', notificationDetails);
}

Future<void> sendNotif(
    {required String title,
    required String description,
    int? channel,
    String? payload}) async {
  // const AndroidNotificationDetails androidNotificationDetails =
  //     AndroidNotificationDetails(
  //   "channelId",
  //   "Foodin City",
  //   channelDescription: "Welcome to foodin",
  //   importance: Importance.high,
  //   color: Colors.blue,
  //   channelShowBadge: false,
  //   category: "Orders",
  //   enableVibration: true,
  //   groupAlertBehavior: GroupAlertBehavior.children,
  // );
  // const IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails(
  //   subtitle: "foodin city",
  // );
  // int value = 500;
  // const NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     iOS: iosNotificationDetails, android: androidNotificationDetails);
  // await FlutterLocalNotificationsPlugin().show(
  //   value,
  //   title,
  //   description,
  //   platformChannelSpecifics,
  //   payload: payload,
  // );
}

deleteCloudNotification({required String notificationId}) {
  firestore
      .collection("notifications")
      .doc(notificationId)
      .delete()
      .then((value) {
    debugPrint("deleted notification");
  }).catchError((onError) {
    debugPrint("error while deleting notification");
  });
}

Future<String?> getFirebaseToken() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken;
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    final fcmToken = await FirebaseMessaging.instance.getAPNSToken();
    return fcmToken;
  }
  return null;
}

getCount({required String collection, required String field}) async {
  int count = await FirebaseFirestore.instance
      .collection(collection)
      .where("foodId", isEqualTo: field)
      .get()
      .then((querySnapshot) {
    return querySnapshot.docs.length;
  });

  return count;
}

updateData(
    {required String collection,
    required String doc,
    required Map<String, dynamic> data}) async {
  // await FirebaseFirestore.instance.collection("reviews").doc(doc).delete();
  FirebaseFirestore.instance
      .collection(collection)
      .doc(doc)
      .set(data, SetOptions(merge: true))
      .then(
        (value) => debugPrint("update complete"),
      );
}

int convertInt(dynamic value) {
  if (value == null) return 0;
  var myInt = value;
  int newInt = myInt as int;

  return newInt;
}

List<String> convertString(dynamic list) {
  if (list == null) {
    return [];
  }
  if (list.runtimeType == String) {
    String names = list as String;
    List<String> d = names.split(",");
    return d;
  }

  return [];
}

List<String> convertList(dynamic list) {
  List<String> data = [];
  if (list == null) {
    return data;
  }

  for (String item in list) {
    data.add(item);
  }

  return data;
}

Future<Customer> getUser({required String userId}) async {
  debugPrint("get user");
  final user = await firestore.collection("users").doc(userId).get();
  Customer data = await Customer.fromMap(user.data()!);
  debugPrint(data.toString());
  return data;
}

isAccountCreated() async {
  final prefs = await SharedPreferences.getInstance();
  if (await prefs.containsKey("account_created")) {
    return true;
  }
  return false;
}

//Free Key: QS6R-4YD4-2Q9S-SGTY

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Widget errorWidget = Lottie.asset(
  "assets/no-connection2.json",
  fit: BoxFit.contain,
);
Widget errorWidget2 = Lottie.asset(
  "assets/no-connection3.json",
  fit: BoxFit.contain,
);
Widget loadingWidget = Lottie.asset(
  "assets/loading5.json",
  fit: BoxFit.contain,
);

FirebaseMessaging messaging = FirebaseMessaging.instance;
