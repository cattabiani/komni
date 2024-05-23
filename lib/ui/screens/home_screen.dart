import 'package:flutter/material.dart';

import 'package:komni/models/storage.dart';
import 'package:komni/ui/screens/note_list_screen.dart';
import 'package:komni/ui/screens/balance_sheet_list_screen.dart';
import 'package:komni/utils/styles.dart';

class KHomeScreen extends StatelessWidget {
  final KStorage storage;

  const KHomeScreen({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('KOmni', style: KStyles.stdTextStyle),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.note), text: 'Notes'),
                Tab(
                    icon: Icon(Icons.account_balance_wallet),
                    text: 'Balance Sheets'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            KNoteListScreen(storage: storage),
            KBalanceSheetListScreen(storage: storage)
          ],
        ),
      ),
    );
  }
}
