import 'package:final_login/screen/postpone_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:final_login/constants/color.dart';
import 'package:intl/intl.dart';

class Appointment {
  final int id;
  final String title;
  final String date;
  final String time;

  Appointment({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
  });

  IconData get icon {
    if (title == 'ตรวจสุขภาพ') {
      return Icons.monitor_heart;
    } else if (title == 'เลิกบุหรี่') {
      return Icons.smoke_free;
    } else if (title == 'HIV') {
      return Icons.health_and_safety;
    } else {
      return Icons.error;
    }
  }

  String get timeSlot {
    if (title == 'ตรวจสุขภาพ') {
      return 'ช่วงเวลาในการเข้าตรวจ : 7:30 - 17:00';
    } else if (title == 'เลิกบุหรี่') {
      return 'ช่วงเวลาในการเข้าตรวจ : 8:30 - 16:00';
    } else {
      return '';
    }
  }

  static Appointment fromJson(Map<String, dynamic> json) {
    DateTime parsedDate =
        DateTime.parse(json['appointment_date']).toUtc().toLocal();

    String formattedDate =
        DateFormat('EEEE dd MMMM yyyy', 'th_TH').format(parsedDate);

    return Appointment(
      id: json['id'],
      title: json['program_name'],
      date: formattedDate,
      time: 'เวลา 7:00 - 16:00',
    );
  }
}

class AppointmentDetails extends StatefulWidget {
  final int userId; // รับ userId จาก HomeDevicePage

  AppointmentDetails({required this.userId});

  @override
  State<AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
  List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/appointments-date-all/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> appointmentJson = jsonDecode(response.body);
      setState(() {
        appointments =
            appointmentJson.map((json) => Appointment.fromJson(json)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments')),
      );
    }
  }

  Future<void> deleteAppointment(int appointmentId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/appointments/$appointmentId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        appointments
            .removeWhere((appointment) => appointment.id == appointmentId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ยกเลิกการนัดหมายสําเร็จ')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel appointment')),
      );
    }
  }

  void _showDeleteConfirmationDialog(int appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('คุณต้องการจะลบการนัดหมายนี้หรือไม่?'),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                deleteAppointment(appointmentId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
          child: Column(children: [
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'รายการนัดหมาย',
                  style: TextStyle(
                      fontSize: 24,
                      color: textColorDark,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    color: Color(0xFFF8F9FA),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: const Color.fromARGB(255, 123, 123, 123),
                          width: 0.7),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                appointment.icon,
                                color: textColorDark,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                appointment.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColorDark,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFF90CAF9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'นัดหมาย : ${appointment.date}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            child: Text(
                              appointment.timeSlot,
                              style: TextStyle(
                                fontSize: 16,
                                color: subtextColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: bottomBarIconColor,
                                    backgroundColor: Color(0xFFD32F2F),
                                    fixedSize: Size(double.maxFinite, 45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(
                                        appointment.id);
                                  },
                                  child: Text(
                                    'ยกเลิกนัดหมาย',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: bottomBarIconColor,
                                    backgroundColor: backgroundGradientEnd,
                                    fixedSize: Size(double.maxFinite, 45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RescheduleScreen(
                                            appointmentId: appointment.id),
                                      ),
                                    );

                                    if (result == true) {
                                      // ถ้ามีการเปลี่ยนแปลงให้ดึงข้อมูลใหม่
                                      fetchAppointments();
                                    }
                                  },
                                  child: Text('เลื่อนนัด',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}
