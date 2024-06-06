import 'package:flutter/material.dart';

import 'package:komni/models/storage.dart';
import 'package:komni/ui/screens/note_list_screen.dart';
import 'package:komni/ui/screens/balance_sheet_list_screen.dart';
import 'package:komni/ui/screens/youtube_download_screen.dart';
import 'package:komni/utils/styles.dart';

class KHomeScreen extends StatefulWidget {
  final KStorage storage;

  const KHomeScreen({super.key, required this.storage});

  @override
  State<KHomeScreen> createState() => _KHomeScreenState();
}

// with SaveStateMixin<KHomeScreen>
class _KHomeScreenState extends State<KHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KOmni', style: KStyles.stdTextStyle),
        actions: [
          KStyles.stdButton(
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'KOmni',
                  applicationVersion: '1.0.0',
                  applicationIcon: const FlutterLogo(size: 50),
                  applicationLegalese: '© 2024 Katta',
                );
              },
              icon: const Icon(Icons.info_outline)),
          Container(
              margin: KStyles.stdEdgeInset,
              decoration: KStyles.stdBoxDecoration(16.0),
              constraints: const BoxConstraints(maxWidth: 200),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                value: widget.storage.initScreen,
                items: const [
                  DropdownMenuItem<int>(
                      alignment: Alignment.center,
                      value: 0,
                      child: Text("Notes", style: KStyles.stdTextStyle)),
                  DropdownMenuItem<int>(
                      alignment: Alignment.center,
                      value: 1,
                      child:
                          Text("Balance Sheets", style: KStyles.stdTextStyle)),
                  DropdownMenuItem<int>(
                      alignment: Alignment.center,
                      value: 2,
                      child: Text("Youtube Download",
                          style: KStyles.stdTextStyle)),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    widget.storage.initScreen = newValue!;
                  });
                },
                isExpanded: true,
              ))),
        ],
      ),
      body: _getSelectedScreen(),
    );
  }

  Widget _getSelectedScreen() {
    switch (widget.storage.initScreen) {
      case 1:
        return KBalanceSheetListScreen(storage: widget.storage);
      case 2:
        return KYoutubeDownloadScreen(storage: widget.storage);
      case 0:
      default:
        return KNoteListScreen(storage: widget.storage);
    }
  }
}

// import 'package:flutter/material.dart';

// import 'package:komni/models/storage.dart';
// import 'package:komni/ui/screens/note_list_screen.dart';
// import 'package:komni/ui/screens/balance_sheet_list_screen.dart';
// import 'package:komni/ui/screens/youtube_download_screen.dart';
// import 'package:komni/utils/styles.dart';

// class KHomeScreen extends StatelessWidget {
//   final KStorage storage;
//   // final Future<void> Function() saveFun;

//   const KHomeScreen(
//       {super.key, required this.storage}); //, required this.saveFun});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('KOmni', style: KStyles.stdTextStyle),
//           actions: [
//             KStyles.stdButton(
//                 onPressed: () {
//                   showAboutDialog(
//                     context: context,
//                     applicationName: 'KOmni',
//                     applicationVersion: '1.0.0',
//                     applicationIcon: const FlutterLogo(size: 50),
//                     applicationLegalese: '© 2024 Katta',
//                   );
//                 },
//                 icon: const Icon(Icons.info_outline))
//           ],
//           bottom: const PreferredSize(
//             preferredSize: Size.fromHeight(70),
//             child: TabBar(
//               tabs: [
//                 Tab(icon: Icon(Icons.note), text: 'Notes'),
//                 Tab(
//                     icon: Icon(Icons.account_balance_wallet),
//                     text: 'Balance Sheets'),
//                 Tab(icon: Icon(Icons.download), text: 'Youtube Download'),
//               ],
//             ),
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             KNoteListScreen(storage: storage),
//             KBalanceSheetListScreen(storage: storage),
//             KYoutubeDownloadScreen(storage: storage)
//           ],
//         ),
//       ),
//     );
//   }
// }
