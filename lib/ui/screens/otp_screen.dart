
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_app/constants.dart';
import 'package:food_app/ui/screens/updatePassword_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  final String? verificationId;
  OtpScreen({this.verificationId});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();


  Future<void> _submitOtp(BuildContext context) async{
    if (widget.verificationId == null) {
      // Xử lý trường hợp không có verificationId được cung cấp
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification ID is required")),
      );
      return;
    }
    String otp = _otpController.text.trim();
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId!, smsCode: otp);
      await auth.signInWithCredential(credential);
      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePasswordScreen(), ));
    } catch (e) {
      print("Failed to sign in: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign in: ${e.toString()}")));
    }
  }



  @override
  Widget build(BuildContext context) {
    // Defining a green color palette
    const Color PrimaryColor = Color(0xFFC51575);
    const Color AccentColor = Color(0xFFD9A5CB);

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP', style: TextStyle(color: AccentColor)),
        backgroundColor: PrimaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'OTP Verification',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: PrimaryColor),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter the 6-digit code sent to your number',
                style: TextStyle(color: Colors.grey[600], fontSize: 18),
              ),
            ),
            SizedBox(height: 50),
            PinCodeTextField(
              controller: _otpController,
              appContext: context,
              length: 6,
              onChanged: (value) {
                // Handle changes in OTP
              },
              pinTheme: PinTheme(
                activeColor: PrimaryColor,
                selectedColor: AccentColor,
                inactiveColor: Colors.grey[300],
                shape: PinCodeFieldShape.underline,
                fieldHeight: 50,
                fieldWidth: 40,
              ),
              animationType: AnimationType.fade,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autoFocus: true,
            ),
            SizedBox(height: 32),
            InkWell(
              onTap: () => _submitOtp(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  color: Constants.primaryColor, // Replace with your constant color value
                ),
                child: Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}