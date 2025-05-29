import 'package:food_app/db/userController.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';

class RestaurantController {
  //getAll
  Future<ApiResponse> getTop() async {
    var url = Uri.parse('${Config.baseUrl}/restaurants/order-by-rate/');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var jsonResponse = utf8.decode(response.bodyBytes);
    var parsedJson = jsonDecode(jsonResponse);

    ApiResponse apiResponse = ApiResponse(response.statusCode, parsedJson);
    return apiResponse;
  }

  Future<ApiResponse> getItem(int id) async {
    var url = Uri.parse('${Config.baseUrl}/restaurant/getItem/${id}');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    var jsonResponse = utf8.decode(response.bodyBytes);
    var parsedJson = jsonDecode(jsonResponse);

    ApiResponse apiResponse = ApiResponse(response.statusCode, parsedJson);
    return apiResponse;
  }
}