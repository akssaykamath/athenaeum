import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static Reference? uploadFile(String destination, File file) {
    try {
      final reference = FirebaseStorage.instance.ref(destination);
      final UploadTask uploadTask = reference.putFile(file);
      return reference;
    } on FirebaseException catch (e) {
      return null;
    }
  }
}
