import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app/config.dart';
import 'package:food_app/db/userController.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderController {
  //add
  Future<ApiResponse> createOrder(int user_id, int restaurant_id, int price, int ship, int discount, int total_amount, int payment) async {
    print("order ${user_id} - ${restaurant_id} - ${price} - ${ship} - ${discount} - ${total_amount} - ${payment}");
    var url = Uri.parse('${Config.baseUrl}/order/create');

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'user_id': user_id,
        'restaurant_id': restaurant_id,
        'price': price,
        'ship': ship,
        'discount': discount,
        'total_amount': total_amount,
        'payment': payment,
      }),
    );
    var jsonResponse = utf8.decode(response.bodyBytes);
    var parsedJson = jsonDecode(jsonResponse);

    ApiResponse apiResponse = ApiResponse(response.statusCode, parsedJson);

    return apiResponse;
  }

  //add
  Future<ApiResponse> createOrderItem(String order_id, String user_id, String restaurant_id, String option) async {
    print("order item ${order_id} - ${user_id} - ${restaurant_id} - ${option}");
    var url = Uri.parse('${Config.baseUrl}/orderItems/create');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': user_id,
        'restaurant_id': restaurant_id,
        'order_id': order_id,
        'option': option,
      }),
    );
    var jsonResponse = utf8.decode(response.bodyBytes);
    var parsedJson = jsonDecode(jsonResponse);

    ApiResponse apiResponse = ApiResponse(response.statusCode, parsedJson);
    return apiResponse;
  }


  //getAllByUser
  Future<ApiResponse> getAll(int user_id) async {
    var url = Uri.parse('${Config.baseUrl}/order/getItems/${user_id}');
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

  //getAllByOrder_id
  Future<ApiResponse> getAllByOrder(int order_id) async {
    var url = Uri.parse('${Config.baseUrl}/orderItems/getAll/${order_id}');
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

  //getItemByOrder_id
  Future<ApiResponse> getItemByOrder(int order_id) async {
    var url = Uri.parse('${Config.baseUrl}/order/getItem/${order_id}');
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