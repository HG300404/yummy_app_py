import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../model/chatMessage.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference _chatCollection;

  ChatController() {
    _chatCollection = _firestore.collection('chats');
  }

    Stream<List<ChatDocument>> getUserChatsStream(int userId) {
      return _firestore
          .collection('chats')
          .where('user_id', isEqualTo: userId)
          .snapshots()
          .map((querySnapshot) {
        print("Docs count: ${querySnapshot.docs.length}");
        final chats = querySnapshot.docs.map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final chatDoc = ChatDocument.fromMap(data);
            return chatDoc;
          } catch (e, stack) {
            print('Error parsing ChatDocument: $e');
            return null; // hoặc throw; tùy ý
          }
        }).where((chatDoc) => chatDoc != null).cast<ChatDocument>().toList();



        print('Loaded ${chats.length} chats for userId=$userId');
        return chats;
      });
    }



  Stream<List<ChatMessage>> getMessagesByUserAndRes(int userId, int resId) {
    return _firestore
        .collection('chats')
        .where('user_id', isEqualTo: userId)
        .where('res_id', isEqualTo: resId)
        .orderBy('lastest_timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      // Lấy danh sách các danh sách message từ từng document
      final listOfLists = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final messagesData = data['messages'] as List<dynamic>? ?? [];
        return messagesData.map((msg) => ChatMessage.fromMap(msg as Map<String, dynamic>)).toList();
      }).toList();

      // Flatten: nối tất cả list con thành một list duy nhất
      return listOfLists.expand((messages) => messages).toList();
    });
  }




  Future<void> addMessageByResAndUser(int resId, int userId, ChatMessage message) async {
    try {
      final querySnapshot = await _chatCollection
          .where('res_id', isEqualTo: resId)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No chat document found for res_id=$resId and user_id=$userId');
        return;
      }

      final chatDoc = querySnapshot.docs.first;

      // Thêm message mới vào mảng 'messages' trong document chat
      await _chatCollection.doc(chatDoc.id).update({
        'messages': FieldValue.arrayUnion([message.toMap()]),
        // Cập nhật luôn latest timestamp nếu muốn
        'lastest_timestamp': message.timestamp,
      });

      print('Message added to messages array in chatId=${chatDoc.id}.');
    } catch (e) {
      print('Failed to add message: $e');
    }
  }


  Future<String> createChatDocument({
    required int orderId,
    required int resId,
    required int userId,
  }) async {
    try {
      final docRef = await _chatCollection.add({
        'order_id': orderId,
        'res_id': resId,
        'user_id': userId,
      });
      print('Chat document created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Failed to create chat document: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> sendCommentToN8n({
    required String userId,
    required String comment,
    required int rating,
    required String orderId,
    required String restaurantId,
  }) async {
    final url = Uri.parse('http://localhost:5678/webhook/sendComment/');

    final body = json.encode({
      'userid': userId,
      'comment': comment,
      'rating': rating,
      'orderid': orderId,
      'restaurantid': restaurantId,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      print('Sent comment data to n8n');
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      print('Failed to send comment data: ${response.statusCode}');
      return null;
    }
  }
}
