import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../db/chatMessageController.dart';
import '../../model/chatMessage.dart';

class ChatDetailScreen extends StatefulWidget {
  final int res_id, user_id;

  const ChatDetailScreen({Key? key, required this.res_id, required this.user_id}) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatController _chatController = ChatController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Detail'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatController.getMessagesByUserAndRes(widget.user_id,widget.res_id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.sender == 'user';

                    return Align(
                      alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color:
                          isUser ? Colors.orange.shade100 : Colors.grey.shade300,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                            bottomLeft:
                            isUser ? Radius.circular(18) : Radius.circular(4),
                            bottomRight:
                            isUser ? Radius.circular(4) : Radius.circular(18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: Offset(1, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.message,
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                            SizedBox(height: 5),
                            Text(
                              DateFormat('hh:mm a • dd/MM/yyyy').format(
                                DateFormat("HH:mm:ss dd/M/yyyy").parse(msg.timestamp).toLocal(),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _sendMessage(value.trim());
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.deepOrange,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final text = _messageController.text.trim();
                        if (text.isNotEmpty) {
                          _sendMessage(text);
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    final formatter = DateFormat("HH:mm:ss dd/M/yyyy");
    final formattedTimestamp = formatter.format(DateTime.now());

    final msg = ChatMessage(
      message: text,
      sender: 'user',
      timestamp: formattedTimestamp,
    );

    await _chatController.addMessageByResAndUser(widget.res_id, widget.user_id, msg);

    _messageController.clear();

    // Thêm xử lý gọi n8n nếu cần
  }
}
