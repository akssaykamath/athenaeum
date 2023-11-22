import 'package:athenaeum/app_constants.dart';
import 'package:athenaeum/screen_dashboard.dart';
import 'package:athenaeum/screen_login.dart';
import 'package:athenaeum/screen_teacher_dashboard.dart';
import 'package:athenaeum/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  @override
  void initState() {
    getPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getPreference();
  }

  Widget getPreference() {
    String userType =
        SharedPreference.readString(key: SharedPreferenceKey.userType);
    if (userType == "") {
      return const Login();
    } else if (userType == "teacher") {
      return const TeacherDashboard();
    } else {
      return const TeacherDashboard();
    }
  }
}
