import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';
import 'package:food_app/ui/screens/home_page.dart';
import 'package:food_app/ui/screens/root_page.dart';
import 'package:food_app/ui/screens/signin_page.dart';
import 'package:food_app/ui/widget/custom_textfield.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../db/userController.dart';
import '../firebase_auth/firebase_auth_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isSigningUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/signup.png'),
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                controller: _emailController,
                obscureText: false,
                hintText: 'Nhập Email',
                icon: Icons.alternate_email,
              ),
              CustomTextField(
                controller: _nameController,
                obscureText: false,
                hintText: 'Nhập Tên',
                icon: Icons.person,
              ),
              CustomTextField(
                controller: _phoneController,
                obscureText: false,
                hintText: 'Nhập SĐT',
                icon: Icons.phone,
              ),
              CustomTextField(
                controller: _passwordController,
                obscureText: true,
                hintText: 'Nhập mật khẩu',
                icon: Icons.lock,
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: _signUp,
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Constants.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Center(
                    child: isSigningUp
                        ? CircularProgressIndicator(color: Colors.white,)
                        : Text(
                      "Đăng Ký",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: size.width,
                decoration: BoxDecoration(
                  border: Border.all(color: Constants.primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: InkWell(
                  onTap: () async {
                    try {
                      UserCredential userCredential = await signInWithGoogle();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RootPage()));
                    } catch (error) {
                      print('Có lỗi khi đăng nhập với Google: $error');
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 30,
                        child: Image.asset('assets/images/google.png'),
                      ),
                      Text(
                        'Đăng ký với Google',
                        style: TextStyle(
                          color: Constants.textColor,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      child: const SignIn(),
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
                child: Center(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: 'Đã có tài khoản? ',
                        style: TextStyle(
                          color: Constants.textColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Đăng nhập',
                        style: TextStyle(
                          color: Constants.primaryColor,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String name = _nameController.text;
    String phone = _phoneController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      ApiResponse response = await UserController().signUp(name, phone, email, password);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SignIn()),
          );
        } else {
          _showErrorDialog(jsonResponse['message']);
        }
      } else {
        _showErrorDialog('Server error. Please try again later.');
      }
    } catch (error) {
      print(error);
    }

    setState(() {
      isSigningUp = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, get the user information
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      // Send user data to the backend
      await sendUserDataToBackend(user);
    }

    return userCredential;
  }

  Future<void> sendUserDataToBackend(User user) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': user.displayName ?? 'No Name',
        'email': user.email!,
        'password': '',
        'phone': '',
        'address': '',
        'role': 'user',
        'image': user.photoURL ?? '',
        'level': '1',
        'coin': '0'
      }),
    );

    if (response.statusCode == 200) {
      print('User added successfully');
    } else {
      throw Exception('Failed to add user');
    }
  }
}
