import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordPage extends StatefulWidget {
  final int userId;

  ChangePasswordPage({required this.userId});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.put(
          Uri.parse('http://localhost:3000/change-password/${widget.userId}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: jsonEncode({'new_password': _newPasswordController.text}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password updated successfully')),
          );
          Navigator.pop(context); // กลับไปยังหน้าโปรไฟล์
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update password')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating password: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขรหัสผ่าน'),
        backgroundColor: Color(0xFF2A6F97),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'รหัสผ่านใหม่'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรหัสผ่านใหม่';
                  }
                  // ตรวจสอบว่ารหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร
                  if (value.length < 6) {
                    return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                  }
                  // ตรวจสอบว่ามีตัวอักษรภาษาอังกฤษ (ตัวเล็กหรือตัวใหญ่) และตัวเลขเท่านั้น
                  final regex = RegExp(r'^[a-zA-Z0-9]+$');
                  if (!regex.hasMatch(value)) {
                    return 'รหัสผ่านต้องเป็นภาษาอังกฤษหรือตัวเลขเท่านั้น';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'ยืนยันรหัสผ่าน'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณายืนยันรหัสผ่าน';
                  }
                  if (value != _newPasswordController.text) {
                    return 'รหัสผ่านไม่ตรงกัน';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text(
                  'บันทึกรหัสผ่านใหม่',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  backgroundColor: Color(0xFF2A6F97),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
