import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';
import 'package:food_app/ui/screens/home_page.dart';
import 'package:food_app/ui/screens/orderScreen.dart';
import 'package:food_app/ui/screens/profile_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}


class _RootPageState extends State<RootPage> {
  int _bottomNavIndex = 0;

  // List of the page
  List<Widget> pages =  [
    HomePage(),
    OrderScreen(),
    ProfileView(),
  ];

  // List of the page icons
  List<IconData> iconList = [Icons.home, Icons.list_alt_outlined, Icons.person];

  // List of the pages titles
  List<String> titleList = ["Trang chủ", "Đơn hàng", "Thông tin cá nhân"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _bottomNavIndex,
        children: pages,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
          splashColor: Constants.primaryColor,
          activeColor: Constants.primaryColor,
          inactiveColor: Colors.black.withOpacity(.5),
          icons: iconList,
          activeIndex: _bottomNavIndex,
          gapLocation: GapLocation.none,
          notchSmoothness: NotchSmoothness.softEdge,
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index;
            });
          }),
    );
  }
}