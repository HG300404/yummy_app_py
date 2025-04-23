import 'dart:ffi';

import 'package:food_app/config.dart';
import 'package:food_app/db/userController.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartController {

  //add
  Future<ApiResponse> addCart(int user_id, int restaurant_id, int item_id, int quantity) async {
    var url = Uri.parse('${Config.baseUrl}/cart/create');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'user_id': user_id,
        'restaurant_id': restaurant_id,
        'item_id': item_id,
        'quantity': quantity,
      }),
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }

  //getAll
  Future<ApiResponse> getAll(int user_id, int restaurant_id) async {
    var url = Uri.parse('${Config.baseUrl}/cart/getAll/${user_id}/${restaurant_id}');
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

    var jsonResponse = utf8.decode(response.bodyBytes);
    var parsedJson = jsonDecode(jsonResponse);

    ApiResponse apiResponse = ApiResponse(response.statusCode, parsedJson);
    return apiResponse;
  }

  //Delete
  Future<ApiResponse> delete(int user_id, int item_id, int restaurant_id) async {
    var url = Uri.parse('${Config.baseUrl}/cart/delete/${user_id}/${restaurant_id}/${item_id}');
    var response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }


  //getAll
  Future<ApiResponse> getAllByUser(int user_id) async {
    var url = Uri.parse('${Config.baseUrl}/cart/getAllByUser/${user_id}');
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