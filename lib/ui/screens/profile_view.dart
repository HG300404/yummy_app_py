import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';
import 'package:food_app/ui/screens/my_order_view.dart';
import 'package:food_app/ui/screens/orderScreen.dart';
import 'package:food_app/ui/screens/signin_page.dart';
import 'package:food_app/ui/widget/common_widget/round_button.dart';
import 'package:food_app/ui/widget/common_widget/round_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../db/userController.dart';
import '../../model/users.dart';


class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    _getUserId().then((_) {
      _getItem();
    });
  }

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  var user_id = 0;
  // Lấy user_id
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id')!;
  }

  Future<void> deleteUserId() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('user_id');
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
          // Gán giá trị từ `item` vào `TextEditingController`
          txtName.text = item.name ?? '';
          txtEmail.text = item.email ?? '';
          txtMobile.text = item.phone ?? '';
          txtAddress.text = item.address ?? '';
          txtPassword.text = "";
        });
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }

  Future<void> update() async {
    try {
      ApiResponse response = await UserController().update(item.id.toString(), txtName.text,txtMobile.text,txtEmail.text,txtPassword.text,txtAddress.text, item.role);
      if (response.statusCode == 200) {
        _showSnackBar('Cập nhật thông tin thành công', Colors.green);
      } else {
        _showSnackBar('Server error. Please try again later.', Colors.red);
      }
    } catch (error) {
      // Xử lý lỗi (nếu có)
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hồ Sơ",
                      style: TextStyle(
                          color: Constants.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderScreen()));
                      },
                      icon: Image.asset(
                        "assets/images/shopping-cart.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Constants.highlightColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person,
                  size: 65,
                  color: Constants.highlightColor,
                ),
              ),
              TextButton.icon(
                onPressed: (){},
                icon: Icon(
                  Icons.edit,
                  color: Constants.primaryColor,
                  size: 12,
                ),
                label: Text(
                  "Chỉnh sửa hồ sơ",
                  style: TextStyle(color: Constants.primaryColor, fontSize: 12),
                ),
              ),
              Text(
                "Xin chào ${item.name}!",
                style: TextStyle(
                    color: Constants.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {
                  deleteUserId();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignIn()));
                },
                child: Text(
                  "Đăng xuất",
                  style: TextStyle(
                      color: Constants.highlightColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: RoundTitleTextfield(
                  title: "Tên",
                  hintText: "Nhập tên",
                  controller: txtName,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: RoundTitleTextfield(
                  title: "Email",
                  hintText: "Nhập Email",
                  keyboardType: TextInputType.emailAddress,
                  controller: txtEmail,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: RoundTitleTextfield(
                  title: "Số điện thoại",
                  hintText: "Nhập số điện thoại",
                  controller: txtMobile,
                  keyboardType: TextInputType.phone,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: RoundTitleTextfield(
                  title: "Địa chỉ",
                  hintText: "Nhập địa chỉ",
                  controller: txtAddress,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: RoundTitleTextfield(
                  title: "Mật khẩu",
                  hintText: "* * * * * *",
                  obscureText: true,
                  controller: txtPassword,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundButton(
                  title: "Save",
                  onPressed: update,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ]),
          ),
        ));
  }
}
