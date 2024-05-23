import 'package:flutter/material.dart';
import 'package:komni/ui/widgets/database.dart';

void main() async {
  await KDatabase.initialize();

  runApp(const KNoteApp());
}

class KNoteApp extends StatelessWidget {
  const KNoteApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KOmni',
      home: KDatabase(),
    );
  }
}
