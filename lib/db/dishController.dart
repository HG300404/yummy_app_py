import 'package:food_app/db/userController.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';

class DishController {
  //getAll
  Future<ApiResponse> getTop() async {
    var url = Uri.parse('${Config.baseUrl}/dish/getAllHome');
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

  Future<ApiResponse> getRecent() async {
    var url = Uri.parse('${Config.baseUrl}/dish/getRecent');
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

  //get list by type
  Future<ApiResponse> search(String type, int res_id) async {
    var url = Uri.parse('${Config.baseUrl}/dish/search/${type}/${res_id}');
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

  // search dish
  Future<ApiResponse> searchDish(String input) async {
    var url = Uri.parse('http://10.0.2.2:8000/api/dish/searchDish/${input}');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }

}