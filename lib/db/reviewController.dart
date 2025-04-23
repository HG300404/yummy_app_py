import 'dart:ffi';

import 'package:food_app/db/userController.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';

class ReviewController {

  //add
  Future<ApiResponse> create(String user_id, String restaurant_id, String rating, String order_id, String comment) async {
    print(user_id + "-" + restaurant_id + "-" + rating + "-" + order_id + "-" + comment);
    var url = Uri.parse('${Config.baseUrl}/comment/create');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': user_id,
        'restaurant_id': restaurant_id,
        'rating': rating,
        'order_id': order_id,
        'comment': comment,
      }),
    );
    var jsonResponse = utf8.decode(response.bodyBytes);
    var parsedJson = jsonDecode(jsonResponse);

    ApiResponse apiResponse = ApiResponse(response.statusCode, parsedJson);
    return apiResponse;
  }

  //getAll
  Future<ApiResponse> getItem(int order_id) async {
    var url = Uri.parse('${Config.baseUrl}/comment/getItemByOrder/${order_id}');
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

  //Put
  Future<ApiResponse> update(int user_id, int item_id, int restaurant_id, int quantity) async {
    var url = Uri.parse('${Config.baseUrl}/cart/update');
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'user_id': user_id,
        'item_id': item_id,
        'restaurant_id': restaurant_id,
        'quantity': quantity,
      }),
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }
}