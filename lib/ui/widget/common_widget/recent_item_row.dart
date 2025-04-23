import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';

import '../common/color_extension.dart';

class RecentItemRow extends StatelessWidget {
  final Map rObj;
  final VoidCallback onTap;
  const RecentItemRow({super.key, required this.rObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prefix = 'data:image/jpeg;base64,';
    Uint8List? bytes;
    if (rObj["img"] != null && rObj["img"].startsWith(prefix)) {
      final String base64Image = rObj["img"].substring(prefix.length);
      try {
        bytes = base64Decode(base64Image);
      } catch (e) {
        bytes = null;
        print("Unable to decode base64 string: $e");
      }
    } else {
      bytes = null;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      bytes,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    "assets/images/image.png",
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rObj["name"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Constants.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        rObj["type"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: TColor.secondaryText, fontSize: 11),
                      ),
                      Text(
                        " . ",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Constants.primaryColor, fontSize: 11),
                      ),
                      Text(
                        "${rObj["price"]}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: TColor.secondaryText, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/rate.png",
                        width: 10,
                        height: 10,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        rObj["restaurant_name"],
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Constants.primaryColor, fontSize: 11),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        "(${rObj["rate"]} Ratings)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: TColor.secondaryText, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
