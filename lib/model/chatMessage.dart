import 'package:intl/intl.dart';

class ChatMessage {
  final String message;
  final String sender;
  final String timestamp;  // giờ là String rồi

  ChatMessage({
    required this.message,
    required this.sender,
    required this.timestamp,
  });

  Map<String, Object?> toMap() {
    return {
      'message': message,
      'sender': sender,
      'timestamp': timestamp,  // lưu thẳng string định dạng
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'] ?? '',
      sender: map['sender'] ?? '',
      timestamp: map['timestamp'] ?? '', // lấy string thẳng
    );
  }
}


class ChatDocument {
  final List<ChatMessage> messages;
  final int orderId;
  final int resId;
  final int userId;
  final DateTime? latestTimestamp;

  ChatDocument({
    required this.messages,
    required this.orderId,
    required this.resId,
    required this.userId,
    this.latestTimestamp,
  });

  Map<String, Object?> toMap() {
    return {
      'messages': messages.map((m) => m.toMap()).toList(),
      'order_id': orderId,
      'res_id': resId,
      'user_id': userId,
      'lastest_timestamp': latestTimestamp?.toIso8601String(),
    };
  }

  factory ChatDocument.fromMap(Map<String, dynamic> map) {
    DateTime? parseLatestTimestamp(String? ts) {
      if (ts == null) return null;
      try {
        return DateTime.parse(ts);
      } catch (_) {
        final formatter = DateFormat("HH:mm:ss dd/M/yyyy");
        return formatter.parse(ts);
      }
    }

    return ChatDocument(
      messages: (map['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessage.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      orderId: map['order_id'] ?? 0,
      resId: map['res_id'] ?? 0,
      userId: map['user_id'] ?? 0,
      latestTimestamp: parseLatestTimestamp(map['lastest_timestamp']),
    );
  }
}
