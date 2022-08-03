// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

final String chatTable = "chats";

class ChatFields {
  static final String restaurantId = "restaurantId";
  static final String restaurantImage = "restaurantImage";
  static final String userId = "userId";
  static final String lastMessage = "lastMessage";
  static final String lastMessageTime = "lastMessageTime";
  static final String sender = "sender";
  static final String userImage = "userImage";
  static final String restaurantName = "restaurantName";
  static final List<String> values = [
    restaurantId,
    restaurantImage,
    restaurantName,
    userId,
    userImage,
    sender,
    lastMessage,
    lastMessageTime
  ];
}

class Chat {
  bool opened;
  final String restaurantId;
  final String restaurantImage;
  final String restaurantName;
  final String userId;
  final String sender;
  final String userImage;
  final String senderName;
  String lastmessage;
  DateTime lastMessageTime;
  String messageId = "";
  Chat({
    required this.opened,
    required this.restaurantId,
    required this.restaurantImage,
    required this.restaurantName,
    required this.userId,
    required this.sender,
    required this.userImage,
    required this.senderName,
    required this.lastmessage,
    required this.lastMessageTime,
    this.messageId = "",
  });

  userSent() {
    if (this.sender == restaurantId) {
      return true;
    }
    return false;
  }

  Chat copyWith({
    bool? opened,
    String? restaurantId,
    String? restaurantImage,
    String? restaurantName,
    String? userId,
    String? sender,
    String? userImage,
    String? senderName,
    String? lastmessage,
    DateTime? lastMessageTime,
    String? messageId,
  }) {
    return Chat(
      opened: opened ?? this.opened,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantImage: restaurantImage ?? this.restaurantImage,
      restaurantName: restaurantName ?? this.restaurantName,
      userId: userId ?? this.userId,
      sender: sender ?? this.sender,
      userImage: userImage ?? this.userImage,
      senderName: senderName ?? this.senderName,
      lastmessage: lastmessage ?? this.lastmessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      messageId: messageId ?? this.messageId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'opened': opened,
      'restaurantId': restaurantId,
      'restaurantImage': restaurantImage,
      'restaurantName': restaurantName,
      'userId': userId,
      'sender': sender,
      'userImage': userImage,
      'senderName': senderName,
      'lastmessage': lastmessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'messageId': messageId,
    };
  }

  factory Chat.fromMap(map) {
    return Chat(
      restaurantId: map['restaurantId'] ?? "",
      restaurantImage: map['restaurantImage'] ?? "",
      restaurantName: map['restaurantName'] ?? "",
      userId: map['userId'] ?? "",
      sender: map['sender'] ?? "",
      userImage: map['userImage'] ?? "",
      messageId: "",
      lastmessage: map['lastmessage'] ?? "",
      senderName: map['senderName'] ?? "",
      opened: map['opened'] ?? false,
      lastMessageTime:
          DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Chat(opened: $opened, restaurantId: $restaurantId, restaurantImage: $restaurantImage, restaurantName: $restaurantName, userId: $userId, sender: $sender, userImage: $userImage, senderName: $senderName, lastmessage: $lastmessage, lastMessageTime: $lastMessageTime, messageId: $messageId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chat &&
        other.opened == opened &&
        other.restaurantId == restaurantId &&
        other.restaurantImage == restaurantImage &&
        other.restaurantName == restaurantName &&
        other.userId == userId &&
        other.sender == sender &&
        other.userImage == userImage &&
        other.senderName == senderName &&
        other.lastmessage == lastmessage &&
        other.lastMessageTime == lastMessageTime &&
        other.messageId == messageId;
  }

  @override
  int get hashCode {
    return opened.hashCode ^
        restaurantId.hashCode ^
        restaurantImage.hashCode ^
        restaurantName.hashCode ^
        userId.hashCode ^
        sender.hashCode ^
        userImage.hashCode ^
        senderName.hashCode ^
        lastmessage.hashCode ^
        lastMessageTime.hashCode ^
        messageId.hashCode;
  }
}
