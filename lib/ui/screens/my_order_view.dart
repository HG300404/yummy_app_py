import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';
import 'package:food_app/db/cartController.dart';
import 'package:food_app/db/userController.dart';
import 'package:food_app/model/carts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../db/restaurantController.dart';
import '../../model/restaurants.dart';
import '../widget/common_widget/round_button.dart';
import 'checkout_view.dart';



class MyOrderView extends StatefulWidget {
  final int resID;
  const MyOrderView({super.key, required this.resID});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  num getTotalAmount() {
    num total = 0;
    for (var item in cart.values){
      total += item['dish_price'] * item['quantity'];
    }
    return total;
  }

  // Định dạng giá trị
  String formatPrice(num price) {
    final formatter = NumberFormat("#,##0", "vi_VN");
    return "${formatter.format(price)}đ"; // Trả về giá dưới dạng "20.000đ"
  }

  num getAmount() {
    num amount = 0;
    for (var item in cart.values){
      amount += item['quantity'];
    }
    return amount;
  }
  @override
  void initState() {
    super.initState();
    _getUserId().then((_) {
      _getCart();
    });
    _getItem();
  }
  var user_id = 0;
  // Lấy user_id
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id')!;
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Restaurants item = Restaurants(
    id: 0,
    name: '',
    address: '',
    phone: '',
    opening_hours: '',
    total_rate: 0,
    review_count: 0,
    created_at: null,
    updated_at: null,
  );
  Future<void> _getItem() async {
    try {
      ApiResponse response = await RestaurantController().getItem(widget.resID);
      if (response.statusCode == 200) {
        setState(() {
          Map<String, dynamic> data = response.body;
          item = Restaurants.fromMap(data);
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }

  Map<int, Map<dynamic, dynamic>> cart = {};
  List<dynamic> itemArr = [];
  Future<void> _getCart() async {
    try {
      ApiResponse response = await CartController().getAll(user_id, widget.resID);
      if (response.statusCode == 200) {
        setState(() {
          itemArr = response.body;
          itemArr.forEach((item) {
            cart[item['dish_id']] = {
              'dish_name': item['dish_name'],
              'dish_price': item['dish_price'],
              'dish_img': item['dish_img'],
              'quantity': item['quantity'],
            };
          });
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }
  bool _showInputField = false;
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset("assets/images/back-icon.png",
                          width: 20, height: 20),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        "Đơn hàng của tôi",
                        style: TextStyle(
                            color: Constants.lightTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          "assets/images/item_1.png",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item.name}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Constants.lightTextColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/rate.png",
                                width: 10,
                                height: 10,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${item.total_rate}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Constants.primaryColor, fontSize: 12),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "${item.review_count} Đánh Giá",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Constants.highlightColor, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "${item.opening_hours}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Constants.highlightColor, fontSize: 12),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/icon_address.png",
                                width: 13,
                                height: 13,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  "${item.address}",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Constants.highlightColor,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: Constants.textfield),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: itemArr.length,
                  separatorBuilder: ((context, index) => Divider(
                    indent: 25,
                    endIndent: 25,
                    color: Constants.highlightColor.withOpacity(0.5),
                    height: 1,
                  )),
                  itemBuilder: ((context, index) {
                    var cObj = itemArr[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 25),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "${cObj["dish_name"]} x${cObj["quantity"]}",
                              style: TextStyle(
                                  color: Constants.lightTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            formatPrice(cObj["dish_price"]),
                            style: TextStyle(
                                color: Constants.lightTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          )
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Lưu ý:",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Constants.lightTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showInputField = !_showInputField;
                            });
                          },
                          icon: Icon(Icons.add, color: Constants.primaryColor),
                          label: Text(
                            "Ghi chú",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (_showInputField)
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                hintText: "Nhập ghi chú tại đây...",
                              ),
                            ),
                          ),
                      ],
                    ),
                    Divider(
                      color: Constants.highlightColor.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Số lượng",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Constants.lightTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "${getAmount()}",
                          style: TextStyle(
                              color: Constants.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Divider(
                      color: Constants.highlightColor.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tổng đơn",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Constants.lightTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          formatPrice(getTotalAmount()),
                          style: TextStyle(
                              color: Constants.primaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    RoundButton(
                        title: "Thanh toán",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutView(resID: widget.resID, note: _noteController.text ?? "" ),
                            ),
                          );
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
