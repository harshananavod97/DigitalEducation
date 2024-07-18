import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  Message({
    required this.by,
    required this.isTextMessage,
    required this.message,
    required this.messageId,
    required this.roomId,
    required this.timestamp,
  });

  Message.empty()
      : by = '',
        isTextMessage = false,
        message = '',
        messageId = '',
        roomId = '',
        timestamp = Timestamp.now();

  Message.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final json = documentSnapshot.data()! as Map<String, dynamic>;

    by = json['by'] as String? ?? '';
    isTextMessage = json['isTextMessage'] as bool? ?? false;
    message = json['message'] as String? ?? '';
    messageId = documentSnapshot.id;
    roomId = json['roomId'] as String? ?? '';
    timestamp = json['timestamp'] as Timestamp? ?? Timestamp.now();
  }

  late final String messageId;
  late final String message;
  late final String roomId;
  late final String by;
  late final Timestamp timestamp;
  late final bool isTextMessage;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    json['by'] = by;
    json['roomId'] = roomId;
    json['message'] = message;
    json['isTextMessage'] = isTextMessage;
    json['timestamp'] = timestamp;
    return json;
  }

  Message copyWith({String? messageDocumentId}) {
    return Message(
      by: by,
      isTextMessage: isTextMessage,
      message: message,
      messageId: messageDocumentId ?? messageId,
      roomId: roomId,
      timestamp: timestamp,
    );
  }
}
