import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RescheduleScreen extends StatefulWidget {
  final int appointmentId; // รับ appointmentId มาจากหน้าที่เรียกใช้
  RescheduleScreen({required this.appointmentId});

  @override
  _RescheduleScreenState createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // เตรียมการแสดงวันที่ในรูปแบบภาษาไทย
  }

  String _getThaiYear(DateTime date) {
    final buddhistYear = date.year + 543;
    return DateFormat.yMMMM('th_TH')
        .format(date)
        .replaceFirst(date.year.toString(), buddhistYear.toString());
  }

  Future<void> _rescheduleAppointment() async {
    if (_selectedDay != null) {
      try {
        final response = await http.put(
          Uri.parse(
              'http://localhost:3000/appointments/${widget.appointmentId}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'new_date': _selectedDay!.toIso8601String()}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เลื่อนนัดหมายสำเร็จ')),
          );
          Navigator.pop(
              context, true); // ส่งค่า true กลับไปยังหน้าที่เรียกใช้หน้าจอนี้
        } else {
          throw Exception('Failed to update appointment');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการเลื่อนนัด: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกวันที่ก่อนทำการเลื่อนนัด')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เลื่อนนัด'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            Text(
              'เลือกวันที่ต้องการเลื่อนนัด',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            TableCalendar(
              locale: 'th_TH',
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              enabledDayPredicate: (day) {
                DateTime today = DateTime.now();
                DateTime comparisonDay = DateTime(day.year, day.month, day.day);

                if (comparisonDay.isBefore(
                        DateTime(today.year, today.month, today.day)) ||
                    comparisonDay.isAtSameMomentAs(
                        DateTime(today.year, today.month, today.day)) ||
                    day.weekday == 6 ||
                    day.weekday == 7) {
                  return false;
                }
                return true;
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 187, 224, 255),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                disabledTextStyle: TextStyle(color: Colors.grey),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                formatButtonVisible: false,
                titleCentered: true,
                titleTextFormatter: (date, locale) => _getThaiYear(date),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'วันที่เลือก: ',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        _selectedDay != null
                            ? '${DateFormat.yMMMMEEEEd('th_TH').format(_selectedDay!).replaceFirst(_selectedDay!.year.toString(), (_selectedDay!.year + 543).toString())}'
                            : 'ยังไม่ได้เลือกวันที่',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed:
                  _rescheduleAppointment, // เชื่อมกับฟังก์ชันอัปเดตวันที่นัดหมาย
              icon: Icon(Icons.check_circle),
              label: Text('ยืนยันการเลื่อนนัด'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
