import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db/userController.dart'; // Import UserController

class ChangeInfoView extends StatefulWidget {
  const ChangeInfoView({super.key});

  @override
  State<ChangeInfoView> createState() => _ChangeInfoViewState();
}

class _ChangeInfoViewState extends State<ChangeInfoView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  var user_id = 0;
  String _email = '';
  String _password = '';
  String _role = '';

  // Lấy user_id từ SharedPreferences
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getInt('user_id')!;  // Lấy user_id từ SharedPreferences
  }

  @override
  void initState() {
    super.initState();
    _getUserId().then((_) {
      _getUserInfo();  // Gọi API sau khi lấy user_id
    });
  }

  // Lấy thông tin người dùng từ API
  Future<void> _getUserInfo() async {
    try {
      ApiResponse response = await UserController().getItem(user_id);
      if (response.statusCode == 200) {
        print('Dữ liệu người dùng: ${response.body}');
        setState(() {
          _nameController.text = response.body['name'] ?? '';  // Cập nhật giá trị vào controller
          _addressController.text = response.body['address'] ?? '';
          _phoneController.text = response.body['phone'] ?? '';
          _email = response.body['email'] ?? '';  // Cập nhật email
          _password = response.body['password'] ?? '';  // Cập nhật password (nếu cần thiết)
          _role = response.body['role'] ?? '';  // Cập nhật role
        });
      } else {
        _showSnackBar('Không thể lấy dữ liệu người dùng', Colors.red);
      }
    } catch (error) {
      print('Lỗi khi lấy dữ liệu: $error');
      _showSnackBar('Lỗi khi lấy dữ liệu', Colors.red);
    }
  }

  // Hiển thị SnackBar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Constants.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Thay đổi thông tin", style: TextStyle(color: Constants.lightTextColor, fontSize: 20)),
        backgroundColor: Constants.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Các trường nhập liệu cho tên, địa chỉ, số điện thoại
              Text("Tên", style: TextStyle(color: Constants.highlightColor, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController, // Sử dụng controller thay vì initialValue
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Nhập tên mới của bạn"),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên mới của bạn' : null,
                onSaved: (value) => _nameController.text = value!,
              ),
              const SizedBox(height: 20),
              Text("Địa chỉ", style: TextStyle(color: Constants.highlightColor, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController, // Sử dụng controller thay vì initialValue
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Nhập địa chỉ mới của bạn"),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập địa chỉ mới của bạn' : null,
                onSaved: (value) => _addressController.text = value!,
              ),
              const SizedBox(height: 20),
              Text("Số điện thoại", style: TextStyle(color: Constants.highlightColor, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController, // Sử dụng controller thay vì initialValue
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Nhập số điện thoại mới"),
                validator: (value) => value!.isEmpty ? 'Xin vui lòng điền số điện thoại của bạn' : null,
                onSaved: (value) => _phoneController.text = value!,
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        // Gọi hàm update để cập nhật thông tin người dùng
                        var response = await UserController().update(
                          user_id.toString(),
                          _nameController.text,
                          _phoneController.text,
                          _email,
                          _password,
                          _addressController.text,
                          _role,
                        );

                        // Kiểm tra phản hồi từ API
                        if (response.statusCode == 200) {
                          _showSnackBar('Cập nhật thông tin thành công', Colors.green);
                        } else {
                          _showSnackBar('Cập nhật không thành công', Colors.red);
                        }
                      }
                    },
                    child: Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

