import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:merchants/models/restaurants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../global.dart';
import '../models/chats_model.dart';
import '../models/message_data.dart';

class DBManager {
  static final DBManager instance = DBManager._init();
  static Database? _database;
  DBManager._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB("foodin.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS chats (

  restaurantId TEXT PRIMARY KEY,
  restaurantName TEXT NOT NULL,
  lastMessageTime TEXT NOT NULL,
  lastMessage TEXT NOT NULL,
  sender TEXT NOT NULL,
  userImage TEXT NOT NULL,
  restaurantImage TEXT NOT NULL,
  userId TEXT NOT NULL
    )
''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS chat_messages (
      msgId INTEGER PRIMARY KEY AUTOINCREMENT,
      restaurantId TEXT NOT NULL,
      restaurantImage TEXT NOT NULL,
      restaurantName TEXT NOT NULL,
      userId TEXT NOT NULL,
      userImage TEXT NOT NULL,
      lastMessage TEXT NOT NULL,
      sender TEXT NOT NULL,
      lastMessageTime TEXT NOT NULL
    )
''');
  }

  Future<int> addOverview({required Chat chat}) async {
    final db = await instance.database;
    chat.toString();

    if (await selectOverview(restaurantId: chat.restaurantId) != null) {
      debugPrint("user exists");
      return -1;
    }

    final id = await db.insert("chats", chat.toMap());
    return id;
  }

  Future<List<Chat>> getChatOverviews() async {
    final db = await instance.database;
    var allMaps =
        await db.query("chats", orderBy: '${ChatFields.lastMessageTime} DESC');
    return allMaps.map((e) => Chat.fromMap(e)).toList();
  }

  Future updateOverview(
      {required String restaurantId,
      required String message,
      required String time}) async {
    final db = await instance.database;
    db.rawUpdate(
        "UPDATE chats SET lastMessage= ?, lastMessageTime = ? WHERE restaurantId = ?",
        [message, time, restaurantId]);
  }

  Future<int> delete({required String restaurantId}) async {
    final db = await instance.database;
    return db
        .delete("chats", where: 'restaurantId = ?', whereArgs: [restaurantId]);
  }

  Future<Chat?> selectOverview({required String restaurantId}) async {
    final db = await instance.database;
    Chat allOverviews;
    var list = await db.query("chats",
        columns: ChatFields.values,
        where: 'restaurantId = ?',
        whereArgs: [restaurantId]);
    if (list.isNotEmpty) {
      return Chat.fromMap(list.first);
    }

    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  overviewExists({required String restaurantId}) async {
    final db = await instance.database;
    var list = await db.query("chats",
        columns: ChatFields.values,
        where: 'restaurantId = ?',
        whereArgs: [restaurantId]);

    if (list.isNotEmpty) {
      return true;
    }

    return false;
  }

  Future<List<MessageData>> restaurantChats() async {
    Database _db = await instance.database;
    // await _db.execute('DROP table chats').catchError((onError) {
    //   debugPrint("error found: $onError");
    // });
    var messages = await _db.query("chats", orderBy: "lastMessageTime");
    debugPrint(messages.join());
    List<MessageData> messageList = [];

    for (Map<String, dynamic> e in messages) {
      debugPrint("going through number 1");
      DateTime date = DateTime.tryParse(e["lastMessageTime"]) as DateTime;
      MessageData chat = MessageData(
          message: e["lastMessage"],
          restaurantId: e["restaurantId"],
          messageDate: date,
          senderId: e["sender"],
          profilePicture: e["userImage"]);
      messageList.add(chat);
    }

    messageList.sort(((b, a) => a.messageDate.compareTo(b.messageDate)));
    return messageList;
  }

// Add chat
  addChat({required Chat chat}) async {
    Database _db = await instance.database;

//check if already exists
    if (await overviewExists(restaurantId: chat.restaurantId)) {
      debugPrint("restaurant already there");
    } else {
      // debugPrint("search term is: ");

      var row = {
        "restaurantId": chat.restaurantId,
        "restaurantImage": chat.restaurantImage,
        "restaurantName": chat.restaurantName,
        "lastMessage": chat.lastmessage,
        "userImage": chat.userImage,
        "sender": chat.sender,
        "userId": chat.userId,
        "lastMessageTime": chat.lastMessageTime.toIso8601String()
      };
      _db
          .insert("chats", row)
          .then(
            (value) => debugPrint("$value added to overview"),
          )
          .catchError((onError) {
        debugPrint("error while inserting: $onError");
      });
    }

    var length = await _db.rawQuery("SELECT * FROM chats");
    var total = length.length;
    debugPrint("total chats are $total");

    debugPrint("Move to chat screen");
  }

// Add chat
  updateChat({required Chat chat}) async {
    Database _db = await instance.database;

    var row = {
      "restaurantId": chat.restaurantId,
      "lastMessage": chat.lastmessage,
      "lastMessageTime": chat.lastMessageTime.toIso8601String()
    };
    _db
        .rawUpdate(
            "UPDATE chats SET lastMessage = ?, lastMessageTime = ? WHERE restaurantId = ?",
            [
              chat.lastmessage,
              chat.lastMessageTime.toIso8601String(),
              chat.restaurantId
            ])
        .then((value) => debugPrint("done updating"))
        .catchError((onError) {
          debugPrint("error found: $onError");
        });
    _db
        .update("chats", row,
            where: "restaurantId=?", whereArgs: [chat.restaurantId])
        .then(
          (value) => debugPrint("$value added to overview"),
        )
        .catchError((onError) {
          debugPrint("error while inserting: $onError");
        });

    var length = await _db.rawQuery("SELECT * FROM chats");
    var total = length.length;
    debugPrint("total chats are $total");

    debugPrint("Move to chat screen");
  }

  dropTable({required String tableName}) async {
    var db = await instance.database;
    debugPrint("adding now");
    await db
        .execute("DROP TABLE '${tableName}'")
        .then((value) => debugPrint("done dropping table"))
        .catchError((onError) {
      debugPrint(onError.toString());
    });
  }

  truncateTable({required String tableName}) async {
    final db = await instance.database;
    db.rawQuery('''
DELETE FROM '${tableName}';
VACUUM; 
    ''');
  }
}

deleteChatOverview({required String restaurantId}) async {
  Database _db = await DBManager.instance.database;
  _db.rawDelete("DELETE FROM chats WHERE restaurantId = ?",
      [restaurantId]).catchError((onError) {
    debugPrint(onError.toString());
  }).then((value) => debugPrint("done deleting chat"));
}

sendMessage(
    {required Chat chat,
    required String userToken,
    required String type,
    required Restaurant restaurant}) async {
  DBManager.instance.addChat(chat: chat);
  updateMessage(
      message: chat.lastmessage,
      newTime: chat.lastMessageTime,
      resturantId: chat.restaurantId);
  firestore.collection("messages").add(chat.toMap()).then((value) async {
    int rand = Random().nextInt(5000);
    debugPrint("Send Notification");
    final data = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "$rand",
      "restaurantId": auth.currentUser!.uid,
      'color': '#dcedc2',
      "message": chat.lastmessage,
      "type": type
    };
    try {
      debugPrint("Token is: $userToken");
      http.Response response =
          await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAAvlyEBz8:APA91bHiJP23KhUWPvJVvMH0iSgzLh37KQoG2id7-Yuk46_CCV5QTRRz7kU-wXo2g3vWoM5rkQlOTtERlk7vAGAKrZ9HKNLelRAd9yXlYkKN0ETklaYSRXHI9LVCgRh0AKT878i2zXAc',
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': restaurant.companyName,
                  'body': '${chat.lastmessage}',
                  'image': restaurant.businessPhoto,
                  'color': '#dcedc2'
                },
                'priority': 'high',
                'data': data,
                'collapse-key': 'message',
                'to': userToken
              }));

      if (response.statusCode == 200) {
        debugPrint("Notification Sent");
      } else {
        debugPrint("error found ${response.body}");
      }
    } catch (e) {
      throw Exception("Error sending personal notification");
    }
  }).catchError((onError) {
    debugPrint("error found: $onError");
  });
}

sendOrderNotification(
    {required String deviceId,
    required String message,
    required String orderId,
    required String userToken,
    required String type,
    String extra = "",
    required String title,
    String image = "",
    required Restaurant restaurant}) async {
  // int rand = Random().nextInt(5000);
  debugPrint("Send Notification to: $userToken");
  final data = {
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "id": "1",
    "restaurantId": orderId,
    "message": message,
    'color': '#dcedc2',
    'type': type,
    "extra": extra,
  };
  try {
    debugPrint("Token is: $deviceId");
    http.Response response =
        await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAAvlyEBz8:APA91bHiJP23KhUWPvJVvMH0iSgzLh37KQoG2id7-Yuk46_CCV5QTRRz7kU-wXo2g3vWoM5rkQlOTtERlk7vAGAKrZ9HKNLelRAd9yXlYkKN0ETklaYSRXHI9LVCgRh0AKT878i2zXAc',
            },
            body: jsonEncode(<String, dynamic>{
              "message": {
                "topic": auth.currentUser!.uid.toString(),
                'notification': <String, dynamic>{
                  'title': restaurant.companyName,
                  'body': message,
                  'type': type,
                  'image': image.isEmpty ? restaurant.businessPhoto : image,
                  'color': "#dcedc2"
                },
              },
              'priority': 'high',
              'data': data,
              'collapse-key': 'message',
              'to': userToken
            }));

    if (response.statusCode == 200) {
      debugPrint("Notification Sent");
    } else {
      debugPrint("error found ${response.body}");
    }
  } catch (e) {
    throw Exception("Error sending personal notification");
  }
}

updateMessage(
    {required String message,
    required DateTime newTime,
    required String resturantId}) async {
  Database _db = await DBManager.instance.database;
  _db
      .rawUpdate(
          "UPDATE chats SET lastMessage = ?, lastMessageTime = ? WHERE restaurantId = ?",
          [message, newTime.toIso8601String(), resturantId])
      .then((value) => debugPrint("updated successfully"))
      .catchError((onError) {
        debugPrint(onError.toString());
      });
}

updateTables(
    {required String collection,
    required String id,
    required Map<String, dynamic> newVal,
    required bool merge}) async {
  firestore.collection("restaurants").get().then((snapshot) {
    for (var data in snapshot.docs) {
      firestore
          .collection("restaurants")
          .doc(data.id)
          .set(newVal, SetOptions(merge: merge));
    }
  });
}

updateOverview(
    {required String id,
    required String message,
    required bool sentByMe,
    User}) async {
  firestore
      .collection("overviews")
      .doc(auth.currentUser!.uid)
      .collection("chats")
      .doc(id)
      .set({
        "lastMessage": message,
        "newMessage": false,
        "time": FieldValue.serverTimestamp(),
        "sentByMe": sentByMe
      }, SetOptions(merge: true))
      .then((value) => debugPrint("now opened"))
      .catchError((onError) => debugPrint("Error adding Overview: $onError"));
}
