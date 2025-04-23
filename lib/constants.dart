import 'package:flutter/material.dart';

class Constants {
  // Màu chính hồng pastel
  static var primaryColor = const Color(0xFFC51575); // Hồng pastel nhẹ

// Màu nền sáng
  static var backgroundColor = const Color(0xFFF8F4F4); // Một màu trắng ngà/nhạt hơn để không làm lu mờ màu chính

  static var backgroundTable = const Color(0xFFE8E6E6);

// Màu văn bản chính - Đậm hơn nhưng không quá chói lọi
  static var textColor = const Color(0xFF3A3633); // Một màu nâu đậm nhạt hoặc xám đậm

// Màu phụ (sẫm hơn một chút, dùng để tạo độ tương phản hoặc làm màu hightlight)
  static var accentColor = const Color(0xFFD77CC0); // Màu hồng sẫm pastel

// Màu tương phản để nhấn mạnh các thành phần tiêu đề hoặc button
  static var highlightColor = const Color(0xFFB6A5AF); // Màu hồng nâu pastel

// Màu văn bản cho những thông tin không quan trọng lắm
  static var lightTextColor = const Color(0xFF7F7C7E); // Màu xám nhạt

  static Color get white => const Color(0xffffffff);

  static Color get textfield => const Color(0xffF2F2F2);

  //Onboarding texts
  static var titleOne = "Thiên đường ẩm thực cùng với Yummy Food";
  static var descriptionOne = "Chọn hàng ngàn món ăn đặc sắc, đặt trong tích tắc và thưởng thức món ngon mọi lúc, mọi nơi.";
  static var titleTwo = "Giao hàng siêu tốc, niềm vui không giới hạn!";
  static var descriptionTwo = "Với Yummy Food, đồ ăn yêu thích của bạn sẽ đến nhanh như chớp, chất lượng tuyệt hảo";
  static var titleThree = "Chọn lựa dễ dàng, tiện lợi mọi lúc";
  static var descriptionThree = "Tìm món ăn theo sở thích chỉ với vài thao tác, mọi thời điểm, mọi nơi.";
}