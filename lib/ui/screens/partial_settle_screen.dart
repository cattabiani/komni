import 'package:flutter/material.dart';
import 'package:komni/models/balance_sheet.dart';
import 'package:komni/models/transaction.dart';
import 'package:komni/utils/styles.dart';
import 'package:komni/utils/utils.dart';
import 'package:komni/ui/screens/edit_list_screen.dart';

class KPartialSettleScreen extends StatefulWidget {
  final KBalanceSheet balanceSheet;

  const KPartialSettleScreen({super.key, required this.balanceSheet});

  @override
  State<KPartialSettleScreen> createState() => _KPartialSettleScreenState();
}

class _KPartialSettleScreenState extends State<KPartialSettleScreen> {
  late TextEditingController _amountController;
  final FocusNode _amountFocus = FocusNode();
  int _currency = 0;
  int _giver = 0;
  late int _onBehalfOf;
  int _receiver = 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _onBehalfOf = widget.balanceSheet.people.length;
    selectAllText(_amountController);
    _amountFocus.requestFocus();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partial Settle', style: KStyles.stdTextStyle),
        actions: [
          KStyles.stdButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close)),
          KStyles.stdButton(onPressed: _apply, icon: const Icon(Icons.check)),
        ],
      ),
      body: Column(children: [
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
                      _currency = newIndex ?? -1;
                    });
                  },
                  value: _currency,
                  items: List.generate(
                    widget.balanceSheet.currencies.length,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text(widget.balanceSheet.currencies[index]),
                    ),
                  )))
        ]),
        Container(
            margin: KStyles.stdEdgeInset,
            decoration: KStyles.stdBoxDecoration(16.0),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
              value: _giver,
              items: List.generate(widget.balanceSheet.people.length, (index) {
                return DropdownMenuItem<int>(
                    alignment: Alignment.center,
                    value: index,
                    child: Text(widget.balanceSheet.people[index],
                        style: KStyles.stdTextStyle));
              }),
              onChanged: (int? newValue) {
                setState(() {
                  _giver = newValue ?? -1;
                });
              },
              isExpanded: true,
            ))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.keyboard_arrow_down, size: 48),
          KStyles.stdButton(
              onPressed: () {
                setState(() {
                  // swap
                  _giver ^= _receiver;
                  _receiver ^= _giver;
                  _giver ^= _receiver;
                });
              },
              icon: const Icon(Icons.swap_vert)),
        ]),
        Container(
            margin: KStyles.stdEdgeInset,
            decoration: KStyles.stdBoxDecoration(16.0),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
              value: _receiver,
              items: List.generate(widget.balanceSheet.people.length, (index) {
                return DropdownMenuItem<int>(
                    alignment: Alignment.center,
                    value: index,
                    child: Text(widget.balanceSheet.people[index],
                        style: KStyles.stdTextStyle));
              }),
              onChanged: (int? newValue) {
                setState(() {
                  _receiver = newValue ?? -1;
                });
              },
              isExpanded: true,
            ))),
        const Text("On Behalf Of", style: KStyles.stdTextStyle),
        Container(
            margin: KStyles.stdEdgeInset,
            decoration: KStyles.stdBoxDecoration(16.0),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
              value: _onBehalfOf,
              items:
                  List.generate(widget.balanceSheet.people.length + 1, (index) {
                return DropdownMenuItem<int>(
                    alignment: Alignment.center,
                    value: index,
                    child: index == widget.balanceSheet.people.length
                        ? const Text("")
                        : Text(widget.balanceSheet.people[index],
                            style: KStyles.stdTextStyle));
              }),
              onChanged: (int? newValue) {
                setState(() {
                  _onBehalfOf = newValue ?? widget.balanceSheet.people.length;
                });
              },
              isExpanded: true,
            ))),
      ]),
    );
  }

  void _apply() {
    final int amount = str2cents(_amountController.text);
    if (amount == 0 || _giver == _receiver || _onBehalfOf == _receiver) {
      return;
    }
    final n = widget.balanceSheet.ledger.length;

    if (_onBehalfOf == widget.balanceSheet.people.length) {
      _onBehalfOf = _giver;
    }
    widget.balanceSheet.addOne2oneTransaction(
        "Settle $n", amount, _currency, _onBehalfOf, _receiver);
    if (_onBehalfOf != _giver) {
      widget.balanceSheet.addOne2oneTransaction(
          "Settle ${n + 1}", amount, _currency, _giver, _onBehalfOf);
    }

    Navigator.pop(context);
  }
}
