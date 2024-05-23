import 'package:flutter/material.dart';
import 'package:komni/models/balance_sheet.dart';
import 'package:komni/models/storage.dart';
import 'package:komni/utils/styles.dart';
import 'package:komni/ui/screens/balance_sheet_screen.dart';

class KBalanceSheetListScreen extends StatefulWidget {
  final KStorage storage;

  const KBalanceSheetListScreen({super.key, required this.storage});

  @override
  State<KBalanceSheetListScreen> createState() =>
      _KBalanceSheetListScreenState();
}

class _KBalanceSheetListScreenState extends State<KBalanceSheetListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReorderableListView(
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final l = widget.storage.balanceSheets.length - 1;
              newIndex = l - newIndex;
              oldIndex = l - oldIndex;
              final item = widget.storage.balanceSheets.removeAt(oldIndex);
              widget.storage.balanceSheets.insert(newIndex, item);
            });
          },
          children: [
            for (int index = widget.storage.balanceSheets.length - 1;
                index >= 0;
                --index)
              Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {
                    setState(() {
                      widget.storage.balanceSheets.removeAt(index);
                    });
                  },
                  background: KStyles.stdBackgroundDelete,
                  child: Container(
                      color: KStyles.altGrey(
                          widget.storage.balanceSheets.length - index - 1),
                      child: Padding(
                          padding: KStyles.stdEdgeInset,
                          child: ListTile(
                            trailing: KStyles.stdDragHandle(index),
                            onTap: () {
                              _editBalanceSheet(index);
                            },
                            title: Text(
                                widget.storage.balanceSheets[index].name,
                                style: KStyles.stdTextStyle),
                          ))))
          ]),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          final n = widget.storage.balanceSheets.length;
          setState(() {
            widget.storage.balanceSheets
                .add(KBalanceSheet.defaults("Balance Sheet $n"));
          });
          _editBalanceSheet(n);
        },
        tooltip: 'Add Balance Sheet',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editBalanceSheet(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KBalanceSheetScreen(
          balanceSheet: widget.storage.balanceSheets[index],
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }
}
