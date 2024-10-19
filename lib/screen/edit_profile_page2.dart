import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage2 extends StatefulWidget {
  final Map<String, dynamic> healthData;

  EditProfilePage2({required this.healthData});

  @override
  _EditProfilePage2State createState() => _EditProfilePage2State();
}

class _EditProfilePage2State extends State<EditProfilePage2> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.healthData);
  }

  double calculateBMI(double weight, double height) {
    return weight / ((height / 100) * (height / 100));
  }

  double calculateWaistToHeightRatio(double waist, double height) {
    return waist / height;
  }

  void _recalculateHealthMetrics() {
    if (_formData['weight'] != null && _formData['height'] != null) {
      _formData['bmi'] = calculateBMI(
        double.parse(_formData['weight']),
        double.parse(_formData['height']),
      ).toStringAsFixed(2);
    }

    if (_formData['waist'] != null && _formData['height'] != null) {
      _formData['waist_to_height_ratio'] = calculateWaistToHeightRatio(
        double.parse(_formData['waist']),
        double.parse(_formData['height']),
      ).toStringAsFixed(2);
    }
  }

  Future<void> _saveHealthData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _recalculateHealthMetrics();

      try {
        final response = await http.put(
          Uri.parse('http://localhost:3000/profile/${_formData['id']}/health'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_formData),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Health data updated successfully')),
          );
          Navigator.pop(context, _formData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update health data')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating health data: $e')),
        );
      }
    }
  }

  String? _validateNumericInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }
    final numericRegex = RegExp(r'^[0-9]+(\.[0-9]*)?$');
    if (!numericRegex.hasMatch(value)) {
      return 'กรุณากรอกเฉพาะตัวเลขเท่านั้น';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขข้อมูลสุขภาพ'),
        backgroundColor: Color(0xFF2A6F97),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextFormField('weight', 'น้ำหนัก (กิโลกรัม)', isNumeric: true),
                _buildTextFormField('height', 'ส่วนสูง (เซนติเมตร)', isNumeric: true),
                _buildTextFormField('waist', 'รอบเอว (เซนติเมตร)', isNumeric: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveHealthData,
                  child: Text(
                    'บันทึก',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String key, String label, {bool isNumeric = false}) {
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
        validator: isNumeric ? _validateNumericInput : null,
        onChanged: (value) {
          setState(() {
            _formData[key] = value;
            if (key == 'weight' || key == 'height' || key == 'waist') {
              _recalculateHealthMetrics();
            }
          });
        },
        onSaved: (value) {
          _formData[key] = value;
        },
      ),
    );
  }
}
