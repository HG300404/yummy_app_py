import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';
import 'package:food_app/ui/screens/orderScreen.dart';
import 'package:image_picker/image_picker.dart';

import '../../db/reviewController.dart';
import '../../db/userController.dart';

class ReviewScreen extends StatefulWidget {
  final int resID,userID,orderID;
  const ReviewScreen({super.key, required this.resID, required this.userID, required this.orderID});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _selectedStars = 0;
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đánh giá sản phẩm', style: TextStyle(color: Constants.white)),
        backgroundColor: Constants.primaryColor,
        actions: [
          TextButton(
            onPressed: () async {
              print(widget.resID);
              try {
                //String user_id, String restaurant_id, String rating, String order_id, String comment
                ApiResponse response = await ReviewController().create(widget.userID.toString(), widget.resID.toString(), _selectedStars.toString(), widget.orderID.toString(), commentController.text );
                if (response.statusCode == 200) {
                    var jsonResponse = response.body;
                    if (jsonResponse['status'] == 'success') {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => OrderScreen()),
                      );
                    }
                }
              } catch (error) {
                // Xử lý lỗi (nếu có)
                print(error);
              }
            },
            child: Text(
              'Gửi',
              style: TextStyle(color: Constants.white, fontSize: 18),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Chất lượng sản phẩm', style: TextStyle(fontSize: 16)),
              subtitle: SingleChildScrollView( // Wrap the Row inside SingleChildScrollView
                scrollDirection: Axis.horizontal, // Allows horizontal scrolling
                child: Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _selectedStars ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedStars = index + 1;
                        });
                      },
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Thêm 50 ký tự để nhận đến 1000 xu',
              style: TextStyle(fontSize: 15, color: Colors.orange),
            ),
            SizedBox(height: 20),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Hãy chia sẻ nhận xét cho quán ăn này bạn nhé!',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      )

    );
  }
}
