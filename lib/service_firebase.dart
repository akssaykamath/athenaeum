import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final reference = FirebaseStorage.instance.ref(destination);
      return reference.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}
