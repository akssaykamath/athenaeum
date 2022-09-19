import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<File> files = [];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(files.isEmpty ? Icons.add : Icons.upload),
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );

          if (result != null) {
            files = result.paths.map((path) => File(path!)).toList();
            setState(() {});
          } else {
            // User canceled the picker
          }
        },
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 16.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user!.displayName.toString().toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      user.email.toString(),
                      style: const TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 16.0,
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(user.photoURL.toString()),
                )
              ],
            ),
            const SizedBox(
              height: 16.0,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: files.isEmpty ? 0 : files.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.blue.shade50,
                      child: Row(
                        children: const [
                          CircleAvatar(
                            child: Icon(Icons.picture_as_pdf),
                          )
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      )),
    );
  }
}
