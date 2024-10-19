import 'package:final_login/constants/color.dart';
import 'package:final_login/data/evaluation.dart';
import 'package:final_login/screen/edit_profile_page2.dart';
import 'package:final_login/screen/login.dart';
import 'package:final_login/screen/profile.dart';
import 'package:final_login/screen/questionscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainMenu extends StatefulWidget {
  final String userName;
  final int userId;

  MainMenu({
    required this.userName,
    required this.userId,
  });

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late String userName;
  late String latestProgramName = 'ยังไม่มีนัดหมาย';
  late String latestAppointmentDate = '';
  List<String> existingAppointments = [];
  late WebSocketChannel channel;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    userName = widget.userName;

    _fetchLatestAppointment().then((data) {
      if (data != null) {
        setState(() {
          latestProgramName = data['program_name'];
          latestAppointmentDate =
              _formatDateToThai(DateTime.parse(data['appointment_date']));
              _checkAppointmentDate(data['appointment_date']);
        });
      }
    });

    _fetchExistingAppointments();
    _connectWebSocket();
    _initializeNotifications();
  }

  // ฟังก์ชันเชื่อมต่อ WebSocket
  void _connectWebSocket() {
    print('Connecting to WebSocket...');
    channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost/${widget.userId}'),
    );

    channel.stream.listen((message) {
      print('Received message: $message');
      _showNotification('การแจ้งเตือนนัดหมาย', message);
    }, onError: (error) {
      print('WebSocket Error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });

    print('WebSocket connection established.');
  }

  // ฟังก์ชันตั้งค่า Notification
  void _initializeNotifications() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _checkAppointmentDate(String appointmentDate) {
    DateTime now = DateTime.now();
    DateTime appointment = DateTime.parse(appointmentDate);
    Duration difference = appointment.difference(now);

    print('Current Date: $now');
    print('Appointment Date: $appointment');
    print('Difference in Hours: ${difference.inHours}');

    // ถ้าเหลืออีกน้อยกว่า 24 ชั่วโมง
    if (difference.inHours <= 24 && difference.inHours >= 0) {
      print('จะมีการแจ้งเตือน: คุณมีนัดหมายในอีก 1 วัน');
      _showNotification('การแจ้งเตือนนัดหมาย', 'คุณมีนัดหมายในอีก 1 วัน');
    } else {
      print('ยังไม่มีการแจ้งเตือนในตอนนี้');
    }
}


  // ฟังก์ชันแสดง Notification
  Future<void> _showNotification(String title, String body) async {
    print('Showing notification with title: $title and body: $body');

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _fetchLatestAppointment() async {
    final response = await http.get(
      Uri.parse(
          'http://localhost:3000/appointments-with-date/${widget.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> appointments = jsonDecode(response.body);
      if (appointments.isNotEmpty) {
        return appointments.first;
      }
    }
    return null;
  }

  Future<void> _fetchExistingAppointments() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/appointments-date-all/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> appointments = jsonDecode(response.body);
      setState(() {
        existingAppointments = appointments
            .map((appointment) => appointment['program_name'])
            .toList()
            .cast<String>();
      });
    }
  }

  String _formatDateToThai(DateTime date) {
    initializeDateFormatting('th_TH', null);

    final localDate =
        date.toLocal().add(Duration(hours: 7)); // ปรับเวลาเป็น GMT+7
    final thaiDateFormat = DateFormat.yMMMMEEEEd('th_TH');

    final buddhistYear = localDate.year + 543;
    return thaiDateFormat
        .format(localDate)
        .replaceAll('${localDate.year}', '$buddhistYear');
  }

  void _navigateToProfile() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: widget.userId),
      ),
    );

    if (updatedData != null) {
      setState(() {
        userName =
            '${updatedData['title_name']} ${updatedData['first_name']} ${updatedData['last_name']}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
                padding: EdgeInsets.all(16.0),
                color: Colors.transparent,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25.0,
                      backgroundImage: AssetImage('assets/images/logor.png'),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'โรงพยาบาลพุทธชินราช พิษณุโลก',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColorDark),
                        ),
                        GestureDetector(
                          onTap: _navigateToProfile,
                          child: Text(
                            userName,
                            style: TextStyle(color: textColorDark),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      icon: Icon(Icons.logout),
                      color: textColorDark,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'รายการนัดที่ใกล้ถึง',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: textColorDark,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: latestProgramName == 'ยังไม่มีนัดหมาย'
                            ? Colors.grey
                            : Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: latestProgramName == 'ยังไม่มีนัดหมาย'
                                    ? Colors.grey
                                    : textColorDark,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    latestProgramName == 'ยังไม่มีนัดหมาย'
                                        ? CrossAxisAlignment.center
                                        : CrossAxisAlignment.start,
                                children: [
                                  if (latestProgramName ==
                                      'ยังไม่มีนัดหมาย') ...[
                                    Text(
                                      'ยังไม่มีนัดหมาย',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: nextButtonTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),  
                                  ] else ...[
                                    Text(latestProgramName,
                                        style: TextStyle(
                                            color: nextButtonTextColor)),
                                    Text(
                                      latestAppointmentDate.isNotEmpty
                                          ? latestAppointmentDate
                                          : 'ไม่มีการนัดหมาย',
                                      style:
                                          TextStyle(color: nextButtonTextColor),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Divider(
                      color: Colors.white,
                      thickness: 2.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'รายการนัดหมาย',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: textColorDark,
                            ),
                          ),
                        ),
                      ),
                      InfoIcon(),
                    ],
                  ),
                  Column(
                    children:
                        List.generate(getSampleQuizSets().length, (index) {
                      return HealthButton(
                        quizSet: getSampleQuizSets()[index],
                        userName: widget.userName,
                        userId: widget.userId,
                        existingAppointments: existingAppointments,
                      );
                    }),
                  ),
                ])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthButton extends StatelessWidget {
  final QuizSet quizSet;
  final String userName;
  final int userId;
  final List<String> existingAppointments;

  HealthButton({
    super.key,
    required this.quizSet,
    required this.userName,
    required this.userId,
    required this.existingAppointments,
  });

  Future<int> _fetchAppointmentCount(String programName) async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/evaluation-results/count/$programName'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final count = jsonDecode(response.body)['count'];
      return count;
    } else {
      throw Exception('Failed to load appointment count');
    }
  }

  Future<Map<String, dynamic>> _fetchHealthData() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/profile/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load health data');
    }
  }

  Future<void> _navigateToQuiz(BuildContext context) async {
    if (existingAppointments.contains(quizSet.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('คุณได้ลงนัดรายการนี้แล้ว')),
      );
      return;
    }
    if (quizSet.name == 'ตรวจสุขภาพ') {
      try {
        final healthData = await _fetchHealthData();

        double? bmi = double.tryParse(healthData['bmi'].toString());
        double? waistToHeightRatio =
            double.tryParse(healthData['waist_to_height_ratio'].toString());

        if (bmi == null ||
            bmi.isNaN ||
            waistToHeightRatio == null ||
            waistToHeightRatio.isNaN) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.info,
            title: 'กรุณากรอกข้อมูลสุขภาพก่อนเข้าตรวจสุขภาพ',
            confirmBtnText: 'ไปกรอก',
            onConfirmBtnTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfilePage2(healthData: healthData),
                ),
              );
            },
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionScreen(
              quizSet: quizSet,
              userId: userId,
              userName: userName,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงข้อมูลสุขภาพ: $e')),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(
            quizSet: quizSet,
            userId: userId,
            userName: userName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: GestureDetector(
        onTap: () => _navigateToQuiz(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          height: MediaQuery.of(context).size.height * 0.1,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 243, 243, 243),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 188, 188, 188),
                spreadRadius: 1,
                blurRadius: 7,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(children: [
            Icon(quizSet.icon, size: 40, color: Color(0xFF0277BD)),
            SizedBox(width: 25),
            Text(
              quizSet.name,
              style: TextStyle(fontSize: 28, color: Color(0xFF0277BD)),
            ),
          ]),
        ),
      ),
    );
  }
}

