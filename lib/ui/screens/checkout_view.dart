import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';
import 'package:food_app/db/orderController.dart';
import 'package:food_app/model/orders.dart';
import 'package:food_app/ui/screens/change_info_view.dart';
import 'package:food_app/ui/widget/common_widget/round_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../db/cartController.dart';
import '../../db/firebaseController.dart';
import '../../db/restaurantController.dart';
import '../../db/userController.dart';
import '../../model/firebaseModel.dart';
import '../../model/restaurants.dart';
import '../../model/users.dart';
import 'checkout_message_view.dart';


class CheckoutView extends StatefulWidget {
  final int resID;
  final String note;
  const CheckoutView({super.key, required this.resID,  required this.note});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {

  final FirebaseController _controller = FirebaseController();

  List paymentArr = [
    {"name": "Thanh toán khi nhận hàng", "icon": "assets/images/cash-icon.png"},
    {"name": "**** **** **** 2187", "icon": "assets/images/visa_icon.png"},
    {"name": "test@gmail.com", "icon": "assets/images/paypal.png"},
  ];

  int selectMethod = -1;

  // Định dạng giá trị
  String formatPrice(num price) {
    final formatter = NumberFormat("#,##0", "vi_VN");
    return "${formatter.format(price)}đ"; // Trả về giá dưới dạng "20.000đ"
  }
  
  @override
  void initState() {
    super.initState();
    _getUserId().then((_) {
      _getCart();
      _getItem();
    });
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
  Users item = Users(
    id: 0,
    name: '',
    password: '',
    email: '',
    phone: '',
    address: '',
    role: '',
    imageURL: '',
    level: 0,
    coin: 0,
    created_at: null,
    updated_at: null,
  );
  Future<void> _getItem() async {
    try {
      ApiResponse response = await UserController().getItem(user_id);
      if (response.statusCode == 200) {
        setState(() {
          Map<String, dynamic> data = response.body;
          item = Users.fromMap(data);
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }
  List<dynamic> list = [];
  Map<int, Map<dynamic, dynamic>> cart = {};
  Future<void> _getCart() async {
    try {
      ApiResponse response = await CartController().getAll(user_id, widget.resID);
      if (response.statusCode == 200) {
        setState(() {
          list = response.body;
          list.forEach((item) {
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


  Orders order = Orders(
    id: 0,
    user_id: 0,
    restaurant_id: 0,
    price: 0,
    ship: 0,
    discount: 0,
    total_amount: 0,
    payment: '',
    created_at: null,
    updated_at: null,
  );
  Future<void> createOrder() async {
    try {
      ApiResponse response = await OrderController().createOrder(user_id, widget.resID, getTotalAmount().toInt(), 5000 , item.coin, getTotal().toInt(), selectMethod);
      if (response.statusCode == 200) {
        setState(() {
          Map<String, dynamic> data = response.body;
          order = Orders.fromMap(data);
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }
  Future<void> createOrderItem() async {
    try {
      ApiResponse response = await OrderController().createOrderItem(order.id.toString(), user_id.toString(), widget.resID.toString(), widget.note);
      if (response.statusCode == 200) {
        // setState(() {
        //   list = jsonDecode(response.body);
        //
        // });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }

  Future<void> saveDataToFirebase(
      int user_id,
      Users item,
      Map<int, Map<dynamic, dynamic>> cart,
      Orders order,
      String note,
      int res_id,
      ) async {
    final Customer customer = Customer(
      name: item.name,
      address: item.address!,
      cus_id: item.id,
    );
    List<Dish> dishes = [];
    cart.forEach((key, value) {
      dynamic dishName = value['dish_name'];
      dynamic dishPrice = value['dish_price'];
      dynamic dishQuantity = value['quantity'];
      Dish dish = Dish(name: dishName, price: dishPrice, quantity: dishQuantity, options: note);
      dishes.add(dish);
    });
    // final Customer customer;
    // final String status;
    // final int total;
    // final int order_id;
    // final int res_id;
    // final List<Dish> dishes;

    // Tạo đối tượng FirebaseModel
    final FirebaseModel data = FirebaseModel(
      customer: customer,
      status: 'Chưa xử lý',
      total: order.total_amount,
      order_id: order.id,
      res_id: res_id, // Thay đổi giá trị res_id tùy theo logic của bạn
      dishes: dishes,
    );

    // Gọi hàm saveDataToFirebase để lưu dữ liệu
    FirebaseController().saveDataToFirebase(data);
  }
  Future<bool> handleOrderCreation() async {
    try {
      await createOrder();
      await createOrderItem();
      await saveDataToFirebase(user_id, item, cart, order, widget.note, widget.resID);
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }


  num getTotalAmount() {
    num total = 0;
    for (var item in cart.values){
      total += item['dish_price'] * item['quantity'];
    }
    return total;
  }

  num getTotal() {
    num total = getTotalAmount() + 5000 - item.coin;
    return total;
  }
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
                        "Thanh toán",
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Địa chỉ giao hàng",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(color: Constants.highlightColor, fontSize: 12),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "${item.name}\n${item.address}\n${item.phone}",
                            style: TextStyle(
                                color: Constants.lightTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const ChangeInfoView()),
                            );
                          },
                          child: Text(
                            "Thay đổi",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: Constants.textfield),
                height: 8,
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
                          "Phương thức thanh toán",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Constants.highlightColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add, color: Constants.primaryColor),
                          label: Text(
                            "Thêm thẻ",
                            style: TextStyle(
                                color: Constants.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        )
                      ],
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: paymentArr.length,
                        itemBuilder: (context, index) {
                          var pObj = paymentArr[index] as Map? ?? {};
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 15.0),
                            decoration: BoxDecoration(
                                color: Constants.textfield,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color:
                                    Constants.highlightColor.withOpacity(0.2))),
                            child: Row(
                              children: [
                                Image.asset(pObj["icon"].toString(),
                                    width: 50, height: 50, fit: BoxFit.contain),
                                // const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    pObj["name"],
                                    style: TextStyle(
                                        color: Constants.lightTextColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectMethod = index;
                                      print(selectMethod);
                                    });
                                  },
                                  child: Icon(
                                    selectMethod == index
                                        ? Icons.radio_button_on
                                        : Icons.radio_button_off,
                                    color: Constants.primaryColor,
                                    size: 15,
                                  ),
                                )
                              ],
                            ),
                          );
                        })
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: Constants.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          formatPrice(getTotalAmount()),
                          style: TextStyle(
                              color: Constants.lightTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Phí ship",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Constants.lightTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "5.000đ",
                          style: TextStyle(
                              color: Constants.lightTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Giảm giá",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Constants.lightTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          formatPrice(item.coin),
                          style: TextStyle(
                              color: Constants.lightTextColor,
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
                          "Thành tiền",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Constants.lightTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          formatPrice(getTotal()),
                          style: TextStyle(
                              color: Constants.lightTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: Constants.textfield),
                height: 8,
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                child: RoundButton(
                    title: "Đặt hàng",
                    onPressed: () {
                      handleOrderCreation().then((success) {
                        if (success) {
                          showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.pinkAccent,
                              isScrollControlled: true,
                              builder: (context) {
                                return const CheckoutMessageView();
                              });
                        } else {
                          print('Order creation failed');
                        }
                      });
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
