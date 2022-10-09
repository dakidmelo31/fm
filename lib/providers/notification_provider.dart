// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationApi {
//   static final _notifications = FlutterLocalNotificationsPlugin();
//   static final onNotifications = BehaviorSubject<String?>();

//   static Future init({bool initScheduled = false}) async {
//     final android = AndroidInitializationSettings("drawable/ic_launcher.png");
//     final iOS = IOSInitializationSettings();
//     final settings = InitializationSettings(android: android, iOS: iOS);

//     await _notifications.initialize(settings,
//         onSelectNotification: ((payload) async {
//       onNotifications.add(payload);
//     }));
//   }

//   static Future _notificationDeails() async {
//     return NotificationDetails(
//         android: AndroidNotificationDetails(
//             "high_importance_channel", "channel name",
//             channelDescription: "channel description",
//             importance: Importance.max),
//         iOS: IOSNotificationDetails());
//   }

//   static Future showNotification(
//           {int id = 0, String? title, String? body, String? payload}) async =>
//       _notifications
//           .show(id, title, body, await _notificationDeails(), payload: payload)
//           .then((value) => debugPrint("sending notification now"));
// }