class InfoIcon extends StatelessWidget {
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รายละเอียดการเข้ารับบริการ'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('1. ตรวจสุขภาพ : เข้าพบแพทย์เพื่อทำการตรวจเบื้องต้น และเข้ารับการเจาะเลือดเพื่อตรวจสารเคมีในเลือด (ควรงดอาหารและน้ำอย่างน้อย 12 ชม.หากกระหายน้ำหรือหิวมากให้จิบน้ำเปล่าได้เพียงเล็กน้อย) \n',
                  style: TextStyle(fontSize: 16),
                ),
                Text('2. ตรวจ HIV : เข้ารับการตรวจหรือรับคำปรึกษาจากแพทย์ และผู้เชี่ยวชาญด้าน HIV\n',
                  style: TextStyle(fontSize: 16),
                ),
                Text('3. เลิกบุหรี่ : รับคำแนะนำจากทีมแพทย์ และนักจิตวิทยาเกี่ยวกับวิธีการเลิกบุหรี่ที่เหมาะสมกับบุคคล\n',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('ปิด'),
              onPressed: () {
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
    return IconButton(
      icon: Icon(
        Icons.info_outline,
        color: textColorDark,
        size: 30.0,
      ),
      onPressed: () {
        _showInfoDialog(context);
      },
    );
  }
}