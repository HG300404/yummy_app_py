import 'package:firebase_core/firebase_core.dart';
import 'package:food_app/ui/screens/detail_dish_page.dart';
import 'package:food_app/ui/screens/home_page.dart';
import 'package:food_app/ui/screens/my_order_view.dart';
import 'package:food_app/ui/screens/root_page.dart';
import 'package:food_app/ui/screens/signin_page.dart';
import 'package:food_app/ui/screens/updatePassword_screen.dart';
import 'package:food_app/ui/screens/orderScreen.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food_app/onboarding_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        title: 'Onboarding Screen',
        home: OnboardingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}