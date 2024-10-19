import 'package:final_login/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:final_login/screen/homeDevice.dart';

class SuccessScreen extends StatelessWidget {
  final DateTime selectedDate;
  final String quizSetName;
  final String userName;
  final int userId;
  SuccessScreen({
    required this.selectedDate,
    required this.quizSetName,
    required this.userName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/success.json',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text(
              'ดำเนินการลงนัดสำเร็จ!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '${DateFormat.yMMMMEEEEd('th_TH').format(selectedDate).replaceFirst(selectedDate.year.toString(), (selectedDate.year + 543).toString())}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'โปรแกรมนัด: $quizSetName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeDevicePage(
                      userName: userName,
                      userId: userId,
                    ),
                  ),
                );
              },
              child: Text('ตกลง',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: buttonTextColor)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                backgroundColor: nextButtonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
