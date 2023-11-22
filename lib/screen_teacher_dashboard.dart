import 'dart:io';
import 'dart:ui';

import 'package:athenaeum/app_constants.dart';
import 'package:athenaeum/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List<PlatformFile> files = [];
  List<PlatformFile> filesList = [];
  UploadTask? uploadTask;
  CollectionReference? fireStoreReference;
  List<Map<String, dynamic>> uploadData = [];
  bool showLoader = false;

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
      floatingActionButton: GestureDetector(
        onTap: () async {
          if (filesList.isEmpty) {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );

            if (result != null) {
              setState(() {
                filesList = result.files
                    .map((file) => PlatformFile(
                        name: file.name, size: file.size, path: file.path))
                    .toList();
              });
            } else {
              // User canceled the picker
            }
          } else {
            setState(() {
              showLoader = true;
            });
            files = filesList;
            await Future.wait(
                files.map((file) async => await uploadFile(file)));
            for (var item in uploadData) {
              fireStoreReference!.add(item);
            }
            files.clear();
            uploadData.clear();
            setState(() {
              showLoader = false;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.circular(8.0)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            filesList.isNotEmpty ? "UPLOAD ALL" : "SELECT FILES",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
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
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: const AbsorbPointer(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        return snapshot.data!.size == 0
                            ? Center(
                                child: LottieBuilder.asset(
                                    "assets/empty_list.json"),
                              )
                            : ListView.builder(
                                itemCount: snapshot.data!.size,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        RouteConstants.pdfPage,
                                        arguments: snapshot.data!.docs[index]
                                            .get('url'));
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.deepPurple,
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
                                                          color: Colors
                                                              .deepPurpleAccent,
                                                        ),
                                                        const SizedBox(
                                                          width: 4.0,
                                                        ),
                                                        Text(DateFormat(
                                                                'dd-MMM-yyy')
                                                            .format(snapshot
                                                                .data!
                                                                .docs[index]
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
                                                          color: Colors
                                                              .deepPurpleAccent,
                                                        ),
                                                        const SizedBox(
                                                          width: 4.0,
                                                        ),
                                                        Text(DateFormat('kk:mm')
                                                            .format(snapshot
                                                                .data!
                                                                .docs[index]
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
          Positioned(
            bottom: 0,
            child: filesList.isEmpty
                ? const SizedBox()
                : Container(
                    color: Colors.white,
                    height: 96,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filesList.length,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(right: 4.0),
                        width: 96,
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    const Icon(
                                      Icons.picture_as_pdf_outlined,
                                      size: 40,
                                    ),
                                    Text(
                                      filesList[index].name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      showLoader = true;
                                    });

                                    await Future.wait(
                                        files.map((file) => uploadFile(file)));
                                    List<Map<String, dynamic>> result =
                                        uploadData
                                            .where((element) => element[
                                                'name' == files[index].name])
                                            .toList();
                                    fireStoreReference!.add(result[0]);
                                    uploadData.remove(result[0]);
                                    setState(() {
                                      showLoader = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: const Text(
                                      "UPLOAD",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    filesList.removeAt(index);
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          showLoader
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox()
        ],
      ),
    );
  }

  Future uploadFile(PlatformFile file) async {
    final String firebaseFolder = "pdf/${file.name}";
    final uploadFile = File(file.path!);
    final storageReference =
        FirebaseStorage.instance.ref().child(firebaseFolder);
    uploadTask = storageReference.putFile(uploadFile);
    await uploadTask!.whenComplete(() {});
    String data = await storageReference.getDownloadURL();
    uploadData.add({
      "name": file.name,
      "size": "${file.size * 0.001} kb",
      "url": data,
      "extension": file.extension,
      "dateTime": DateTime.now(),
    });
    setState(() {
      filesList.remove(file);
    });

    return data;
  }
}
