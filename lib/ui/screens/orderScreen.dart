import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';
import 'package:food_app/model/dishes.dart';
import 'package:food_app/ui/screens/detail_dish_page.dart';
import 'package:food_app/ui/screens/reviewScreen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../db/cartController.dart';
import '../../db/firebaseController.dart';
import '../../db/orderController.dart';
import '../../db/restaurantController.dart';
import '../../db/reviewController.dart';
import '../../db/userController.dart';
import '../../model/firebaseModel.dart';
import '../../model/restaurants.dart';
import '../../model/reviews.dart';

void main() {
  runApp(MaterialApp(
    home: OrderScreen(),
    theme: ThemeData(
      primaryColor: Constants.primaryColor,
    ),
  ));
}

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this,  initialIndex: 0);
    _tabController.addListener(_tabChanged); // Lắng nghe sự thay đổi tab
    _getUserId().then((_) {
      _getItem();
    });
  }

  var user_id = 0;

  // Lấy user_id
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id')!;
  }

  // Hiển thị SnackBar
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

  List<dynamic> list = [];
  Map<int, Map<dynamic, dynamic>> cart = {};

  // Lấy item giỏ hàng
  Future<void> _getItem() async {
    try {
      ApiResponse response = await CartController().getAllByUser(user_id);
      if (response.statusCode == 200) {
        setState(() {
          list = response.body;
          list.forEach((item) {
            cart[item['id']] = {
              'restaurant_name': item['restaurant_name'],
              'address': item['address'],
              'img': item['img'],
              'count': item['count'],
            };
          });
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      print(error);
    }
  }

  // Lắng nghe sự thay đổi tab
  void _tabChanged() {
    if (_tabController.index == 2) {
      // Nếu chọn tab "Giỏ hàng"
      _getItem(); // Gọi lại _getItem khi chuyển sang tab Giỏ hàng
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(
        _tabChanged); // Hủy lắng nghe sự thay đổi tab khi widget bị hủy
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng',
            style:
                TextStyle(color: Constants.white, fontWeight: FontWeight.bold)),
        backgroundColor: Constants.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Constants.white,
          labelStyle: TextStyle(fontSize: 18.0, color: Constants.white),
          tabs: [
            Tab(text: 'Đang đến'),
            Tab(text: 'Đánh giá'),
            Tab(text: 'Giỏ hàng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DangDenTab(),
          DanhGiaTab(),
          GioHangTab(cart), // Pass cart to GioHangTab
        ],
      ),
    );
  }
}

class DangDenTab extends StatelessWidget {
  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  // Định dạng giá trị
  String formatPrice(num price) {
    final formatter = NumberFormat("#,##0", "vi_VN");
    return "${formatter.format(price)}đ";
  }

  final FirebaseController _controller = FirebaseController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          final user_id = snapshot.data ?? 0;
          return StreamBuilder<List<FirebaseModel>>(
            stream: _controller.getAll(user_id.toInt(), "Hoàn thành"),
            builder: (context, snapshot1) {
              if (snapshot1.data == null || snapshot1.data!.isEmpty) {
                return Center(
                  child: Text(
                    "Không có đơn hàng đang giao", // Dòng chữ thông báo
                    style: TextStyle(
                      color: Colors.grey, // Màu chữ nhạt
                      fontSize: 16, // Kích thước chữ
                    ),
                  ),
                );
              } else {
                final orders = snapshot1.data;
                final models = snapshot1.data;
                final modelString =
                    _controller.firebaseModelListToString(models!);
                print(modelString);
                return ListView.builder(
                  itemCount: orders?.length,
                  itemBuilder: (context, index) {
                    final order = orders?[index];
                    print("order_id: ${order?.status}");
                    Future<Restaurants> _getItem(int resId) async {
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
                        ApiResponse response =
                            await RestaurantController().getItem(resId);

                        if (response.statusCode == 200) {
                          Map<String, dynamic> data = response.body;
                          res = Restaurants.fromMap(data);
                        }
                      } catch (error) {
                        print(error);
                      }

                      return res;
                    }

                    return FutureBuilder<Restaurants>(
                      future: _getItem(order!.res_id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          Restaurants? res = snapshot.data;
                          return Card(
                            margin: EdgeInsets.all(10),
                            color: Constants.backgroundTable,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Đồ ăn ${order.order_id}',
                                      style: TextStyle(
                                          color: Constants.highlightColor,
                                          fontSize: 15)),
                                  SizedBox(height: 5),
                                  Text("${res?.name}",
                                      style: TextStyle(
                                          color: Constants.accentColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  FutureBuilder(
                                    future: OrderController()
                                        .getAllByOrder(order!.order_id),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}");
                                      } else {
                                        List<dynamic> list =
                                            snapshot.data!.body;
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: list.length,
                                          itemBuilder: (context, index) {
                                            var orderItem = list[
                                                index]; // orderItem là đối tượng, không phải List

                                            return Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Truy xuất trực tiếp vào orderItem['dishes'] nếu 'dishes' là một danh sách trong orderItem
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5.0),
                                                      child: Row(
                                                        children: [
                                                          // Xử lý hình ảnh từ Base64 (nếu có)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: (orderItem[
                                                                            'dish_img'] !=
                                                                        null &&
                                                                    orderItem[
                                                                            'dish_img']
                                                                        .startsWith(
                                                                            'data:image/jpeg;base64,'))
                                                                ? Image.memory(
                                                                    base64Decode(orderItem[
                                                                            'dish_img']
                                                                        .substring(
                                                                            'data:image/jpeg;base64,'.length)),
                                                                    width: 60,
                                                                    height: 60,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorBuilder: (BuildContext
                                                                            context,
                                                                        Object
                                                                            exception,
                                                                        StackTrace?
                                                                            stackTrace) {
                                                                      return const Icon(
                                                                          Icons
                                                                              .error);
                                                                    },
                                                                  )
                                                                : Image.asset(
                                                                    "assets/images/image.png", // Hình ảnh mặc định nếu không có base64 hợp lệ
                                                                    width: 60,
                                                                    height: 60,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Text(
                                                            orderItem[
                                                                'dish_name'], // Truy cập trực tiếp vào 'dish_name' trong orderItem
                                                            style: TextStyle(
                                                              color: Constants
                                                                  .textColor,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Text(
                                                            "${orderItem['quantity']}", // Truy cập trực tiếp vào 'quantity' trong orderItem
                                                            style: TextStyle(
                                                              color: Constants
                                                                  .textColor,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      formatPrice(order
                                                          .total), // Hiển thị tổng giá của order
                                                      style: TextStyle(
                                                        color: Constants
                                                            .primaryColor,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),

                                                    // Hiển thị tổng số món ăn
                                                    Text(
                                                      '${orderItem['quantity']} món', // Hiển thị 'length'
                                                      style: TextStyle(
                                                        color: Constants
                                                            .lightTextColor,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}

class LichSuTab extends StatelessWidget {
  final List<Map<String, dynamic>> history = [
    {
      'id': '#05054-674530315',
      'shop': 'Highlands Coffee - Nguyễn Huệ',
      'items': [
        {'name': 'Cà phê sữa đá', 'image': 'assets/images/item_3.png'},
        {'name': 'Bánh mì thịt', 'image': 'assets/images/item_1.png'}
      ],
      'total': 85000,
      'date': '21/4 lúc 14:00',
      'status': 'Đã giao'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Constants.backgroundTable,
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(Icons.monetization_on, color: Colors.yellow),
              SizedBox(width: 10),
              Text('Đánh giá quán, nhận ngay 500 Xu',
                  style: TextStyle(color: Constants.textColor, fontSize: 16)),
              Spacer(),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Constants.textColor),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final order = history[index];
              return Card(
                margin: EdgeInsets.all(10),
                color: Constants.backgroundTable,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Đồ ăn ${order['id']}',
                          style: TextStyle(
                              color: Constants.textColor, fontSize: 16)),
                      SizedBox(height: 5),
                      Text(order['shop'],
                          style: TextStyle(
                              color: Constants.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: order['items'].map<Widget>((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  children: [
                                    Image.asset(item['image'], height: 60),
                                    SizedBox(width: 10),
                                    Text(item['name'],
                                        style: TextStyle(
                                            color: Constants.textColor,
                                            fontSize: 16)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${order['total']}đ',
                                  style: TextStyle(
                                      color: Constants.primaryColor,
                                      fontSize: 16)),
                              Text('${order['items'].length} món',
                                  style: TextStyle(
                                      color: Constants.lightTextColor,
                                      fontSize: 16)),
                              Text('Ngày đặt: ${order['date']}',
                                  style: TextStyle(
                                      color: Constants.lightTextColor)),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.pinkAccent,
                              ),
                              onPressed: () {},
                              child: Text(order['status']),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.pinkAccent,
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () {},
                              child: Text('Đặt lại'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
class DanhGiaTab extends StatelessWidget {
  // Định dạng giá trị tiền


  String formatPrice(num price) {
    final formatter = NumberFormat("#,##0", "vi_VN");
    return "${formatter.format(price)}đ";
  }

  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  final FirebaseController _controller = FirebaseController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          final user_id = snapshot.data ?? 0;
          return StreamBuilder<List<FirebaseModel>>(
            stream: _controller.getOrdered(user_id.toInt(), "Hoàn thành"),
            builder: (context, snapshot1) {
              if (snapshot1.data == null || snapshot1.data!.isEmpty) {
                return Center(
                  child: Text(
                    "Không có đơn hàng cần đánh giá",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),

                  ),
                );
              } else {
                final orders = snapshot1.data!;
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    Future<Restaurants> _getItem(int resId) async {
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
                        ApiResponse response =
                        await RestaurantController().getItem(resId);
                        if (response.statusCode == 200) {
                          Map<String, dynamic> data = response.body;
                          res = Restaurants.fromMap(data);
                        }
                      } catch (error) {
                        print(error);
                      }
                      return res;
                    }

                    Future<Reviews> _getReview(int order_id) async {
                      Reviews reviews = Reviews(
                        id: 0,
                        order_id: 0,
                        user_id: 0,
                        restaurant_id: 0,
                        rating: 0,
                        comment: '',
                        created_at: null,
                        updated_at: null,
                      );

                      try {
                        ApiResponse response =
                        await ReviewController().getItem(order_id);

                        if (response.statusCode == 200) {
                          Map<String, dynamic> data = response.body;
                          reviews = Reviews.fromMap(data);
                        }
                      } catch (error) {
                        print(error);
                      }

                      return reviews;
                    }

                    return FutureBuilder<Restaurants>(
                      future: _getItem(order.res_id),
                      builder: (context, snapshotRes) {
                        if (snapshotRes.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshotRes.hasError) {
                          return Text("Error: ${snapshotRes.error}");
                        } else {
                          Restaurants? res = snapshot.data;

                          Future<Reviews> _getReview(int order_id) async {
                            Reviews reviews = Reviews(
                              id: 0,
                              order_id: 0,
                              user_id: 0,
                              restaurant_id: 0,
                              rating: 0,
                              comment: '',
                              created_at: null,
                              updated_at: null,
                            );
                            try {
                              ApiResponse response =
                              await ReviewController().getItem(order_id);
                              if (response.statusCode == 200) {
                                Map<String, dynamic> data = response.body;
                                reviews = Reviews.fromMap(data);
                              }
                            } catch (error) {
                              print(error);
                            }
                            return reviews;
                          }

                          return FutureBuilder<Reviews>(
                            future: _getReview(order.order_id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshotReview.hasError) {
                                return Text("Error: ${snapshotReview.error}");
                              } else {
                                Reviews? review = snapshotReview.data;
                                String doneText;

                                if (!snapshotReview.hasData || review == null || review.id == null || review.id == 0) {
                                  doneText = "Đánh giá";
                                } else {
                                  doneText = "Đã đánh giá";
                                }


                                return Card(
                                  margin: EdgeInsets.all(10),
                                  color: Constants.backgroundTable,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text('Đồ ăn ${order.order_id}',
                                            style: TextStyle(
                                                color: Constants.textColor,
                                                fontSize: 16)),
                                        SizedBox(height: 5),
                                        Text("${res?.name}",
                                            style: TextStyle(
                                                color: Constants.accentColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 5),
                                        FutureBuilder(
                                          future: OrderController().getAllByOrder(order.order_id),
                                          builder: (context, snapshotOrderItems) {
                                            if (snapshotOrderItems.connectionState == ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            } else if (snapshotOrderItems.hasError) {
                                              return Text("Error: ${snapshotOrderItems.error}");
                                            } else if (snapshotOrderItems.data == null || snapshotOrderItems.data!.body == null) {
                                              return Center(
                                                child: Text(
                                                  "Không có đơn hàng",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 16),
                                                ),
                                              );
                                            } else {
                                              List<dynamic> list = snapshotOrderItems.data!.body;
                                              return ListView.builder(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemCount: list.length,
                                                itemBuilder: (context, index) {
                                                  var orderItem = list[index];
                                                  return Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.all(10),
                                                                  child: (orderItem['dish_img'] != null &&
                                                                      orderItem['dish_img'].startsWith('data:image/jpeg;base64,'))
                                                                      ? Image.memory(
                                                                    base64Decode(orderItem['dish_img'].substring('data:image/jpeg;base64,'.length)),
                                                                    width: 60,
                                                                    height: 60,
                                                                    fit: BoxFit.cover,
                                                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                      return const Icon(Icons.error);
                                                                    },
                                                                  )
                                                                      : Image.asset(
                                                                    "assets/images/image.png",
                                                                    width: 60,
                                                                    height: 60,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                                SizedBox(width: 10),
                                                                Text(
                                                                  orderItem['dish_name'],
                                                                  style: TextStyle(
                                                                    color: Constants.textColor,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Spacer(),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            formatPrice(order.total),
                                                            style: TextStyle(
                                                              color: Constants.primaryColor,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${orderItem['quantity']} món',
                                                            style: TextStyle(
                                                              color: Constants.lightTextColor,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Colors.pinkAccent,
                                                ),
                                                onPressed: () {
                                                  if (doneText == "Đánh giá") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ReviewScreen(
                                                          resID: res!.id,
                                                          userID: user_id,
                                                          orderID: order.order_id,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Text(doneText),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.pinkAccent,
                                                  backgroundColor: Colors.white,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => DetailDish(resID: res!.id),
                                                    ),
                                                  );
                                                },
                                                child: Text('Đặt lại'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }
                      },
                    );
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}


class GioHangTab extends StatelessWidget {
  final Map<int, Map<dynamic, dynamic>> cart;

  GioHangTab(this.cart);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cart.length,
      itemBuilder: (context, index) {
        int id = cart.keys.elementAt(index);
        var item = cart[id];
        return GestureDetector(
          // Sử dụng GestureDetector
          onTap: () {
            // Navigate to HomePage when card is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailDish(resID: id)),
            );
          },
          child: Card(
            margin: EdgeInsets.all(10),
            color: Constants.backgroundTable,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  item?['img'] != null
                      ? Image.memory(
                          base64Decode(item?['img']
                              .substring('data:image/jpeg;base64,'.length)),
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.error),
                        )
                      : Icon(Icons.image_not_supported),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item?['restaurant_name'],
                            style: TextStyle(
                                color: Constants.accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text(item?['address'],
                            style: TextStyle(
                                color: Constants.textColor, fontSize: 15)),
                        SizedBox(height: 5),
                        Text("${item?['count']} sản phẩm",
                            style: TextStyle(color: Constants.lightTextColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
