import 'package:flutter/material.dart';
import 'package:komni/models/balance_sheet.dart';
import 'package:komni/models/transaction.dart';
import 'package:komni/utils/styles.dart';
import 'package:komni/utils/utils.dart';
// import 'package:komni/utils/utils.dart';

class KTransactionScreen extends StatefulWidget {
  final KBalanceSheet balanceSheet;
  final KTransaction transaction;

  const KTransactionScreen(
      {super.key, required this.balanceSheet, required this.transaction});

  @override
  State<KTransactionScreen> createState() => _KTransactionScreenState();
}

class _KTransactionScreenState extends State<KTransactionScreen> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  final FocusNode _nameFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.transaction.name);
    selectAllText(_nameController);
    _amountController =
        TextEditingController(text: cents2str(widget.transaction.amount, true));
    _nameFocus.requestFocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Edit Transaction', style: KStyles.stdTextStyle)),
      body: Column(children: [
        Container(
            padding: KStyles.stdEdgeInset,
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              style: KStyles.stdTextStyle,
              onEditingComplete: () {
                setState(() {
                  widget.transaction.name = _nameController.text;
                });
                FocusScope.of(context).unfocus();
              },
            )),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Expanded(child: Container(
              padding: KStyles.stdEdgeInsetAmount,
              child:  TextField(
                decoration: const InputDecoration(
                    labelText: "Amount", border: OutlineInputBorder()),
                controller: _amountController,
                style: KStyles.stdTextStyle,
                onEditingComplete: () {
                  setState(() {
                    widget.transaction.amount = str2cents(_amountController.text);
                  });
                  FocusScope.of(context).unfocus();
                },
              ))),
          Container(padding: const EdgeInsets.only(left: 0.0, top: 4.0, bottom: 4.0, right: 8.0), child: DropdownButton<int>(
              onChanged: (int? newIndex) {
                setState(() {
                  widget.transaction.currency = newIndex ?? 0;
                });
              },
              value: widget.transaction.currency,
              items: List.generate(
                widget.balanceSheet.currencies.length,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text(widget.balanceSheet.currencies[index]),
                ),
              )))
        ]),
        ElevatedButton(
          onPressed: () {
            setState(() {
              widget.transaction.distributeEqually();
            });
          },
          child: const Text('Distribute Equally'),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: widget.balanceSheet.people.length,
                itemBuilder: (context, index) {
                  final person = widget.balanceSheet.people[index];
                  return Container(
                      padding: KStyles.stdEdgeInset,
                      color: KStyles.altGrey(index),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              person,
                              style: KStyles.stdTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ]));
                })),
      ]),
      // floatingActionButton: FloatingActionButton(
      //   heroTag: null,
      //   onPressed: () {
      //     final n = widget.balanceSheet.ledger.length;
      //     setState(() {
      //       widget.balanceSheet.addTransaction();
      //     });
      //     _editTransaction(n);
      //   },
      //   tooltip: 'Add Transaction',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  // _editTransaction(int index) {
  //   // Navigator.push(KBalanceSheetScreen(balanceSheet: widget.balanceSheet))
  // }
}
