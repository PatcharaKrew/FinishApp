import 'package:final_login/constants/color.dart';
import 'package:final_login/data/evaluation.dart';
import 'package:final_login/screen/succesScreen%20.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppointmentScreen extends StatefulWidget {
  final QuizSet quizSet;
  final int userId;
  final String resultProgram;
  final String userName;
  AppointmentScreen(
      {required this.quizSet,
      required this.userId,
      required this.resultProgram,
      required this.userName});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _remainingQueue = -1;

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

  Future<void> _fetchRemainingQueue() async {
    if (_selectedDay != null) {
      final formattedDate =
          "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";
      final url = Uri.parse(
          'http://localhost:3000/remaining-queue/${widget.quizSet.name}/$formattedDate');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _remainingQueue = data['remainingQueue'];
          });
        } else {
          setState(() {
            _remainingQueue =
                0; // หากมีข้อผิดพลาดในการดึงข้อมูล ให้ถือว่าวันนี้ไม่ว่าง
          });
        }
      } catch (error) {
        setState(() {
          _remainingQueue = 0;
        });
      }
    }
  }

  void _submitAppointment() async {
    if (_selectedDay != null) {
      if (_remainingQueue <= 0) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Warning',
          text: 'กรุณาลงนัดวันที่ว่าง',
        );
        return;
      }

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/evaluation-results'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'user_id': widget.userId,
            'program_name': widget.quizSet.name,
            'result_program': widget.resultProgram,
            'appointment_date':
                _selectedDay!.toIso8601String().substring(0, 10),
          }),
        );

        if (response.statusCode == 201) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(
                selectedDate: _selectedDay!,
                quizSetName: widget.quizSet.name,
                userName: widget.userName,
                userId: widget.userId,
              ),
            ),
          );
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            text: 'เกิดข้อผิดพลาดในการบันทึกการนัดหมาย',
          );
        }
      } catch (error) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์',
        );
      }
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Warning',
        text: 'กรุณาเลือกวันที่ก่อนทำการลงนัด',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeSlot;
    if (widget.quizSet.name == "ตรวจสุขภาพ") {
      timeSlot = "ช่วงเวลาในการเข้าตรวจ : 7:30 - 17:00";
    } else if (widget.quizSet.name == "เลิกบุหรี่") {
      timeSlot = "ช่วงเวลาในการเข้าตรวจ : 8:30 - 16:00";
    } else {
      timeSlot = "ช่วงเวลาในการเข้าตรวจ : 8:30 - 11:30";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: bottomBarIconColor),
        title: Text(
          'ลงนัด',
          style: TextStyle(color: bottomBarIconColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            Text(
              widget.quizSet.name == "HIV"
                  ? 'เลือกวันเข้ารับบริการ'
                  : 'เลือกวันที่ต้องการลงนัด ${widget.quizSet.name}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: textColor,
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
                _fetchRemainingQueue(); // เรียกใช้ฟังก์ชันเมื่อเลือกวันที่ใหม่
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
                  color: nextButtonColor,
                  shape: BoxShape.circle,
                ),
                disabledTextStyle: TextStyle(color: Colors.grey),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: subtextColor,
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
            Text(
              _remainingQueue == -1
                  ? 'กำลังโหลดข้อมูลจำนวนคิว...'
                  : _remainingQueue == 0
                      ? 'คิวเต็มแล้ว กรุณาเลือกวันที่อื่น'
                      : 'จำนวนคิวที่เหลือ: $_remainingQueue',
              style: TextStyle(fontSize: 18.0, color: Colors.red),
            ),
            SizedBox(height: 10.0),
            Text('$timeSlot', style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _submitAppointment,
              icon: Icon(Icons.check_circle),
              label: Text('ยืนยันการลงนัด'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: nextButtonColor,
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
