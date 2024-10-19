import 'dart:convert';
import 'package:final_login/constants/color.dart';
import 'package:final_login/screen/register_page3.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage2 extends StatefulWidget {
  final Map<String, dynamic> patientData;

  RegisterPage2({required this.patientData});

  @override
  State<RegisterPage2> createState() => _RegisterPage2State();
}

class _RegisterPage2State extends State<RegisterPage2> {
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> provinces = [];
  List<String> districts = [];
  List<String> subdistricts = [];

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSubdistrict;
  String? zipcode;
  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  String? _validateThaiText(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    final thaiRegex = RegExp(r'^[ก-๙\-s]+$');
    if (!thaiRegex.hasMatch(value)) {
      return 'กรุณากรอกเป็นภาษาไทยเท่านั้น';
    }
    return null;
  }

  String? _validateNumberAndSlash(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    // กำหนดรูปแบบ Regular Expression ให้ตรวจสอบเฉพาะตัวเลขและเครื่องหมาย /
    final numberAndSlashRegex = RegExp(r'^[0-9/]+$');
    if (!numberAndSlashRegex.hasMatch(value)) {
      return 'กรุณากรอกเฉพาะบ้านเลขที่เท่านั้น';
    }
    return null;
  }

  String? _validateNumberOnly(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    // กำหนดรูปแบบ Regular Expression ให้ตรวจสอบเฉพาะตัวเลขเท่านั้น
    final numberOnlyRegex = RegExp(r'^[0-9-]+$');
    if (!numberOnlyRegex.hasMatch(value)) {
      return 'กรุณากรอกเฉพาะตัวเลขเท่านั้น';
    }
    return null;
  }

  Future<void> fetchProvinces() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/provinces'));
      if (response.statusCode == 200) {
        setState(() {
          provinces = List<String>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load provinces');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลจังหวัดได้')),
      );
    }
  }

  Future<void> fetchDistricts(String province) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/districts/$province'));
      if (response.statusCode == 200) {
        setState(() {
          districts = List<String>.from(json.decode(response.body));
          selectedDistrict = null;
          selectedSubdistrict = null;
          subdistricts = [];
        });
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลอำเภอได้')),
      );
    }
  }

  Future<void> fetchSubdistricts(String district) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/subdistricts/$district'));
      if (response.statusCode == 200) {
        setState(() {
          subdistricts = List<String>.from(json.decode(response.body));
          selectedSubdistrict = null;
        });
      } else {
        throw Exception('Failed to load subdistricts');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลตำบลได้')),
      );
    }
  }

  Future<void> fetchZipcode() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/zipcode?province=$selectedProvince&district=$selectedDistrict&subdistrict=$selectedSubdistrict'));
      if (response.statusCode == 200) {
        setState(() {
          zipcode = json.decode(response.body)['zipcode'].toString();
        });
      } else {
        throw Exception('Failed to load zipcode');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลรหัสไปรษณีย์ได้')),
      );
    }
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      widget.patientData.addAll({
        'house_number': _houseNumberController.text,
        'street': _streetController.text,
        'village': _villageController.text,
        'subdistrict': selectedSubdistrict,
        'district': selectedDistrict,
        'province': selectedProvince,
        'zipcode': zipcode,
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage3(patientData: widget.patientData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 80),
                      Text(
                        'ที่อยู่',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: textColor1,
                        ),
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        controller: _houseNumberController,
                        decoration: InputDecoration(
                          labelText: 'บ้านเลขที่',
                          labelStyle: TextStyle(color: borderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        validator: _validateNumberAndSlash,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _streetController,
                        decoration: InputDecoration(
                          labelText: 'ถนน',
                          labelStyle: TextStyle(color: borderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        validator: _validateThaiText,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _villageController,
                        decoration: InputDecoration(
                          labelText: 'หมู่',
                          labelStyle: TextStyle(color: borderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        validator: _validateNumberOnly,
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'จังหวัด',
                          labelStyle: TextStyle(color: borderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        value: selectedProvince,
                        items: provinces.map((province) {
                          return DropdownMenuItem(
                            value: province,
                            child: Text(province),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProvince = value;
                            fetchDistricts(value!);
                          });
                        },
                        validator: (value) =>
                            value == null ? 'กรุณาเลือกจังหวัด' : null,
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'อำเภอ',
                          labelStyle: TextStyle(color: borderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        value: selectedDistrict,
                        items: districts.map((district) {
                          return DropdownMenuItem(
                            value: district,
                            child: Text(district),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDistrict = value;
                            fetchSubdistricts(value!);
                          });
                        },
                        validator: (value) =>
                            value == null ? 'กรุณาเลือกอำเภอ' : null,
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'ตำบล',
                          labelStyle: TextStyle(color: borderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        value: selectedSubdistrict,
                        items: subdistricts.map((subdistrict) {
                          return DropdownMenuItem(
                            value: subdistrict,
                            child: Text(subdistrict),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSubdistrict = value;
                            fetchZipcode(); // ดึงข้อมูลรหัสไปรษณีย์เมื่อเลือกตำบล
                          });
                        },
                        validator: (value) =>
                            value == null ? 'กรุณาเลือกตำบล' : null,
                      ),

                      // ฟิลด์แสดงรหัสไปรษณีย์
                      SizedBox(height: 20), 
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'รหัสไปรษณีย์',
                          labelStyle: TextStyle(color: borderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        controller: TextEditingController(
                          text: zipcode != null ? zipcode! : '-',
                        ), // กำหนดค่าจากตัวแปร zipcode
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'กลับไปก่อนหน้า',
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
                          backgroundColor: secondaryButtonColor,
                          elevation: 10,
                          shadowColor:
                              Color.fromARGB(255, 0, 28, 52).withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _next,
                        child: Text(
                          'ถัดไป',
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
                          elevation: 10,
                          shadowColor:
                              Color.fromARGB(255, 0, 28, 52).withOpacity(0.9),
                        ),
                      ),
                    ],
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
