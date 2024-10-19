import 'package:final_login/constants/color.dart';
import 'package:final_login/screen/CompletedAppointment%20.dart';
import 'package:final_login/screen/appointmentDetail.dart';
import 'package:final_login/screen/mainMenu.dart';
import 'package:final_login/screen/profile.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeDevicePage extends StatefulWidget {
  final int userId;
  final String userName;
  const HomeDevicePage(
      {super.key, required this.userId, required this.userName,});

  @override
  State<HomeDevicePage> createState() => _HomeDevicePageState();
}

class _HomeDevicePageState extends State<HomeDevicePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MainMenu(userName: widget.userName, userId: widget.userId),
      AppointmentDetails(userId: widget.userId),  // ส่ง userId ไปที่ AppointmentDetails
      CompletedAppointments(userId: widget.userId),
      ProfilePage(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("หน้าหลัก"),
            selectedColor: bottomBarIconColor,
            unselectedColor: loginBackgroundColor,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.calendar_today,),
            title: Text("รายการนัด"),
            selectedColor: bottomBarIconColor,
            unselectedColor: loginBackgroundColor,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.check_circle_outline_outlined),  // ไอคอนสำหรับ "รายการที่ตรวจแล้ว"
            title: Text("การตรวจ"),
            selectedColor: bottomBarIconColor,
            unselectedColor: loginBackgroundColor,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("ข้อมูลผู้ใช้"),
            selectedColor: bottomBarIconColor,
            unselectedColor: loginBackgroundColor,
          ),
        ],
        backgroundColor: bottomBarColor0.withOpacity(0.9),
      ),
    );
  }
}
