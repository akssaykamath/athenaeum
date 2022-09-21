import 'dart:io';

import 'package:athenaeum/service_firebase.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<PlatformFile> files = [];
  UploadTask? uploadTask;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );

          if (result != null) {
            files = result.files
                .map((file) => PlatformFile(name: file.name, size: file.size))
                .toList();
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      margin: const EdgeInsets.symmetric(vertical: 2.0),
                      color: Colors.blue.shade50,
                      child: Row(
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.picture_as_pdf),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        files[index].name,
                                        maxLines: 3,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${(files[index].size / 1000000).toStringAsFixed(2)} MB",
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          InkWell(
                            onTap: () {
                              String fileName = files[index].name;
                              final firebaseStorageDestination =
                                  'files/${files[index].extension}';
                              uploadTask = FirebaseService.uploadFile(
                                  firebaseStorageDestination,
                                  File(files[index].path.toString()));

                              if(uploadTask == null) return;

                              final snapShot = uploadTask!.whenComplete(() {
                                //TODO start from here
                              });
                            },
                            child: const CircleAvatar(
                              child: Icon(Icons.upload),
                            ),
                          ),
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
