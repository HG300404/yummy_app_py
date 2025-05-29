import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class ApiResponse {
  final int statusCode;
  final dynamic body;

  ApiResponse(this.statusCode, this.body);
}

class UserController {
  // login
  Future<ApiResponse> signIn(String email, String password) async {
    var url = Uri.parse('${Config.baseUrl}/login');
    var body = jsonEncode(<String, String>{
      'email': email,
      'password': password,
    });

    print("Sending: $body");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }

  // register
  Future<ApiResponse> signUp(String name, String phone, String email, String password) async {
    var url = Uri.parse('${Config.baseUrl}/register');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'role': 'user',
      }),
    );

    ApiResponse apiResponse = ApiResponse(response.statusCode, response.body);
    return apiResponse;
  }

  // getItem
  Future<ApiResponse> getItem(int id) async {
    var url = Uri.parse('${Config.baseUrl}/user/getUser/$id');
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


  //update
  Future<ApiResponse> update(String id, String name, String phone, String email, String password, String address, String role) async {

    print(id + " - " + name + "-" + phone + "-" + email + "-" + password + "-" + address + "-" + role);
    var url = Uri.parse('${Config.baseUrl}/user/update/$id'); // điều chỉnh URL cho phù hợp
    var body = jsonEncode(<String, String>{
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'address': address,
      'role': role,
    });

    var response = await http.put( // sử dụng phương thức put
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    var jsonResponse = utf8.decode(response.bodyBytes);
    var parsedJson = jsonDecode(jsonResponse);

    ApiResponse apiResponse = ApiResponse(response.statusCode, parsedJson);
    return apiResponse;
  }

}
