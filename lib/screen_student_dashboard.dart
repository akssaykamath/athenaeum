import 'dart:io';

import 'package:athenaeum/app_constants.dart';
import 'package:athenaeum/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  CollectionReference? fireStoreReference;

  @override
  void initState() {
    fireStoreReference = FirebaseFirestore.instance.collection("books");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Athenaeum"),
        actions: [
          IconButton(
              onPressed: () {
                SharedPreference.writeString(
                    key: SharedPreferenceKey.userType, value: "");
                Navigator.popAndPushNamed(context, RouteConstants.base);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Stack(
        fit: StackFit.loose,
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: fireStoreReference!.snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.size,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  RouteConstants.pdfPage,
                                  arguments:
                                      snapshot.data!.docs[index].get('url'));
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.picture_as_pdf_outlined,
                                      size: 40,
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${snapshot.data!.docs[index].get('name')}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                              "${snapshot.data!.docs[index].get('size')}"),
                                          const SizedBox(
                                            height: 8.0,
                                          ),
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_month,
                                                    size: 12,
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                  ),
                                                  const SizedBox(
                                                    width: 4.0,
                                                  ),
                                                  Text(DateFormat('dd-MMM-yyy')
                                                      .format(snapshot
                                                          .data!.docs[index]
                                                          .get('dateTime')
                                                          .toDate())),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 8.0,
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.timer,
                                                    size: 12,
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                  ),
                                                  const SizedBox(
                                                    width: 4.0,
                                                  ),
                                                  Text(DateFormat('kk:mm')
                                                      .format(snapshot
                                                          .data!.docs[index]
                                                          .get('dateTime')
                                                          .toDate())),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const Text("Something went wrong");
                      }
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
