import 'package:athenaeum/app_constants.dart';
import 'package:athenaeum/base.dart';
import 'package:athenaeum/pdf_page.dart';
import 'package:athenaeum/provider/google_sign_in.dart';
import 'package:athenaeum/screen_login.dart';
import 'package:athenaeum/screen_student_dashboard.dart';
import 'package:athenaeum/screen_teacher_dashboard.dart';
import 'package:athenaeum/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreference.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => GoogleSignInProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: RouteConstants.base,
        routes: {
          RouteConstants.base: (context) => const Base(),
          RouteConstants.login: (context) => const Login(),
          RouteConstants.teacherDashboard: (context) =>
              const TeacherDashboard(),
          RouteConstants.studentDashboard: (context) =>
              const StudentDashboard(),
          RouteConstants.pdfPage: (context) => PdfPage(
              pdfUrl: ModalRoute.of(context)!.settings.arguments as String),
        },
      ),
    );
  }
}
