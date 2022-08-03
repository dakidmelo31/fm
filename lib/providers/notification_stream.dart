import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../global.dart';
import '../models/cloud_notification.dart';

class NotificationStream extends StatelessWidget {
  const NotificationStream({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection("notifications")
          .where("restaurantId", isEqualTo: auth.currentUser!.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            String notificationId = doc.id;
            CloudNotification notification =
                CloudNotification.fromMap(doc.data() as Map<String, dynamic>);

            debugPrint("got notifications for $notificationId");
            sendNotif(
                    description: notification.description,
                    title: notification.title,
                    payload: notification.payload)
                .then((value) =>
                    deleteCloudNotification(notificationId: notificationId));
//delete the notification
          }
        }
        if (snapshot.hasError) {
          debugPrint("found an error: ${snapshot.error}");
        }
        return child;
      },
    );
  }
}
