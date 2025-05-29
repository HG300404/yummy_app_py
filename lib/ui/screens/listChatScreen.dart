import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_app/ui/screens/chatScreen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../db/chatMessageController.dart';
import '../../db/restaurantController.dart';
import '../../db/userController.dart';
import '../../model/chatMessage.dart';
import '../../model/restaurants.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int? _userId;
  Stream<List<ChatDocument>>? _chatsStream;
  final ChatController _chatController = ChatController();

  // Cache Restaurant để tránh gọi API nhiều lần
  final Map<int, Restaurants> _restaurantCache = {};

  @override
  void initState() {
    super.initState();
    _loadUserIdAndChats();
  }

  Future<void> _loadUserIdAndChats() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userIdInt = prefs.getInt('user_id');
    if (userIdInt != null) {
      setState(() {
        _userId = userIdInt;
        _chatsStream = _chatController.getUserChatsStream(_userId!);
      });
    } else {
      // TODO: Xử lý trường hợp không có user_id (ví dụ show màn đăng nhập)
      print("User ID chưa có trong SharedPreferences");
    }
  }

  Future<Restaurants> _fetchRestaurant(int resId) async {
    if (_restaurantCache.containsKey(resId)) {
      return _restaurantCache[resId]!;
    }

    Restaurants res = Restaurants(
      id: 0,
      name: '',
      address: '',
      phone: '',
      opening_hours: '',
      created_at: null,
      updated_at: null,
    );

    try {
      ApiResponse response = await RestaurantController().getItem(resId);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.body;
        res = Restaurants.fromMap(data);
        _restaurantCache[resId] = res;
      }
    } catch (e) {
      print('Fetch restaurant error: $e');
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (_chatsStream == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chats')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: StreamBuilder<List<ChatDocument>>(
        stream: _chatsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No chats yet'));
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final lastMessage = chat.messages.isNotEmpty ? chat.messages.last.message : '';
              final String? lastTime = chat.messages.isNotEmpty ? chat.messages.last.timestamp : null;
              print('LastTime raw: $lastTime');
              return FutureBuilder<Restaurants>(
                future: _fetchRestaurant(chat.resId),
                builder: (context, resSnapshot) {
                  if (resSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: Text(lastMessage),
                    );
                  }
                  if (resSnapshot.hasError || !resSnapshot.hasData) {
                    return ListTile(
                      title: Text('Quán ăn'),
                      subtitle: Text(lastMessage),
                    );
                  }

                  final restaurant = resSnapshot.data!;
                  return ListTile(
                    title: Text(
                      (restaurant.name != null && restaurant.name!.isNotEmpty)
                          ? restaurant.name!
                          : 'Quán ăn',
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: _buildTimestampWidget(lastTime),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            res_id: restaurant.id,
                            user_id: _userId!,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget? _buildTimestampWidget(String? lastTime) {
    if (lastTime == null || lastTime.isEmpty) {
      return null;
    }

    try {
      final parsedDate = DateFormat("HH:mm:ss dd/M/yyyy").parse(lastTime).toLocal();
      final formatted = DateFormat('hh:mm a').format(parsedDate);
      return Text(formatted);
    } catch (e) {
      print('Error parsing timestamp: $e');
      return null;
    }
  }
}
