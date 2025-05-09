import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  ScrollController _scrollController = ScrollController(); // Khai báo ScrollController

  // Gửi tin nhắn tới API và nhận phản hồi
  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    // Thêm tin nhắn của người dùng vào danh sách
    setState(() {
      _messages.add({"sender": "user", "text": message});
    });

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/webhook/"),  // Đảm bảo địa chỉ API đúng
        headers: {"Content-Type": "application/json"},
        body: json.encode({"message": message}),
      );

      if (response.statusCode == 200) {
        // Dùng utf8.decode để giải mã bodyBytes thành chuỗi
        var jsonResponse = utf8.decode(response.bodyBytes);  // Giải mã byte về chuỗi UTF-8
        var parsedJson = jsonDecode(jsonResponse);  // Chuyển đổi chuỗi thành JSON

        // Kiểm tra nếu có tin nhắn trả về từ API và thêm vào danh sách tin nhắn
        if (parsedJson != null && parsedJson.isNotEmpty) {
          setState(() {
            _messages.add({
              "sender": "bot",
              "text": parsedJson[0]['text'], // Nhận trả về của API
            });
          });

          // Sau khi tin nhắn mới được thêm vào, cuộn xuống tin nhắn mới nhất
          _scrollToBottom();
        }
      } else {
        // Nếu có lỗi từ API, hiển thị lỗi
        setState(() {
          _messages.add({
            "sender": "bot",
            "text": "Có lỗi xảy ra. Vui lòng thử lại.",
          });
        });
      }
    } catch (error) {
      // Nếu có lỗi trong quá trình gọi API
      print("Error: $error");
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": "Không thể kết nối với server.",
        });
      });
    }
  }

  // Phương thức để cuộn xuống tin nhắn mới nhất
  void _scrollToBottom() {
    // Đảm bảo cuộn đến cuối ListView
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Gắn ScrollController cho ListView
              reverse: false, // Để tin nhắn mới xuất hiện ở dưới cùng
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageWidget(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                    ),
                    keyboardType: TextInputType.text, // Đảm bảo có thể nhập văn bản bình thường
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _controller.text.trim();
                    _controller.clear();
                    _sendMessage(message);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng giao diện hiển thị tin nhắn
  Widget _buildMessageWidget(Map<String, String> message) {
    bool isUserMessage = message['sender'] == "user";
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message['text']!,
          style: TextStyle(
            color: isUserMessage ? Colors.white : Colors.black,
            fontSize: 16, // Cài đặt fontSize cho tin nhắn
            fontWeight: FontWeight.w400, // Điều chỉnh độ đậm font
          ),
        ),
      ),
    );
  }
}
