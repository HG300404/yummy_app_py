import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';

class CustomTextField extends StatelessWidget {
  final IconData icon;
  final bool obscureText;
  final String hintText;
  final TextEditingController? controller;

  const CustomTextField({
    Key? key,
    required this.icon,
    required this.obscureText,
    required this.hintText,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: Constants.textColor,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(
          icon,
          color: Constants.textColor.withOpacity(.3),
        ),
        hintText: hintText,
      ),
      cursorColor: Constants.textColor.withOpacity(.5),
    );
  }
}