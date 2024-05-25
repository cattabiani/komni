import 'package:flutter/material.dart';
import 'package:komni/models/balance_sheet.dart';
import 'package:komni/models/transaction.dart';
import 'package:komni/utils/styles.dart';
import 'package:komni/utils/utils.dart';
import 'package:komni/ui/screens/edit_list_screen.dart';
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
  final FocusNode _amountFocus = FocusNode();
  final double _trailingSizedBox = 120.0;
  late List<TextEditingController> _amountControllerList;
  bool _unequalEditMode = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.transaction.name);
    selectAllText(_nameController);
    _amountController =
        TextEditingController(text: cents2str(widget.transaction.amount, true));
    _nameFocus.requestFocus();

    _amountControllerList = List.generate(
      widget.balanceSheet.people
          .length, // Specify the number of controllers you need
      (_) => TextEditingController(), // Create a new controller for each index
    );
    _updateAmountController();

    _amountFocus.addListener(() {
      if (_amountFocus.hasFocus) {
        selectAllText(_amountController);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _nameFocus.dispose();
    _amountFocus.dispose();
    for (var controller in _amountControllerList) {
      controller.dispose();
    }
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
                  _amountFocus.requestFocus();
                },
              )),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(
                child: Container(
                    padding: KStyles.stdEdgeInsetAmount,
                    child: TextField(
                      focusNode: _amountFocus,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: "Amount", border: OutlineInputBorder()),
                      controller: _amountController,
                      style: KStyles.stdTextStyle,
                      onChanged: (_) {
                        setState(() {
                          widget.transaction.amount =
                              str2cents(_amountController.text);
                          if (!_unequalEditMode) {
                            _distributeEqually();
                          }
                        });
                      },
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                      },
                    ))),
            Container(
                padding: const EdgeInsets.only(
                    left: 0.0, top: 4.0, bottom: 4.0, right: 8.0),
                child: DropdownButton<int>(
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
          Container(
              padding: KStyles.stdEdgeInset,
              child: ListTile(
                  leading: const Text("Creditor"),
                  title: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _distributeEqually();
                      });
                    },
                    child: const Text('Distribute Equally'),
                  ),
                  trailing: SizedBox(
                      width: _trailingSizedBox,
                      child: const Row(children: [
                        Text("Debtor"),
                        KStyles.stdSizedBox,
                        Text("Amount"),
                      ])))),
          Expanded(
              child: ListView.builder(
                  itemCount: widget.balanceSheet.people.length,
                  itemBuilder: (context, index) {
                    final person = widget.balanceSheet.people[index];
                    return Container(
                        padding: KStyles.stdEdgeInset,
                        color: KStyles.altGrey(index),
                        child: ListTile(
                          title: Text(
                            person,
                            style: KStyles.stdTextStyle,
                            textAlign: TextAlign.center,
                          ),
                          leading: Radio<int>(
                              value: index,
                              groupValue: widget.transaction.creditor,
                              onChanged: (int? value) {
                                setState(() {
                                  widget.transaction.creditor = value ?? -1;
                                  if (!_unequalEditMode) {
                                    _distributeEqually();
                                  }
                                });
                              }),
                          trailing: SizedBox(
                            width: _trailingSizedBox,
                            child: Row(children: [
                              Checkbox(
                                value: widget.transaction.debtors[index],
                                onChanged: (value) {
                                  setState(() {
                                    widget.transaction.debtors[index] =
                                        value ?? false;
                                    if (!_unequalEditMode) {
                                      _distributeEqually();
                                    }
                                  });
                                },
                              ),
                              SizedBox(
                                  width: 72,
                                  child: TextField(
                                    readOnly:
                                        !widget.transaction.debtors[index],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                        labelText: "Amount",
                                        border: OutlineInputBorder()),
                                    controller: _amountControllerList[index],
                                    style: KStyles.stdTextStyle,
                                    onEditingComplete: () {
                                      _unequalEdit(index);
                                      FocusScope.of(context).unfocus();
                                    },
                                  ))
                            ]),
                          ),
                        ));
                  })),
        ]),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () async {
              final n = widget.balanceSheet.currencies.length;
              final String s = "C $n";
              final (newVal, edited) = await editItem(context, s);
              if (edited) {
                setState(() {
                  widget.balanceSheet.addCurrency(newVal);
                  widget.transaction.currency = n;
                });
              }
            },
            tooltip: 'Add Currency',
            child: const Icon(Icons.payments_outlined),
          ),
          KStyles.stdSizedBox,
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Confirm',
            child: const Icon(Icons.check),
          ),
        ]));
  }

  void _updateAmountController() {
    for (int i = 0; i < widget.balanceSheet.people.length; ++i) {
      _amountControllerList[i].text =
          cents2str(widget.transaction.debts[i], true);
    }
  }

  void _resetAmountController() {
    for (int i = 0; i < widget.balanceSheet.people.length; ++i) {
      _amountControllerList[i].text = "";
    }
  }

  void _distributeEqually() {
    widget.transaction.distributeEqually();
    _updateAmountController();
  }

  void _unequalEdit(int index) {
    final v = str2cents(_amountControllerList[index].text);
    _amountControllerList[index].text = cents2str(v, true);
    final amount = widget.transaction.amount;

    if (v < 0) {
      const snackBar = SnackBar(
        content: Text('Debts cannot be negative!'),
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return; // Stop execution if value exceeds the limit
    }

    if (!_unequalEditMode) {
      if (v > amount) {
        final snackBar = SnackBar(
          content:
              Text('Value must be below amount: ${cents2str(amount, false)}'),
          duration: const Duration(seconds: 1),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          _amountControllerList[index].text =
              cents2str(widget.transaction.debts[index], true);
        });

        return; // Stop execution if value exceeds the limit
      }

      _resetAmountController();
      _unequalEditMode = true;
      _amountControllerList[index].text = cents2str(v, true);
    }

    int zeroIndex = -2;
    int sum = 0;
    for (int i = 0; i < _amountControllerList.length; ++i) {
      final t = str2cents(_amountControllerList[i].text);
      if (t == 0 && widget.transaction.debtors[i] && i != index) {
        zeroIndex = zeroIndex == -2 ? i : -1;
      }
      sum += t;
    }

    if (sum > amount) {
      final snackBar = SnackBar(
        content: Text(
            'Value must be below amount: ${cents2str(amount - sum + v, false)}'),
        duration: const Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        _amountControllerList[index].text = cents2str(0, true);
      });
      return;
    }

    if (zeroIndex >= 0) {
      _amountControllerList[zeroIndex].text = cents2str(amount - sum, true);
      sum = amount;
    }

    if (sum == amount) {
      setState(() {
        for (int i = 0; i < _amountControllerList.length; ++i) {
          widget.transaction.debts[i] =
              str2cents(_amountControllerList[i].text);
        }
      });
      _unequalEditMode = false;
    }

    if (_unequalEditMode) {
      final snackBar = SnackBar(
        content: Text('Remaining amount: ${cents2str(amount - sum, false)}'),
        duration: const Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // _addCurrency() {
  //         // final n = widget.balanceSheet.currencies.length;
  //         // setState(() {
  //         //   _addCurrency();
  //         //   widget.transaction.currency = n;
  //         // });

  //   final TextEditingController nameController =
  //       TextEditingController();
  //   final nameFocus = FocusNode();

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Edit Currency'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             TextField(
  //               focusNode: nameFocus,
  //               controller: nameController,
  //               style: KStyles.stdTextStyle,
  //               decoration: const InputDecoration(labelText: 'Currency'),
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Save'),
  //             onPressed: () {
  //               ans = true;
  //               balanceSheet.people[index] = nameController.text;
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   ).then((_) {
  //     nameController.dispose();
  //     nameFocus.dispose();
  //   });

  //   nameFocus.requestFocus();
  //   return ans;
  // }
}
