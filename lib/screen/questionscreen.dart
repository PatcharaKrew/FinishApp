import 'package:final_login/constants/color.dart';
import 'package:final_login/data/evaluation.dart';
import 'package:final_login/screen/date_result.dart';
import 'package:final_login/screen/resultscreen.dart';
import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget {
  final QuizSet quizSet;
  final int userId;
  final String userName;
  QuestionScreen(
      {required this.quizSet, required this.userId, required this.userName});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentQuestionIndex = 0;
  List<int> _selectedAnswers = List.filled(3, -1);
  List<int> _selectedAnswersHIV = List.filled(1, -1);
  List<int> _selectedAnswersSmoking = List.filled(6, -1);
  int? bloodPressure; // ตัวแปรเก็บค่าความดันโลหิต
  int? bloodSugar; // ตัวแปรเก็บค่าน้ำตาลในเลือด

  void _nextQuestion() {
    if (_currentQuestionIndex == 0 &&
        _selectedAnswers[0] == 0 &&
        bloodPressure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกค่าความดันโลหิตก่อนดำเนินการต่อ'),
        ),
      );
      return;
    }

    if (_currentQuestionIndex == 2 &&
        _selectedAnswers[2] == 0 &&
        bloodSugar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกค่าน้ำตาลในเลือดก่อนดำเนินการต่อ'),
        ),
      );
      return;
    }

    setState(() {
      _currentQuestionIndex++;
    });
  }

  void _prevQuestion() {
    setState(() {
      _currentQuestionIndex--;
    });
  }

  void _submitQuiz() {
    List<int> selectedAnswers;
    if (widget.quizSet.name == "ตรวจสุขภาพ") {
      selectedAnswers = _selectedAnswers;

      // ตรวจสอบการกรอกค่าความดันโลหิต
      if (_currentQuestionIndex == 0 &&
          selectedAnswers[0] == 0 &&
          bloodPressure == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กรุณากรอกค่าความดันโลหิต'),
          ),
        );
        return; // หยุดการทำงานถ้ายังไม่ได้กรอกค่าความดัน
      }

      // ตรวจสอบการกรอกค่าน้ำตาลในเลือดในคำถามข้อที่ 2
      if (_currentQuestionIndex == 2 &&
          selectedAnswers[2] == 0 &&
          bloodSugar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กรุณากรอกค่าน้ำตาลในเลือดหลังอาหาร'),
          ),
        );
        return; // หยุดการทำงานถ้ายังไม่ได้กรอกค่าน้ำตาลในเลือด
      }
    } else if (widget.quizSet.name == "เลิกบุหรี่") {
      selectedAnswers = _selectedAnswersSmoking;
    } else if (widget.quizSet.name == "HIV") {
      selectedAnswers = _selectedAnswersHIV;
    } else {
      selectedAnswers = [];
    }

    // Mark any unanswered question with an answer index that corresponds to a score of 0
    for (int i = 0; i < selectedAnswers.length; i++) {
      if (selectedAnswers[i] == -1) {
        selectedAnswers[i] = widget.quizSet.questions[i].answers
            .indexWhere((answer) => answer.score == 0);
      }
    }

    // ถ้าเป็น HIV ให้ไปหน้าลงนัด
    if (widget.quizSet.name == "HIV") {
      if (selectedAnswers[0] == -1) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('กรุณาเลือกคำตอบก่อนลงนัด'),
        ));
        return;
      }

      String resultProgram =
          widget.quizSet.questions[0].answers[selectedAnswers[0]].text;
      debugPrint('Result Program: $resultProgram');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentScreen(
            quizSet: widget.quizSet,
            userId: widget.userId,
            resultProgram: resultProgram,
            userName: widget.userName,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            quizSet: widget.quizSet,
            selectedAnswers: selectedAnswers,
            userId: widget.userId,
            userName: widget.userName,
            bloodPressure: bloodPressure, // ส่งค่าความดันโลหิตไปยังผลลัพธ์
            bloodSugar: bloodSugar, // ส่งค่าน้ำตาลในเลือดไปยังผลลัพธ์
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quizSet.questions[_currentQuestionIndex];
    final selectedAnswers;
    if (widget.quizSet.name == "ตรวจสุขภาพ") {
      selectedAnswers = _selectedAnswers;
    } else if (widget.quizSet.name == "เลิกบุหรี่") {
      selectedAnswers = _selectedAnswersSmoking;
    } else if (widget.quizSet.name == "HIV") {
      selectedAnswers = _selectedAnswersHIV;
    } else {
      selectedAnswers = [];
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundGradientEnd,
        iconTheme: IconThemeData(color: bottomBarIconColor),
        title: Text(
          widget.quizSet.name == 'HIV'
              ? 'เลือกโปรแกรมHIV'
              : widget.quizSet.name == 'เลิกบุหรี่'
                  ? 'แบบทดสอบวัดระดับการติดนิโคติน'
                  : widget.quizSet.name,
          style: TextStyle(color: bottomBarIconColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(
                currentQuestion.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.0,
                    color: textColor1,
                    fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.grey),
              SizedBox(height: 10),
              ...currentQuestion.answers.map((answer) {
                int index = currentQuestion.answers.indexOf(answer);
                bool isSelected =
                    selectedAnswers[_currentQuestionIndex] == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAnswers[_currentQuestionIndex] = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                backgroundGradientStart2,
                                backgroundGradientEnd
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border:
                          Border.all(color: backgroundGradientEnd, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        answer.text,
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              isSelected ? Colors.white : backgroundGradientEnd,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 20),

              // ถ้าเป็นคำถามข้อที่ 0 และเลือกตัวเลือกที่ 0 จะแสดงช่องให้กรอกค่าความดันโลหิต
              if (_currentQuestionIndex == 0 && _selectedAnswers[0] == 0)
                Column(
                  children: [
                    Text(
                      'กรุณากรอกค่าความดันโลหิตของคุณ',
                      style: TextStyle(fontSize: 16, color: Colors.redAccent),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ค่าความดันโลหิต',
                      ),
                      onChanged: (value) {
                        setState(() {
                          bloodPressure = int.tryParse(value);
                        });
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),

              // ถ้าเป็นคำถามข้อที่ 2 และเลือกตัวเลือกที่ 0 จะแสดงช่องให้กรอกค่าน้ำตาลในเลือด
              if (_currentQuestionIndex == 2 && _selectedAnswers[2] == 0)
                Column(
                  children: [
                    Text(
                      'กรุณากรอกค่าน้ำตาลในเลือดหลังอาหาร',
                      style: TextStyle(fontSize: 16, color: Colors.redAccent),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ค่าน้ำตาลในเลือด',
                      ),
                      onChanged: (value) {
                        setState(() {
                          bloodSugar = int.tryParse(value);
                        });
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: _prevQuestion,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back_ios_new, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'ย้อนกลับ',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: backgroundGradientEnd,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        minimumSize: Size(140, 60),
                      ),
                    ),
                  Spacer(),
                  if (_currentQuestionIndex <
                      widget.quizSet.questions.length - 1)
                    ElevatedButton(
                      onPressed: selectedAnswers[_currentQuestionIndex] == -1
                          ? null
                          : _nextQuestion,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ถัดไป',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 20),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: buttonSelectedColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        minimumSize: Size(140, 60),
                      ),
                    ),
                  if (_currentQuestionIndex ==
                      widget.quizSet.questions.length - 1)
                    ElevatedButton(
                      onPressed: selectedAnswers[_currentQuestionIndex] == -1
                          ? null
                          : _submitQuiz,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.quizSet.name == 'HIV' ? 'ลงนัด' : 'ประเมิน',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check, size: 20),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        backgroundColor: sucmintColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        minimumSize: Size(140, 60),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
