import 'dart:io';

import 'package:athenaeum/provider/google_sign_in.dart';
import 'package:athenaeum/service_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<PlatformFile> files = [];

  final firebaseStorage = FirebaseStorage.instance;
  final user = FirebaseAuth.instance.currentUser;
  String firebaseStorageFolder = '';

  @override
  void initState() {
    firebaseStorageFolder = user!.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                .map((file) => PlatformFile(
                    name: file.name, size: file.size, path: file.path))
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 16.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    final provider = Provider.of<GoogleSignInProvider>(context,
                        listen: false);
                    provider.googleLogout();
                  },
                  child: Row(
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
                            user!.email.toString(),
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
                        backgroundImage:
                            NetworkImage(user!.photoURL.toString()),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16.0,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Your Uploaded List'),
            ),
            Expanded(
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc("${user!.uid}/uploadFiles")
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text("Something went wrong");
                  }

                  if (snapshot.hasData && !snapshot.data!.exists) {
                    return Text("Document does not exist");
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return ListView.builder(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  onTap: () async {
                                    try {
                                      final reference = firebaseStorage
                                          .ref('files/${files[index].name}');
                                      final UploadTask uploadTask =
                                          reference.putFile(File(
                                              files[index].path.toString()));

                                      uploadTask.snapshotEvents.listen(
                                          (TaskSnapshot taskSnapshot) async {
                                        switch (taskSnapshot.state) {
                                          case TaskState.running:
                                            final progress = 100.0 *
                                                (taskSnapshot.bytesTransferred /
                                                    taskSnapshot.totalBytes);
                                            print(
                                                "Upload is $progress% complete.");
                                            break;
                                          case TaskState.paused:
                                            print("Upload is paused.");
                                            break;
                                          case TaskState.canceled:
                                            print("Upload was canceled");
                                            break;
                                          case TaskState.error:
                                            // Handle unsuccessful uploads
                                            break;
                                          case TaskState.success:
                                            {
                                              String downloadUrl =
                                                  await taskSnapshot.ref
                                                      .getDownloadURL();
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user!.uid)
                                                  .collection('uploadFiles')
                                                  .add({
                                                files[index].name: downloadUrl
                                              });
                                            }
                                            break;
                                        }
                                      });
                                    } on FirebaseException catch (e) {
                                      print('FIREBASE EXCEPTION');
                                      return;
                                    }
                                  },
                                  child: const CircleAvatar(
                                    child: Icon(Icons.upload),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  }

                  return Text("loading");
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Upload List'),
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
                            onTap: () async {
                              try {
                                final reference = firebaseStorage
                                    .ref('files/${files[index].name}');
                                final UploadTask uploadTask = reference.putFile(
                                    File(files[index].path.toString()));

                                uploadTask.snapshotEvents
                                    .listen((TaskSnapshot taskSnapshot) {
                                  switch (taskSnapshot.state) {
                                    case TaskState.running:
                                      final progress = 100.0 *
                                          (taskSnapshot.bytesTransferred /
                                              taskSnapshot.totalBytes);
                                      print("Upload is $progress% complete.");
                                      break;
                                    case TaskState.paused:
                                      print("Upload is paused.");
                                      break;
                                    case TaskState.canceled:
                                      print("Upload was canceled");
                                      break;
                                    case TaskState.error:
                                      // Handle unsuccessful uploads
                                      break;
                                    case TaskState.success:
                                      // Handle successful uploads on complete
                                      // ...
                                      break;
                                  }
                                });
                              } on FirebaseException catch (e) {
                                print('FIREBASE EXCEPTION');
                                return;
                              }
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
