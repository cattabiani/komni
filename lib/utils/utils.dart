import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

String cents2str(int cents, bool is0empty, {int truncate = -1}) {
  if (is0empty && cents == 0) {
    return '';
  }
  var v = "${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}";
  if (truncate > 0 && truncate < v.length) {
    v = v.substring(0, truncate);
  }
  return v;
}

int str2cents(String value) {
  if (value.isEmpty) return 0;

  // Split the input by the decimal point
  final parts = value.split('.');
  // Extract the dollars and cents parts
  String dollars = parts[0];
  String cents = parts.length > 1 ? parts[1] : '';

  // If the cents part is empty or has only one digit, append a zero
  cents = cents.padRight(2, '0');

  // If the cents part has more than two digits, take only the first two
  if (cents.length > 2) {
    cents = cents.substring(0, 2);
  }

  // Combine dollars and cents with a decimal point
  final cleanedValue = '$dollars.$cents'.replaceAll(RegExp('[^0-9]'), '');

  // Parse the cleaned value as an integer
  return cleanedValue.isEmpty ? 0 : int.parse(cleanedValue);
}

int bool2int(bool v) {
  return v ? 1 : 0;
}

void selectAllText(TextEditingController controller) {
  controller.selection = TextSelection(
    baseOffset: 0,
    extentOffset: controller.text.length,
  );
}

// Define the mixin class
mixin SaveStateMixin<T extends StatefulWidget> on State<T> {
  // Original setState method
  @override
  void setState(VoidCallback fn) {
    (widget as dynamic).saveFun(); // Call save function
    super.setState(fn); // Call original setState
  }
}

int invIdx(int idx, int l) {
  return l - idx - 1;
}

Future<String> getPath(String dir, String name, String ext) async {
  final PermissionStatus status = await Permission.storage.request();

  if (status != PermissionStatus.granted) {
    throw "$status";
  }

  final Directory directory = Directory(dir);
  if (!await directory.exists()) {
    throw 'Directory "${directory.path}" does not exist';
  }

  String basePath = path.join(dir, name);
  String fullPath = '$basePath.$ext';
  int counter = 1;

  while (await File(fullPath).exists()) {
    fullPath = '$basePath($counter).$ext';
    counter++;
  }

  return fullPath;
}

String sanitize(String s) {
  return s
      .replaceAll(r'\', '')
      .replaceAll('/', '')
      .replaceAll('*', '')
      .replaceAll('?', '')
      .replaceAll('"', '')
      .replaceAll('<', '')
      .replaceAll('>', '')
      .replaceAll('|', '')
      .replaceAll(' ', '_');
}
