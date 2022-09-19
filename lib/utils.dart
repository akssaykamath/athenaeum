import 'dart:async';
import 'dart:js_util/js_util_wasm.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Utils {
  static StreamTransformer streamTransformer<T>(
          T Function(Map<String, dynamic> json) fromJson) =>
      StreamTransformer<QuerySnapshot, List<T>>.fromHandlers(
        handleData: (QuerySnapshot data, EventSink<List<T>> sink) {
          final snaps = data.docs.map((doc) => doc.data()).toList();
          final users = snaps
              .map((json) => fromJson(
                  Map<String, dynamic>.from(json as Map<String, dynamic>)))
              .toList();

          sink.add(users);
        },
      );

  static DateTime? toDateTime(Timestamp value) {
    if (value == null) return null;

    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }
}
