import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:final_login/constants/color.dart';
import 'package:intl/intl.dart';

class CompletedAppointment {
  final int id;
  final String title;
  final String date;

  CompletedAppointment({
    required this.id,
    required this.title,
    required this.date,
  });

  static CompletedAppointment fromJson(Map<String, dynamic> json) {
    DateTime parsedDate =
        DateTime.parse(json['appointment_date']).toUtc().toLocal();

    String formattedDate =
        DateFormat('EEEE dd MMMM yyyy', 'th_TH').format(parsedDate);

    return CompletedAppointment(
      id: json['id'],
      title: json['program_name'],
      date: formattedDate,
    );
  }
}

class CompletedAppointments extends StatefulWidget {
  final int userId;

  CompletedAppointments({required this.userId});

  @override
  _CompletedAppointmentsState createState() => _CompletedAppointmentsState();
}

class _CompletedAppointmentsState extends State<CompletedAppointments> {
  List<CompletedAppointment> completedAppointments = [];

  @override
  void initState() {
    super.initState();
    fetchCompletedAppointments();
  }

  void _showDeleteConfirmationDialog(int appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('คุณต้องการลบรายการที่ตรวจนี้หรือไม่?'),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
            ),
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                deleteCompletedAppointment(
                    appointmentId); // ลบรายการเมื่อกดตกลง
                Navigator.of(context).pop(); // ปิด dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchCompletedAppointments() async {
    final response = await http.get(
      Uri.parse(
          'http://localhost:3000/completed-appointments/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> appointmentJson = jsonDecode(response.body);
      setState(() {
        completedAppointments = appointmentJson
            .map((json) => CompletedAppointment.fromJson(json))
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load completed appointments')),
      );
    }
  }

  Future<void> deleteCompletedAppointment(int appointmentId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/appointment-status/$appointmentId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        completedAppointments
            .removeWhere((appointment) => appointment.id == appointmentId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบรายการที่ตรวจแล้วสำเร็จ')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
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
          child: Column(
            children: [
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'บันทึกการตรวจที่ผ่านมา',
                    style: TextStyle(
                        fontSize: 24,
                        color: textColorDark,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: completedAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = completedAppointments[index];
                    return Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: ListTile(
                        title: Text(
                          appointment.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: textColorDark),
                        ), 
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // จัดให้อยู่ทางซ้าย
                          children: [
                            Text(
                              'วันที่ตรวจ:${appointment.date}',
                              style:
                                  TextStyle(fontSize: 16, color: subtextColor),
                            ),
                            
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(appointment
                                .id); // เรียก dialog เพื่อยืนยันการลบ
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
