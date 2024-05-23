import 'package:flutter/material.dart';

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
