import 'dart:convert';
import 'package:final_login/constants/color.dart';
import 'package:final_login/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'register_page2.dart';

class RegisterPage1 extends StatefulWidget {
  const RegisterPage1({super.key});

  @override
  State<RegisterPage1> createState() => _RegisterPage1State();
}

class _RegisterPage1State extends State<RegisterPage1> {
  final TextEditingController _titleNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Map<String, dynamic> _patientData = {};
  String selectedTitle = 'นาย';
  String selectedGender = 'ชาย';
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  String _convertToBuddhistYear(DateTime date) {
    final buddhistCalendarYear = date.year + 543;
    return '${buddhistCalendarYear}-${DateFormat('MM-dd').format(date)}';
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

  Future<void> _selectDate() async {
    DateTime? initialDate = _selectedDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
        _selectedDate = selectedDate;
        _patientData['date_birth'] =
            DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  String formatIdCard(String idCard) {
    return idCard.replaceAll('-', '');
  }

  String formatPhone(String phone) {
    return phone.replaceAll('-', '');
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

  void _next() {
    if (_formKey.currentState!.validate()) {
      int age = _calculateAge(_selectedDate);
      _patientData.addAll({
        'title_name': selectedTitle,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'id_card': formatIdCard(_idCardController.text),
        'phone': formatPhone(_phoneController.text),
        'gender': selectedGender,
        'date_birth': _convertToBuddhistYear(_selectedDate),
        'age': age,
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage2(patientData: _patientData),
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
                        'สมัครสมาชิก',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: textColor1,
                        ),
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: selectedTitle,
                              items:
                                  ['นาย', 'นาง', 'นางสาว'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedTitle = value!;
                                });
                              },
                              onSaved: (value) =>
                                  _patientData['title_name'] = value,
                              decoration: InputDecoration(
                                labelText: 'คำนำหน้า',
                                labelStyle: TextStyle(color: borderColor),
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
                              validator: (value) =>
                                  value == null ? 'กรุณาเลือกคำนำหน้า' : null,
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'ชื่อ',
                                labelStyle: TextStyle(color: borderColor),
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
                              onSaved: (value) =>
                                  _patientData['first_name'] = value,
                              validator:
                                  _validateThaiText, // เรียกใช้ฟังก์ชันนี้เพื่อทำการตรวจสอบ
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'นามสกุล',
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
                        onSaved: (value) => _patientData['last_name'] = value,
                        validator:
                            _validateThaiText, // เรียกใช้ฟังก์ชันนี้เพื่อทำการตรวจสอบ
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _idCardController,
                        decoration: InputDecoration(
                          labelText: 'เลขบัตรประชาชน',
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
                        validator: _validateIdCard,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            String newText = newValue.text.replaceAllMapped(
                              RegExp(r'(\d{1})(\d{4})(\d{5})(\d{2})(\d{1})'),
                              (Match m) =>
                                  '${m[1]}-${m[2]}-${m[3]}-${m[4]}-${m[5]}',
                            );
                            return newValue.copyWith(
                              text: newText,
                              selection: TextSelection.collapsed(
                                  offset: newText.length),
                            );
                          }),
                        ],
                        onSaved: (value) =>
                            _patientData['id_card'] = formatIdCard(value!),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'เบอร์โทร',
                                labelStyle: TextStyle(color: borderColor),
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
                              onSaved: (value) =>
                                  _patientData['phone'] = formatPhone(value!),
                              validator: _validatePhone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  String newText =
                                      newValue.text.replaceAllMapped(
                                    RegExp(r'(\d{3})(\d{3})(\d{4})'),
                                    (Match m) => '${m[1]}-${m[2]}-${m[3]}',
                                  );
                                  return newValue.copyWith(
                                    text: newText,
                                    selection: TextSelection.collapsed(
                                        offset: newText.length),
                                  );
                                }),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                                value: selectedGender,
                                items: ['ชาย', 'หญิง'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'เพศ',
                                  labelStyle: TextStyle(color: borderColor),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 1),
                                  ),
                                ),
                                onSaved: (value) =>
                                    _patientData['gender'] = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณาเลือกเพศ';
                                  }
                                  return null;
                                }),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'วันเกิด: ${DateFormat('dd/MM/yyyy').format(DateTime(_selectedDate.year + 543, _selectedDate.month, _selectedDate.day))}',
                                style:
                                    TextStyle(fontSize: 16, color: borderColor),
                              ),
                              Icon(Icons.calendar_today, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
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

class DatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  DatePickerWidget({required this.initialDate, required this.onDateSelected});

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year + 543;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'เลือกวันที่',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedYear,
                  items: List.generate(100, (index) {
                    final year = DateTime.now().year + 543 - index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text('$year'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value!;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  items: List.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem(
                      value: month,
                      child: Text('${month.toString().padLeft(2, '0')}'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value!;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedDay,
                  items: List.generate(31, (index) {
                    final day = index + 1;
                    return DropdownMenuItem(
                      value: day,
                      child: Text('${day.toString().padLeft(2, '0')}'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final selectedDate = _convertToGregorian(
                _selectedYear,
                _selectedMonth,
                _selectedDay,
              );
              widget.onDateSelected(selectedDate);
              Navigator.pop(context);
            },
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  DateTime _convertToGregorian(int buddhistYear, int month, int day) {
    return DateTime(buddhistYear - 543, month, day);
  }
}
