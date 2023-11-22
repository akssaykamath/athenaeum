import 'package:athenaeum/app_constants.dart';
import 'package:athenaeum/provider/google_sign_in.dart';
import 'package:athenaeum/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    getPreference();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: (MediaQuery.of(context).size.width / 4) + 4,
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width / 4,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'assets/images/athenaeum_primary.png',
                        fit: BoxFit.contain,
                        height: MediaQuery.of(context).size.width / 2,
                        width: MediaQuery.of(context).size.width / 2,
                        // fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Athenaeum".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        'Login as ...',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Teacher",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  SharedPreference.writeString(
                                      key: SharedPreferenceKey.userType,
                                      value: "teacher");
                                  Navigator.popAndPushNamed(
                                      context, RouteConstants.teacherDashboard);
                                },
                                child: Image.asset('assets/images/teacher.png',
                                    width:
                                        MediaQuery.of(context).size.width / 2),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Student",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  SharedPreference.writeString(
                                      key: SharedPreferenceKey.userType,
                                      value: "student");
                                  Navigator.popAndPushNamed(
                                      context, RouteConstants.studentDashboard);
                                },
                                child: Image.asset(
                                  'assets/images/student.png',
                                  width: MediaQuery.of(context).size.width / 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  void getPreference() {}
}
