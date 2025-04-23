import 'package:flutter/material.dart';
import 'package:food_app/ui/screens/home_page.dart';
import 'package:food_app/ui/screens/orderScreen.dart';
import 'package:food_app/ui/widget/common_widget/round_button.dart';

import '../../constants.dart';

class CheckoutMessageView extends StatefulWidget {
  const CheckoutMessageView({Key? key});

  @override
  State<CheckoutMessageView> createState() => _CheckoutMessageViewState();
}

class _CheckoutMessageViewState extends State<CheckoutMessageView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      width: media.width,
      decoration: BoxDecoration(
          color: Constants.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Constants.lightTextColor,
                  size: 25,
                ),
              )
            ],
          ),
          Image.asset(
            "assets/images/thankyou.png",
            width: media.width * 0.55,
          ),
          const SizedBox(
            height: 25,
          ),
          Text(
            "Cảm ơn bạn",
            style: TextStyle(
                color: Constants.lightTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 25,
          ),
          Text(
            "Đơn hàng của bạn đang được xử lý. Chúng tôi sẽ thông báo cho bạn khi đơn hàng được lấy từ cửa hàng. Kiểm tra trạng thái của đơn hàng của bạn",
            textAlign: TextAlign.center,
            style: TextStyle(color: Constants.lightTextColor, fontSize: 14),
          ),
          const SizedBox(
            height: 35,
          ),
          RoundButton(title: "Theo Dõi Đơn Hàng", onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrderScreen()),
            );
          }),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text(
                "Quay lại Trang Chủ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Constants.lightTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}
