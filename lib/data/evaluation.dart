import 'package:flutter/material.dart';

class Answer {
  final String text;
  final int score;

  Answer(this.text, this.score);
}

class Question {
  final String text;
  final List<Answer> answers;

  Question(this.text, this.answers);
}

class QuizSet {
  final String name;
  final List<Question> questions;
  final IconData icon;

  QuizSet(this.name, this.questions, this.icon);
}

List<QuizSet> getSampleQuizSets() {
  return [
    QuizSet(
      "ตรวจสุขภาพ",
      [
        Question("ค่าความดันโลหิตตัวบน (mmhg)", [
          Answer("มีค่าความดันโลหิต", 0),
          Answer("ไม่มี", 0),
        ]),
        Question("ประวัติโรคเบาหวานในญาติสายตรง(พ่อ แม่ พี่ หรือน้อง) ?", [
          Answer("มี", 2),
          Answer("ไม่มี", 0),
        ]),
        Question("ค่าน้ำตาลในเลือดหลังอดหาร ?", [
          Answer("มีค่าน้ำตาล", 0),
          Answer("ไม่มีค่าน้ำตาล", 0),
        ]),
        // Question("ความดันโลหิต (mmhg) ", [
        //   Answer("ไม่มี", 0),
        //   Answer("ความดันตัวบน >=120 - < 140", 0),
        //   Answer("ความดันตัวบน >= 140", 0),
        // ]),
        // Question("น้ำตาลในเลือดหลังอดหาร", [
        //   Answer("ไม่มีค่าน้ำตาล", 0),
        //   Answer("<100 ", 0),
        //   Answer(">=100 - 125  ", 0),
        // ]),
        // Question("ท่านเป็นโรคอัมพาตหรือไม่ ?", [
        //   Answer("เป็น", 0),
        //   Answer("ไม่เป็น", 0),
        // ]),
        // Question("ท่านสูบบุหรี่หรือไม่ ?", [
        //   Answer("สูบ", 0),
        //   Answer("ไม่สูบ", 0),
        //   Answer("เคยสูบแต่เลิกแล้วมากกว่า 1 ปี", 0),
        // ]),
        // Question("ท่านดื่มเครื่องดื่มAlcoholeหรือไม่ ?", [
        //   Answer("ดื่ม", 0),
        //   Answer("ไม่ดื่ม", 0),
        // ]),
      ],
      Icons.monitor_heart, 
    ),
    QuizSet(
      "HIV",
      [
        Question("โปรแกรมตรวจHIV", [
          Answer("ตรวจเชื้อHIV/Sysphilis", 3),
          Answer("รับยาป้องกันโรคเอดส์(PrEP)", 1),
        ]),
      ],
      Icons.health_and_safety, 
    ),
    QuizSet(
      "เลิกบุหรี่",
      [
        Question("โดยปกติท่านสูบบุหรี่กี่มวนต่อวัน ?", [
          Answer("10 มวนหรือน้อยกว่า", 0),
          Answer(" 11 – 20 มวน", 1),
          Answer("21 – 30 ม้วน", 2),
          Answer("31 มวนขึ้นไป", 3),
        ]),
        Question("หลังตื่นนอนตอนเช้าท่านสูบบุหรี่มวนแรกเมื่อไร ?", [
          Answer("ภายใน 5 นาทีหลังตื่นนอน", 3),
          Answer("6-30 นาที หลังตื่นนอน", 2),
          Answer("31-60 นาที หลังตื่นนอน", 1),
          Answer("มากกว่า 60 นาทีหลังตื่นนอน", 0)
        ]),
        Question("ท่านสูบบุหรี่จัดในช่วง 2-3 ชั่วโมงแรกหลังตื่นนอน ?", [
          Answer("ใช่", 1),
          Answer("ไม่ใช่", 0),
        ]),
        Question("คุณคิดว่าบุหรี่ม้วนไหนที่คุณไม่อยากเลิก ?", [
          Answer("มวนแรกตอนเช้า", 1),
          Answer("มวนอื่นๆ ระหว่างวัน", 0),
        ]),
        Question("คุณรู้สึกลำบากหรือยุ่งยากในเขตปลอดบุหรี่หรือไม่ ?", [
          Answer("รู้สึกลําบาก", 1),
          Answer("ไม่รู้สึกลําบาก", 0),
        ]),
        Question("คุณยังต้องสูบบุหรี่แม้จะเจ็บป่วยหรือนอนพักโรงพยาบาล ?", [
          Answer("ใช่", 3),
          Answer("ไม่ใช่", 1),
        ]),
      ],
      Icons.smoke_free, 
    ),
  ];
}
