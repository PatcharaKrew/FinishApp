import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'ChangePasswordPage.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileData;
  EditProfilePage({
    required this.profileData,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  List<String> provinces = [];
  List<String> districts = [];
  List<String> subdistricts = [];
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSubdistrict;

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.profileData);

    // Initialize the date controller
    _dateController.text = _formData['date_birth'] != null
        ? DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(_formData['date_birth']))
        : '';

    fetchProvinces(); // Fetch provinces when the page is initialized
  }

  String? _validateThaiText(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    final thaiRegex = RegExp(r'^[ก-๙]+$');
    if (!thaiRegex.hasMatch(value)) {
      return 'กรุณากรอกเป็นภาษาไทยเท่านั้น';
    }
    return null;
  }

  String? _validateIdCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกเลขบัตรประชาชน';
    }
    final idCardRegex = RegExp(r'^\d{1}-\d{4}-\d{5}-\d{2}-\d{1}$');
    if (!idCardRegex.hasMatch(value)) {
      return 'รูปแบบเลขบัตรประชาชนไม่ถูกต้อง';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกเบอร์โทร';
    }
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'รูปแบบเบอร์โทรไม่ถูกต้อง';
    }
    return null;
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String? _validateNumberAndSlash(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    final numberAndSlashRegex = RegExp(r'^[0-9/]+$');
    if (!numberAndSlashRegex.hasMatch(value)) {
      return 'กรุณากรอกเฉพาะบ้านเลขที่เท่านั้น';
    }
    return null;
  }

  String? _validateRoad(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    final thaiRegex = RegExp(r'^[ก-๙\-s]+$');
    if (!thaiRegex.hasMatch(value)) {
      return 'กรุณากรอกเป็นภาษาไทยเท่านั้น';
    }
    return null;
  }

  String? _validateNumberOnly(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
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
          selectedProvince = _formData['province'];
          if (selectedProvince != null) {
            fetchDistricts(selectedProvince!);
          }
        });
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
          selectedDistrict = _formData['district'];
          if (selectedDistrict != null) {
            fetchSubdistricts(selectedDistrict!);
          }
        });
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
          selectedSubdistrict = _formData['subdistrict'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถดึงข้อมูลตำบลได้')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _formData['province'] = selectedProvince;
      _formData['district'] = selectedDistrict;
      _formData['subdistrict'] = selectedSubdistrict;

      if (_formData['date_birth'] != null &&
          _formData['date_birth'].isNotEmpty) {
        final date = DateTime.parse(_formData['date_birth']);
        final buddhistYear = date.year + 543;
        _formData['date_birth'] = DateFormat('yyyy-MM-dd')
            .format(DateTime(buddhistYear, date.month, date.day));
      }

      try {
        print(_formData); // Print the data before sending
        final response = await http.put(
          Uri.parse('http://localhost:3000/profile/${_formData['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_formData),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context, _formData); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เเก้ไขโปรไฟล์'),
        backgroundColor: Color(0xFF2A6F97),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDropdownFormField(
                    'title_name', 'คำนำหน้า', ['นาย', 'นาง', 'นางสาว']),
                _buildTextFormField('first_name', 'ชื่อ',
                    validator: _validateThaiText),
                _buildTextFormField('last_name', 'นามสกุล',
                    validator: _validateThaiText),
                _buildTextFormField('id_card', 'เลขบัตรประชาชน',
                    validator: _validateIdCard),
                _buildTextFormField('phone', 'เบอร์โทร',
                    validator: _validatePhone),
                _buildDropdownFormField(
                    'gender', 'เพศ', ['ชาย', 'หญิง', 'อื่นๆ']),
                GestureDetector(
                  onTap: () async {
                    DateTime? initialDate;
                    if (_dateController.text.isNotEmpty) {
                      try {
                        final parts = _dateController.text.split('/');
                        final day = int.parse(parts[0]);
                        final month = int.parse(parts[1]);
                        final year = int.parse(parts[2]) - 543;
                        initialDate = DateTime(year, month, day);
                      } catch (e) {
                        initialDate = DateTime.now();
                      }
                    } else {
                      initialDate = DateTime.now();
                    }

                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate!,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      helpText: 'เลือกวันเกิด', 
                      cancelText: 'ยกเลิก',
                      confirmText: 'ตกลง',
                      locale: Locale('th', 'TH'),
                    );

                    if (selectedDate != null) {
                      setState(() {
                        final buddhistYear = selectedDate.year + 543;
                        _dateController.text = DateFormat('dd/MM/yyyy').format(
                          DateTime(buddhistYear, selectedDate.month,
                              selectedDate.day),
                        );
                        _formData['date_birth'] =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                        _formData['age'] = _calculateAge(selectedDate);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'วันเกิด (วัน/เดือน/ปี)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกวันเกิด';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextFormField('house_number', 'เลขบ้าน',
                    validator: _validateNumberAndSlash),
                _buildTextFormField('street', 'ถนน', validator: _validateRoad),
                _buildTextFormField('village', 'หมู่บ้าน',
                    validator: _validateNumberOnly),
                _buildDropdownFormFieldWithApi(
                  'province',
                  'จังหวัด',
                  provinces,
                  provinces.contains(selectedProvince)
                      ? selectedProvince
                      : null,
                  (value) {
                    setState(() {
                      selectedProvince = value;
                      selectedDistrict = null;
                      selectedSubdistrict = null;
                      fetchDistricts(value!);
                    });
                  },
                ),
                _buildDropdownFormFieldWithApi(
                  'district',
                  'อำเภอ',
                  districts,
                  districts.contains(selectedDistrict)
                      ? selectedDistrict
                      : null,
                  (value) {
                    setState(() {
                      selectedDistrict = value;
                      selectedSubdistrict = null;
                      fetchSubdistricts(value!);
                    });
                  },
                ),
                _buildDropdownFormFieldWithApi(
                  'subdistrict',
                  'ตำบล',
                  subdistricts,
                  subdistricts.contains(selectedSubdistrict)
                      ? selectedSubdistrict
                      : null,
                  (value) {
                    setState(() {
                      selectedSubdistrict = value;
                      _formData['subdistrict'] = value;
                    });
                  },
                ),
                _buildTextFormField('zipcode', 'ไปรษณีย์',
                    validator: _validateNumberOnly),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    int userId = int.parse(_formData['id'].toString());

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangePasswordPage(userId: userId),
                      ),
                    );
                  },
                  child: Text(
                    'แก้ไขรหัสผ่าน',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text(
                    'บันทึกข้อมูลส่วนตัว',
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
      ),
    );
  }

  Widget _buildTextFormField(String key, String label,
      {bool isNumeric = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: _formData[key],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        onChanged: (value) {
          setState(() {
            _formData[key] = value;
          });
        },
        onSaved: (value) {
          _formData[key] = value;
        },
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownFormField(String key, String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _formData[key],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _formData[key] = value;
          });
        },
        onSaved: (value) {
          _formData[key] = value;
        },
      ),
    );
  }

  Widget _buildDropdownFormFieldWithApi(
      String key, String label, List<String> items, String? selectedItem,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'กรุณาเลือก $label' : null,
      ),
    );
  }
}
