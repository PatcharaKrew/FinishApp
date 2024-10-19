import 'package:final_login/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ข้อมูลติดต่อ'),  // Changed title to match the image
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: backgroundGradientStart.withOpacity(0.9),
      ),
      body: Container(
        // Outer gradient background
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),  // Inner container with white background
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width * 0.9,  // Make it responsive
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Logo
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.asset('assets/images/logor.png'),  // Update with your image path
                  ),
                  SizedBox(height: 20),
                  // Website Icon and Text
                  ListTile(
                    leading: Icon(Icons.language, color: Colors.purple, size: 40),
                    title: Text('website'),
                    onTap: () async {
                      const url = 'https://www.budhosp.go.th/?fbclid=IwZXh0bgNhZW0CMTAAAR0OTzLrkUDE25HXT_raCSRm5dA58cXVfqAvhCE0OomQB-i0NNuM3yc02a4_aem_mqlJBfsGMFTVMxEzBp6URg';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  // Facebook Icon and Text
                  ListTile(
                    leading: Icon(Icons.facebook, color: Colors.blue, size: 40),
                    title: Text('facebook'),
                    onTap: () async {
                      const url = 'https://web.facebook.com/budhosp.go.th';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  // Phone Icon and Text
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.green, size: 40),
                    title: Text('0993708895'),
                    onTap: () async {
                      const url = 'tel:0993708895';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
