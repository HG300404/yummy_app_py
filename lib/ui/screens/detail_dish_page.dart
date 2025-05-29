import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:food_app/db/cartController.dart';
import 'package:food_app/db/dishController.dart';
import 'package:food_app/ui/screens/my_order_view.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../db/restaurantController.dart';
import '../../db/userController.dart';
import '../../model/dishes.dart';
import '../../model/restaurants.dart';

class DetailDish extends StatefulWidget {
  final int resID;
  const DetailDish({super.key, required this.resID});

  @override
  State<DetailDish> createState() => _DetailDishState();
}

class _DetailDishState extends State<DetailDish> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    _getItem();
    _search1();
    _search2();
    _search3();
    _getUserId().then((_) {
      _getCart();
    });
  }

  var user_id = 0;
  // Lấy user_id
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id')!;
  }

  // Định dạng giá trị
  String formatPrice(num price) {
    final formatter = NumberFormat("#,##0", "vi_VN");
    return "${formatter.format(price)}đ"; // Trả về giá dưới dạng "20.000đ"
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
    total_rate:0 ,
    phone: '',
    opening_hours: '',
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

  List<dynamic> list1 = [];
  List<dynamic> list2 = [];
  List<dynamic> list3 = [];
  List<dynamic> list = [];
  Map<int, Map<dynamic, dynamic>> cart = {};


  Future<void> _search1() async {
    try {
      ApiResponse response = await DishController().search("Món chính", widget.resID);
      if (response.statusCode == 200) {
        setState(() {
          list1 = response.body;
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }

  Future<void> _search2() async {
    try {
      ApiResponse response = await DishController().search("Món thêm", widget.resID);
      if (response.statusCode == 200) {
        setState(() {
          list2 = response.body;
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }

  Future<void> _search3() async {
    try {
      ApiResponse response = await DishController().search("Đồ uống", widget.resID);
      if (response.statusCode == 200) {
        setState(() {
          list3 = response.body;
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }

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

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/offer_1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/item_1.png'),
                    radius: 40,
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            SizedBox(width: 5),
                            Text(
                              "${item.total_rate}",
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          "${item.name}",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "${item.address}  -  ${item.opening_hours}",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: Constants.backgroundTable,
                appBar: AppBar(
                  bottom: TabBar(
                    tabs: <Widget>[
                      Tab(text: 'Món chính'),
                      Tab(text: 'Món thêm'),
                      Tab(text: 'Đồ uống'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    buildDishList(list1),
                    buildDishList(list2),
                    buildDishList(list3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildCartButton(context),
    );
  }

  Widget buildDishList(List<dynamic> dishList) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: dishList.length,
              itemBuilder: ((context, index) {
                var pObj = Dishes.fromMap(dishList[index]);

                final prefix = 'data:image/jpeg;base64,';
                Uint8List? bytes;
                if (pObj.img != null && pObj.img.startsWith(prefix)) {
                  var base64Image = pObj.img.substring(prefix.length);
                  if (base64Image.length % 4 == 0) {
                    try {
                      bytes = base64Decode(base64Image);
                    } on FormatException {
                      print('Không thể giải mã hình ảnh: dữ liệu base64 không hợp lệ.');
                      bytes = null;
                    }
                  } else {
                    // Sửa lỗi: Dữ liệu hình ảnh bị hỏng: độ dài không phải là bội số của 4.
                    base64Image += '=' * ((base64Image.length % 4 - 4) % 4);
                    try {
                      bytes = base64Decode(base64Image);
                    } on FormatException {
                      print('Không thể giải mã hình ảnh: dữ liệu base64 không hợp lệ.');
                      bytes = null;
                    }
                  }
                } else {
                  bytes = null;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bytes != null
                        ? Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.memory(
                        bytes,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return const Icon(Icons.error);
                        },
                      ),
                    )
                        : Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.asset(
                        "assets/images/image.png",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10, bottom: 2),
                            child: Text(
                              pObj.name,
                              style: TextStyle(
                                color: Constants.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              formatPrice(pObj.price),
                              style: TextStyle(
                                color: Constants.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          buildQuantityButton(CupertinoIcons.minus, () => onDecrement(pObj.id)),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "${cart[pObj.id]?['quantity'] ?? 0}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          buildQuantityButton(CupertinoIcons.add, () => onIncrement(pObj.id)),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget buildCartButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Constants.backgroundTable,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return buildCartPopup(context);
                },
                isScrollControlled: true,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(image: AssetImage("assets/images/cart.png")),
                Text(
                  "(${getAmount()})",
                  style: TextStyle(
                    color: Constants.primaryColor,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Text(
            formatPrice(getTotalAmount()),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Constants.primaryColor,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOrderView(resID: widget.resID)),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Constants.primaryColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "Đặt hàng",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCartPopup(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.67,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Giỏ hàng",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Constants.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Constants.primaryColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      int id = cart.keys.elementAt(index);
                      var item = cart[id];
                      return ListTile(
                        leading: item?['dish_img'] != null
                            ? Image.memory(
                          base64Decode(item?['dish_img'].substring('data:image/jpeg;base64,'.length)),
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                        )
                            : Icon(Icons.image_not_supported),
                        title: Text(item?['dish_name']),
                        subtitle: Text(formatPrice(item?['dish_price'])),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            buildQuantityButton(CupertinoIcons.minus, () {
                              setState(() {
                                // onDecrement(item?['dish_id']);
                                onDecrement(id);
                              });
                            }),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "${item?['quantity']}",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            buildQuantityButton(CupertinoIcons.add, () {
                              setState(() {
                                onIncrement(id);
                              });
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tổng cộng",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Constants.primaryColor,
                      ),
                    ),
                    Text(
                        formatPrice(getTotalAmount()),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Dishes getItemById(int id) {
    for (var dish in list1) {
      if (Dishes.fromMap(dish).id == id) return Dishes.fromMap(dish);
    }
    for (var dish in list2) {
      if (Dishes.fromMap(dish).id == id) return Dishes.fromMap(dish);
    }
    for (var dish in list3) {
      if (Dishes.fromMap(dish).id == id) return Dishes.fromMap(dish);
    }
    throw Exception('Item not found');
  }

  void onDecrement(int id) async {
    if (cart[id] != null && cart[id]?['quantity'] > 1) {
      cart[id]?['quantity']--;
      try {
        ApiResponse response = await CartController().update(user_id, id, widget.resID, cart[id]?['quantity']);
        if (response.statusCode == 200) {
          setState(() {
            // Update state here
          });
        } else {
          _showSnackBar('Server error. Please try again later.', Colors.red);
        }
      } catch (error) {
        print(error);
      }
    } else if (cart[id]?['quantity'] == 1) {
      cart.remove(id);
      try {
        ApiResponse response = await CartController().delete(user_id, id, widget.resID);
        if (response.statusCode == 200) {
          setState(() {
            // Update state here
          });
        } else {
          _showSnackBar('Server error. Please try again later.', Colors.red);
        }
      } catch (error) {
        print(error);
      }
    }
  }

  void onIncrement(int id) async {
    if (cart[id] != null) {
      cart[id]?['quantity']++;
      try {
        ApiResponse response = await CartController().update(user_id, id, widget.resID, cart[id]?['quantity']);
        if (response.statusCode == 200) {
          setState(() {
            // Update state here
          });
        } else {
          _showSnackBar('Server error. Please try again later.', Colors.red);
        }
      } catch (error) {
        print(error);
      }
    } else {
      try {
        ApiResponse response = await CartController().addCart(user_id, widget.resID, id, 1);
        if (response.statusCode == 200) {
          setState(() {
            // Update state here
          });
        } else {
          print(response.body);
          _showSnackBar('Server error. Please try again later.', Colors.red);
        }
      } catch (error) {
        print(error);
      }
      _getCart();
    }
  }

  num getTotalAmount() {
    num total = 0;
    for (var item in cart.values) {
      total += item['dish_price'] * item['quantity'];
    }
    return total;
  }

  num getAmount() {
    num amount = 0;
    for (var item in cart.values) {
      amount += item['quantity'];
    }
    return amount;
  }
}
