import 'package:auto_route/auto_route.dart';
import 'package:final_login/constants/color.dart';
import 'package:final_login/router/routes.gr.dart';
import 'package:final_login/screen/homeDevice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

@RoutePage()
class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idCardOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'id_card_or_phone': _idCardOrPhoneController.text.replaceAll('-', ''),
          'password': _passwordController.text,
        }),
      );

      // Log the status code for debugging purposes
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response body
        final userData = jsonDecode(response.body);
        
        // Log userData to check if the parsing is correct
        print('User Data: $userData');
        
        String userName = "${userData['title_name']} ${userData['first_name']} ${userData['last_name']}";
        int userId = int.parse(userData['id']);

        // Navigate to the next page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeDevicePage(
              userId: userId,
              userName: userName,
            ),
          ),
        );
      } else {
        // Show error if status code is not 200
        final errorMessage = jsonDecode(response.body)['message'];
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      // Handle any errors during the request
      print('Error during login: $e');
      _showErrorDialog('เกิดข้อผิดพลาดในการเข้าสู่ระบบ กรุณาลองใหม่อีกครั้ง');
    }
  }
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

  String? _validateIdCardOrPhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'กรุณากรอกรหัสบัตรประชาชนหรือหมายเลขโทรศัพท์';
  }

  final idCardRegex = RegExp(r'^\d{1}-\d{4}-\d{5}-\d{2}-\d{1}$');
  final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');

  if (!idCardRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
    return 'รหัสบัตรประชาชนหรือหมายเลขโทรศัพท์ไม่ถูกต้อง';
  }

  return null;
}
  String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'กรุณากรอกรหัสผ่าน';
  }

  // ตรวจสอบความยาวขั้นต่ำ 6 ตัวอักษร
  if (value.length < 6) {
    return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
  }

  // ตรวจสอบว่ามีเฉพาะตัวเลขและตัวอักษรภาษาอังกฤษ
  final passwordRegex = RegExp(r'^[a-zA-Z0-9]+$');
  if (!passwordRegex.hasMatch(value)) {
    return 'รหัสผ่านต้องประกอบด้วยตัวเลขและตัวอักษรภาษาอังกฤษเท่านั้น';
  }

  return null;
}

  void _formatIdCardOrPhone() {
  String text = _idCardOrPhoneController.text.replaceAll('-', '');
  if (text.length == 10) {
    if (text.length > 3) {
      text = text.substring(0, 3) + '-' + text.substring(3);
    }
    if (text.length > 7) {
      text = text.substring(0, 7) + '-' + text.substring(7);
    }
    _idCardOrPhoneController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  } else {
    if (text.length > 1) {
      text = text.substring(0, 1) + '-' + text.substring(1);
    }
    if (text.length > 6) {
      text = text.substring(0, 6) + '-' + text.substring(6);
    }
    if (text.length > 12) {
      text = text.substring(0, 12) + '-' + text.substring(12);
    }
    if (text.length > 15) {
      text = text.substring(0, 15) + '-' + text.substring(15);
    }
    _idCardOrPhoneController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: -130, // Set the position at the bottom of the screen
              left: 0, // Align it to the left edge
              right: 0, // Align it to the right edge
              child: Image.asset(
                'assets/images/waveback.png',
                fit: BoxFit.cover, // Keep the image's size intact
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundGradientStart.withOpacity(0.9),
                    backgroundGradientEnd.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 80),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10.0,
                                  spreadRadius: 5.0,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 4,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 115,
                              backgroundImage:
                                  AssetImage('assets/images/logor.png'),
                            ),
                          ),
                          SizedBox(height: 30),
                          const Text('เข้าสู่ระบบ',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFF59D))),
                          SizedBox(height: 25),
                          TextFormField(
                            controller: _idCardOrPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'รหัสบัตรประชาชน/เบอร์โทรศัพท์',
                              labelStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.white30,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1),
                              ),
                            ),
                            validator: _validateIdCardOrPhone,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(17),
                            ],
                            onChanged: (value) {
                              _formatIdCardOrPhone();
                            },
                          ),
                          SizedBox(height: 25),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'รหัสผ่าน',
                              labelStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.white30,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleVisibility,
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: _login,
                            child: Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 20),
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              backgroundColor: buttonColor,
                              foregroundColor: Color(0xFF2A6F97),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('ยังไม่มีสมาชิก?',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                TextButton(
                                  onPressed: () {
                                    context.router.push(RegisterRoute());
                                  },
                                  child: Text('คลิกที่นี่',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellowAccent)),
                                ),
                              ])
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}