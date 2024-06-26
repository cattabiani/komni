import 'package:flutter/material.dart';
import 'package:komni/models/balance_sheet.dart';
// import 'package:komni/models/transaction.dart';
import 'package:komni/utils/styles.dart';
import 'package:komni/utils/utils.dart';
import 'package:komni/ui/screens/transaction_screen.dart';
import 'package:komni/ui/screens/edit_list_screen.dart';
import 'package:komni/ui/screens/settle_screen.dart';

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
          title: const Text('Edit Balance Sheet', style: KStyles.stdTextStyle),
          actions: [
            KStyles.stdButton(
                onPressed: _settle, icon: const Icon(Icons.handshake_outlined)),
            KStyles.stdButton(
                onPressed: _editCurrency,
                icon: const Icon(Icons.payments_outlined)),
            KStyles.stdButton(
                onPressed: () async {
                  final n = widget.balanceSheet.people.length;
                  final String s = "Person $n";

                  final (newVal, edited) = await editItem(context, s);
                  if (edited) {
                    setState(() {
                      widget.balanceSheet.addPerson(newVal);
                    });
                  }
                },
                icon: const Icon(Icons.person_add)),
            KStyles.stdButton(
                onPressed: () {
                  final n = widget.balanceSheet.ledger.length;
                  setState(() {
                    widget.balanceSheet.addTransaction();
                  });
                  _editTransaction(n);
                },
                icon: const Icon(Icons.add)),
          ]),
      body: Column(children: [
        Container(
            padding: KStyles.stdEdgeInset,
            child: TextField(
              focusNode: _nameFocus,
              controller: _nameController,
              style: KStyles.stdTextStyle,
              onChanged: (String s) {
                widget.balanceSheet.name = s;
              },
              onEditingComplete: () {
                setState(() {
                  widget.balanceSheet.name = _nameController.text;
                });
                FocusScope.of(context).unfocus();
              },
            )),
        Container(
            padding: KStyles.stdEdgeInset,
            color: KStyles.stdGreen,
            child: TextField(
                readOnly: true,
                style: KStyles.stdTextStyle,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "People",
                    hintText: widget.balanceSheet.people.join(", "),
                    hintStyle: KStyles.stdTextStyle),
                onTap: () {
                  _editPeople();
                })),
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
                        widget.balanceSheet.removeTransaction(index);
                      });
                    },
                    background: KStyles.stdBackgroundDelete,
                    child: Container(
                        color: widget.balanceSheet.ledger[index].creditor == -1
                            ? Colors.red[200]
                            : KStyles.altGrey(invIdx(
                                index, widget.balanceSheet.ledger.length)),
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
                                                labelText: widget.balanceSheet
                                                        .currencies[
                                                    widget
                                                        .balanceSheet
                                                        .ledger[index]
                                                        .currency],
                                                hintText: cents2str(
                                                    widget.balanceSheet
                                                        .ledger[index].amount,
                                                    false),
                                                border: InputBorder.none,
                                                hintStyle:
                                                    KStyles.boldTextStyle))),
                                    KStyles.stdSizedBox,
                                    KStyles.stdDragHandle(index)
                                  ])),
                          onTap: () {
                            _editTransaction(index);
                          },
                          title: Text(widget.balanceSheet.ledger[index].name,
                              style: KStyles.stdTextStyle),
                        )))
            ])),
      ]),
    );
  }

  _editTransaction(int index) {
    FocusScope.of(context).unfocus();
    widget.balanceSheet.beginEditTransaction(index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KTransactionScreen(
            balanceSheet: widget.balanceSheet,
            transaction: widget.balanceSheet.ledger[index]),
      ),
    ).then((_) {
      widget.balanceSheet.endEditTransaction();
      setState(() {});
    });
  }

  _editPeople() {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KEditListScreen(
          title: "People",
          l: widget.balanceSheet.people,
          icon: const Icon(Icons.person_add),
          removeAt: widget.balanceSheet.removePerson,
          newItemBaseName: "Person",
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  _editCurrency() {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KEditListScreen(
          title: "Currencies",
          l: widget.balanceSheet.currencies,
          icon: const Icon(Icons.payments_outlined),
          removeAt: widget.balanceSheet.removeCurrency,
          newItemBaseName: "C",
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  _settle() {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KSettleScreen(
          balanceSheet: widget.balanceSheet,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }
}
