import 'package:final_login/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:final_login/router/routes.gr.dart'; // Import AutoRouter
import 'package:flutter_localizations/flutter_localizations.dart'; // เพิ่มส่วนนี้

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setPathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansThaiTextTheme(),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates, // เพิ่มตรงนี้
      supportedLocales: [
        const Locale('th', 'TH'), 
        const Locale('en', 'US'), 
      ],
    );
  }
}
