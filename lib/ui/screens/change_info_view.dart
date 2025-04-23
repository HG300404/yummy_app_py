import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';

class ChangeInfoView extends StatefulWidget {
  const ChangeInfoView({super.key});

  @override
  State<ChangeInfoView> createState() => _ChangeInfoViewState();
}

class _ChangeInfoViewState extends State<ChangeInfoView> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  String _phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Constants.primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Thay đổi thông tin",
          style: TextStyle(color: Constants.lightTextColor, fontSize: 20),
        ),
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
              Text(
                "Tên",
                style: TextStyle(
                  color: Constants.highlightColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Nhập tên mới của bạn",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên mới của bạn';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Địa chỉ",
                style: TextStyle(
                  color: Constants.highlightColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Nhập địa chỉ mới của bạn",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ mới của bạn';
                  }
                  return null;
                },
                onSaved: (value) {
                  _address = value!;
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Số điện thoại",
                style: TextStyle(
                  color: Constants.highlightColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Nhập số điện thoại mới",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Xin vui lòng điền số điện thoại của bạn';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phone = value!;
                },
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.pop(context, {
                          'name': _name,
                          'address': _address,
                          'phone': _phone,
                        });
                      }
                    },
                    child: Text(
                      "Lưu thay đổi",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
