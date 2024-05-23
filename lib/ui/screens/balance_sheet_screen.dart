import 'package:flutter/material.dart';
import 'package:komni/models/balance_sheet.dart';
import 'package:komni/utils/styles.dart';
import 'package:komni/utils/utils.dart';
import 'package:komni/ui/screens/transaction_screen.dart';

class KBalanceSheetScreen extends StatefulWidget {
  final KBalanceSheet balanceSheet;

  const KBalanceSheetScreen({super.key, required this.balanceSheet});

  @override
  State<KBalanceSheetScreen> createState() => _KBalanceSheetScreenState();
}

class _KBalanceSheetScreenState extends State<KBalanceSheetScreen> {
  late TextEditingController _nameController;
  final FocusNode _nameFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.balanceSheet.name);
    selectAllText(_nameController);
    if (widget.balanceSheet.ledger.isEmpty) {
      _nameFocus.requestFocus();
    }
    
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Edit Balance Sheet', style: KStyles.stdTextStyle)),
      body: Column(children: [
        Container(
            padding: KStyles.stdEdgeInset,
            child: TextField(
              focusNode: _nameFocus,
              controller: _nameController,
              style: KStyles.stdTextStyle,
              onEditingComplete: () {
                setState(() {
                  widget.balanceSheet.name = _nameController.text;
                });
                FocusScope.of(context).unfocus();
              },
            )),
        Expanded(
            child: ReorderableListView(
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final l = widget.balanceSheet.ledger.length - 1;
                    newIndex = l - newIndex;
                    oldIndex = l - oldIndex;
                    final item = widget.balanceSheet.ledger.removeAt(oldIndex);
                    widget.balanceSheet.ledger.insert(newIndex, item);
                  });
                },
                children: [
              for (int index = widget.balanceSheet.ledger.length - 1;
                  index >= 0;
                  --index)
                Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      setState(() {
                        widget.balanceSheet.ledger.removeAt(index);
                      });
                    },
                    background: KStyles.stdBackgroundDelete,
                    child: Container(
                        color: KStyles.altGrey(
                            widget.balanceSheet.ledger.length - index - 1),
                        child: Padding(
                            padding: KStyles.stdEdgeInset,
                            child: ListTile(
                              trailing: SizedBox(
                                  width: 120,
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                            flex: 1,
                                            child: TextField(
                                                readOnly: true,
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                    floatingLabelAlignment:
                                                        FloatingLabelAlignment
                                                            .center,
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .always,
                                                    labelText: widget
                                                            .balanceSheet
                                                            .currencies[
                                                        widget
                                                            .balanceSheet
                                                            .ledger[index]
                                                            .currency],
                                                    hintText: cents2str(
                                                        widget
                                                            .balanceSheet
                                                            .ledger[index]
                                                            .amount,
                                                        false),
                                                    border: InputBorder.none,
                                                    hintStyle: KStyles
                                                        .boldTextStyle))),
                                        KStyles.stdSizedBox,
                                        KStyles.stdDragHandle(index)
                                      ])),
                              onTap: () {
                                _editTransaction(index);
                              },
                              title: Text(
                                  widget.balanceSheet.ledger[index].name,
                                  style: KStyles.stdTextStyle),
                            ))))
            ])),
      ]),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          final n = widget.balanceSheet.ledger.length;
          setState(() {
            widget.balanceSheet.addTransaction();
          });
          _editTransaction(n);
        },
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  _editTransaction(int index) {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KTransactionScreen(
            balanceSheet: widget.balanceSheet,
            transaction: widget.balanceSheet.ledger[index]),
      ),
    ).then((_) {
      setState(() {});
    });
  }
}
