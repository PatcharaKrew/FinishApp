import 'package:final_login/constants/color.dart';
import 'package:final_login/screen/login.dart';
import 'package:final_login/screen/massage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:final_login/screen/edit_profile_page.dart';
import 'package:final_login/screen/edit_profile_page2.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/profile/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        profileData = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch profile data')),
      );
    }
  }

  void _editPersonalInfo() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(profileData: profileData!),
      ),
    );

    if (updatedData != null) {
      setState(() {
        profileData = updatedData;
      });
    }
  }

  void _editHealthInfo() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage2(healthData: profileData!),
      ),
    );

    if (updatedData != null) {
      setState(() {
        profileData = updatedData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profileData == null) {
      return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text('Profile',
                style: TextStyle(
                    color: textColorDark,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: backgroundGradientStart.withOpacity(0.9),
            automaticallyImplyLeading: false,
          ),
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
          )));
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('โปรไฟล์',
            style: TextStyle(
                color: textColorDark,
                fontSize: 26,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: backgroundGradientStart.withOpacity(0.9),
        automaticallyImplyLeading: false,
      ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 80.0,
                      backgroundImage: AssetImage('assets/images/person.png'),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '${profileData!['title_name']} ${profileData!['first_name']} ${profileData!['last_name']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003566),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  _buildSectionCard(
                    title: 'ข้อมูลส่วนตัว',
                    onEditPressed: _editPersonalInfo,
                    content: [
                      _buildProfileCard(
                          'เลขบัตรประชาชน', profileData!['id_card']),
                      _buildProfileCard('เบอร์โทร', profileData!['phone']),
                      _buildProfileCard('เพศ', profileData!['gender']),
                      _buildProfileCard(
                          'อายุ', profileData?['age']?.toString() ?? '-'),
                      _buildProfileCard(
                        'ปีเกิด',
                        profileData!['date_birth'] != null
                            ? DateFormat('dd/MM/yyyy').format(
                                DateTime.parse(profileData!['date_birth']))
                            : '-',
                      ),
                      _buildProfileCard(
                          'เลขบ้าน', profileData!['house_number']),
                      _buildProfileCard('ถนน', profileData!['street']),
                      _buildProfileCard('หมู่บ้าน', profileData!['village']),
                      _buildProfileCard('ตําบล', profileData!['subdistrict']),
                      _buildProfileCard('อําเภอ', profileData!['district']),
                      _buildProfileCard('จังหวัด', profileData!['province']),
                      _buildProfileCard('รหัสไปรษณีย์',
                          profileData?['zipcode']?.toString() ?? '-'),
                    ],
                  ),
                  _buildSectionCard(
                    title: 'ข้อมูลสุขภาพ',
                    onEditPressed: _editHealthInfo,
                    content: [
                      _buildProfileCard(
                        'น้ำหนัก',
                        profileData?['weight'] != null
                            ? '${profileData!['weight'].toString()} กิโลกรัม'
                            : "-",
                      ),
                      _buildProfileCard(
                        'ส่วนสูง',
                        profileData?['height'] != null
                            ? '${profileData!['height'].toString()} เซนติเมตร'
                            : "-",
                      ),
                      _buildProfileCard(
                        'รอบเอว',
                        profileData?['waist'] != null
                            ? '${profileData!['waist'].toString()} เซนติเมตร'
                            : "-",
                      ),
                      _buildProfileCard(
                        'ค่า BMI',
                        profileData?['bmi'] != null &&
                                profileData!['bmi'].toString() != "NaN"
                            ? profileData!['bmi'].toString()
                            : "-",
                      ),
                      _buildProfileCard(
                        'ค่า รอบเอวต่อส่วนสูง',
                        profileData?['waist_to_height_ratio'] != null &&
                                profileData!['waist_to_height_ratio']
                                        .toString() !=
                                    "NaN"
                            ? profileData!['waist_to_height_ratio'].toString()
                            : "-",
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactUs(),
                        ),
                      );
                    },
                    child: Text(
                      'ข้อมูลติดต่อ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      backgroundColor: buttonSelectedColor,
                      elevation: 10,
                      shadowColor:
                          Color.fromARGB(255, 0, 28, 52).withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      'ออกจากระบบ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      backgroundColor: buttonColor,
                      elevation: 10,
                      shadowColor:
                          Color.fromARGB(255, 0, 28, 52).withOpacity(0.9),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required VoidCallback onEditPressed,
    required List<Widget> content,
  }) {
    return Card(
      color: Color.fromARGB(255, 255, 255, 255),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003566),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEditPressed,
                ),
              ],
            ),
          ),
          Divider(),
          ...content,
        ],
      ),
    );
  }

  Widget _buildProfileCard(String title, dynamic value) {
    return Card(
      color: Color.fromARGB(255, 255, 255, 255),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF003566),
          ),
        ),
        subtitle: Text(
          value != null && value != "NaN" ? value.toString() : "-",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF003566),
          ),
        ),
      ),
    );
  }
}
