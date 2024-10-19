import 'package:final_login/constants/color.dart';
import 'package:final_login/screen/register_page4.dart';
import 'package:flutter/material.dart';

class RegisterPage3 extends StatefulWidget {
  final Map<String, dynamic> patientData;

  RegisterPage3({required this.patientData});

  @override
  State<RegisterPage3> createState() => _RegisterPage3State();
}

class _RegisterPage3State extends State<RegisterPage3> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? _bmi;
  double? _waistToHeightRatio;

  void _calculateMetrics() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final waist = double.tryParse(_waistController.text);

    if (weight != null && height != null) {
      setState(() {
        _bmi = weight / ((height / 100) * (height / 100));
      });
    }

    if (waist != null && height != null) {
      setState(() {
        _waistToHeightRatio = waist / height;
      });
    }
  }

  String? _validateNumberOnly(String? value) {
    if (value == null || value.isEmpty) {
      return null;  // Allow empty value
    }
    final numberOnlyRegex = RegExp(r'^[0-9]+$');
    if (!numberOnlyRegex.hasMatch(value)) {
      return 'กรุณากรอกเฉพาะตัวเลขเท่านั้น';
    }
    return null;
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      _calculateMetrics();

      widget.patientData.addAll({
        'weight': _weightController.text.isNotEmpty ? _weightController.text : null,
        'height': _heightController.text.isNotEmpty ? _heightController.text : null,
        'waist': _waistController.text.isNotEmpty ? _waistController.text : null,
        'bmi': _bmi,
        'waist_to_height_ratio': _waistToHeightRatio,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage4(patientData: widget.patientData),
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
              bottom: -130,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/waveback.png',
                fit: BoxFit.cover,
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
                        'ข้อมูลสุขภาพ',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: textColor1,
                        ),
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: 'น้ำหนัก (กิโลกรัม)',
                          labelStyle: TextStyle(color: borderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateNumberOnly,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _heightController,
                        decoration: InputDecoration(
                          labelText: 'ส่วนสูง (เซนติเมตร)',
                          labelStyle: TextStyle(color: borderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateNumberOnly,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _waistController,
                        decoration: InputDecoration(
                          labelText: 'รอบเอว (เซนติเมตร)',
                          labelStyle: TextStyle(color: borderColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateNumberOnly,
                      ),
                      SizedBox(height: 16,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('สามารถกดถัดไปเพื่อข้ามได้',style: TextStyle(fontSize: 18,color: Colors.white),),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          backgroundColor: secondaryButtonColor,
                          elevation: 10,
                          shadowColor: Color.fromARGB(255, 0, 28, 52).withOpacity(0.9),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          backgroundColor: textColor1,
                          elevation: 10,
                          shadowColor: Color.fromARGB(255, 0, 28, 52).withOpacity(0.9),
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
