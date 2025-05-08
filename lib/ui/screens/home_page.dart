import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';
import 'package:food_app/db/dishController.dart';
import 'package:food_app/db/restaurantController.dart';
import 'package:food_app/ui/screens/my_order_view.dart';
import 'package:food_app/ui/screens/searchPage.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../db/userController.dart';
import '../widget/common_widget/category_cell.dart';
import '../widget/common_widget/most_popular_cell.dart';
import '../widget/common_widget/popular_resutaurant_row.dart';
import '../widget/common_widget/recent_item_row.dart';
import '../widget/common_widget/round_textfield.dart';
import '../widget/common_widget/view_all_title_row.dart';
import 'orderScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController txtSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getTopDishes();
    _getTopRes();
    _getRecent();
    getUserId();
  }

  var user_id = 0;

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id')!;
    print(user_id);
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

  List<dynamic> topDishes = [];
  List<dynamic> topRes = [];
  List<dynamic> dishRecent = [];

  Future<void> _getTopDishes() async {
    try {
      ApiResponse response = await DishController().getTop();
      if (response.statusCode == 200) {
        setState(() {
          // topDishes = jsonDecode(response.body);
          topDishes = response.body;
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _getTopRes() async {
    try {
      ApiResponse response = await RestaurantController().getTop();
      if (response.statusCode == 200) {
        setState(() {
           // topRes = jsonDecode(response.body);
          topRes = response.body;
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _getRecent() async {
    try {
      ApiResponse response = await DishController().getRecent();
      if (response.statusCode == 200) {
        setState(() {
          dishRecent = jsonDecode(response.body);
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      print(error);
    }
  }

  List catArr = [
    {"image": "assets/images/cat_offer.png", "name": "Fast Food"},
    {"image": "assets/images/cat_sri.png", "name": "Cơm nhà"},
    {"image": "assets/images/cat_3.png", "name": "Trái cây"},
    {"image": "assets/images/cat_4.png", "name": "Đồ ăn Ấn"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Chào buổi sáng",
                      style: TextStyle(
                          color: Constants.lightTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                       onPressed: () {
                         // Navigator.push(
                         // context,
                         //     MaterialPageRoute(
                         //  builder: (context) => OrderScreen()));
                 },
                      icon: Image.asset(
                        "assets/images/shopping-cart.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Giao hàng tới",
                      style: TextStyle(color: Constants.textColor, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Vị trí hiện tại",
                          style: TextStyle(
                              color: Constants.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 25),
                        Image.asset(
                          "assets/images/dropdown.png",
                          width: 12,
                          height: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                  hintText: "Tìm kiếm món ăn",
                  controller: txtSearch,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultsPage(
                              query: txtSearch.text,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        "assets/images/search.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: catArr.length,
                  itemBuilder: ((context, index) {
                    var cObj = catArr[index] as Map? ?? {};
                    return CategoryCell(
                      cObj: cObj,
                      onTap: () {},
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(
                  title: "Top Quán Ăn",
                  onView: () {},
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: topRes.length > 3 ? 3 : topRes.length,
                itemBuilder: ((context, index) {
                  var pObj = topRes[index] as Map? ?? {};
                  return PopularRestaurantRow(
                    pObj: pObj,
                    onTap: () {},
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(
                  title: "Top Món Ăn",
                  onView: () {},
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: topDishes.length > 3 ? 3 : topDishes.length,
                  itemBuilder: ((context, index) {
                    var mObj = topDishes[index] as Map? ?? {};
                    return MostPopularCell(
                      mObj: mObj,
                      onTap: () {},
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
