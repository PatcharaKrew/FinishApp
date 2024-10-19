import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }
}

class AppointmentNotification extends StatefulWidget {
  final int userId;

  AppointmentNotification({required this.userId});

  @override
  _AppointmentNotificationState createState() =>
      _AppointmentNotificationState();
}

class _AppointmentNotificationState extends State<AppointmentNotification> {
  late WebSocketChannel channel;
  final NotificationService notificationService = NotificationService(); // สร้าง instance ของ NotificationService

  @override
  void initState() {
    super.initState();
    notificationService.initialize(); // เรียกใช้เมธอด initialize ของ NotificationService

    // เชื่อมต่อกับ WebSocket server
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8080/${widget.userId}'), // แก้ไข URL
      );

      // ตรวจสอบการเชื่อมต่อสำเร็จ
      print('WebSocket connection established for user ${widget.userId}');

      // ฟังข้อความจาก WebSocket server
      channel.stream.listen((message) {
        print('Received message: $message'); // พิมพ์ข้อความที่ได้รับ
        Map<String, dynamic> notification = jsonDecode(message);
        notificationService.showNotification(
            'แจ้งเตือนการนัดหมาย', notification['notification']);
      });
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แจ้งเตือนการนัดหมาย'),
      ),
      body: Center(
        child: Text('รอการแจ้งเตือนการนัดหมาย...'),
      ),
    );
  }

  @override
  void dispose() {
    if (channel != null) {
      channel.sink.close();
    }
    super.dispose();
  }
}
