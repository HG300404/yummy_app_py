import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';
import 'package:intl/intl.dart';

import '../common/color_extension.dart';

class MostPopularCell extends StatelessWidget {
  final Map mObj;
  final VoidCallback onTap;

  const MostPopularCell({super.key, required this.mObj, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final prefix = 'data:image/jpeg;base64,';
    Uint8List? bytes;
    if (mObj["img"] != null && mObj["img"].startsWith(prefix)) {
      final String base64Image = mObj["img"].substring(prefix.length);
      bytes = base64Decode(base64Image);
    } else {
      bytes = null;
    }
    // Định dạng giá trị
    String formatPrice(int price) {
      final formatter = NumberFormat("#,##0", "vi_VN");
      return "${formatter.format(price)}đ"; // Trả về giá dưới dạng "20.000đ"
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bytes != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(bytes,  width: 220,
                  height: 130,
                  fit: BoxFit.cover,),
            )
                : CircularProgressIndicator(),
            const SizedBox(
              height: 8,
            ),
            Text(
              mObj["name"],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  mObj["restaurant__name"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 12),
                ),

                Text(
                " . ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Constants.primaryColor, fontSize: 12),
                ),

                Text(
                  mObj["type"],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.secondaryText, fontSize: 12),
                ),

                const SizedBox(
                  width: 8,
                ),
            
                Image.asset(
                "assets/images/rate.png",
                width: 10,
                height: 10,
                fit: BoxFit.cover,
              ) ,
              const SizedBox(
                  width: 4,
                ),
                Text(
                  "${mObj["rate"].toString()}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Constants.primaryColor, fontSize: 12),
                ),
                Text(
                  " . ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Constants.primaryColor, fontSize: 12),
                ),
                Text(
                  formatPrice(mObj["price"]),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Constants.primaryColor, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
