import 'package:flutter/material.dart';
import 'package:komni/models/balance_sheet.dart';
import 'package:komni/utils/styles.dart';
import 'package:komni/utils/utils.dart';
import 'package:tuple/tuple.dart';

class KSettleScreen extends StatefulWidget {
  final KBalanceSheet balanceSheet;

  const KSettleScreen({super.key, required this.balanceSheet});

  @override
  State<KSettleScreen> createState() => _KSettleScreenState();
}

class _KSettleScreenState extends State<KSettleScreen> {
  int _person = 0;
  List<Tuple3<int, int, int>> _recap = [];

  @override
  void initState() {
    super.initState();
    _update(0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settle', style: KStyles.stdTextStyle)),
      body: Column(children: [
        Padding(
            padding: KStyles.stdEdgeInsetAmount,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                  color: KStyles.stdGrey,
                ),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                  value: _person,
                  items:
                      List.generate(widget.balanceSheet.people.length, (index) {
                    return DropdownMenuItem<int>(
                        alignment: Alignment.center,
                        value: index,
                        child: Text(widget.balanceSheet.people[index],
                            style: KStyles.stdTextStyle));
                  }),
                  onChanged: (int? newValue) {
                    setState(() {
                      _update(newValue ?? 0);
                    });
                  },
                  isExpanded: true,
                )))),
        Expanded(
            child: ListView.builder(
          itemCount: _recap.length,
          itemBuilder: (context, index) {
            final v = _recap[index];
            final curr = widget.balanceSheet.currencies[v.item1];
            final amount = v.item2;
            final person1 = widget.balanceSheet.people[v.item3];
            final person0 = widget.balanceSheet.people[_person];

            return _buildRecapLine(
                curr: curr,
                amount: amount,
                person0: person0,
                person1: person1,
                index: index);
          },
        )),
      ]),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          _showSettleConfirmationDialog();
        },
        tooltip: 'Settle',
        child: const Icon(Icons.handshake_outlined),
      ),
    );
  }

  void _update(int newValue) {
    _person = newValue;
    _recap = widget.balanceSheet.personRecap(_person);
  }

  Widget _buildRecapLine(
      {required String curr,
      required String person0,
      required String person1,
      required int amount,
      required int index}) {
    final backgroundColor = KStyles.altGrey(index);
    final textStyle =
        amount < 0 ? KStyles.greenTextStyle : KStyles.redTextStyle;
    final arrowColor = amount < 0 ? Colors.green : Colors.red;
    final arrowIcon = amount > 0 ? Icons.arrow_forward : Icons.arrow_back;

    final val = amount < 0 ? -amount : amount;

    final title = RichText(
        text: TextSpan(children: [
      TextSpan(text: "$person0  ", style: textStyle),
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(
          arrowIcon,
          size: 30, // Adjust the size sas needed
          color: arrowColor,
        ),
      ),
      TextSpan(text: "  $person1", style: textStyle)
    ]));
    final trailing = Text("${cents2str(val, true)} $curr", style: textStyle);

    return Container(
        color: backgroundColor,
        child: ListTile(title: title, trailing: trailing));
  }

  void _showSettleConfirmationDialog() {
    const base = Text('Settle for:', style: KStyles.stdTextStyle);
    final personText =
        Text(widget.balanceSheet.people[_person], style: KStyles.boldTextStyle);
    // const qm = TextSpan(text: '?', style: KStyles.stdTextStyle);
    final t = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [base, personText]);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(content: t, actions: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  setState(() {
                    // Replace with your actual logic
                    widget.balanceSheet.settlePerson(_person, _recap);
                    _update(_person);
                  });
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
            ],
          )
        ]);
      },
    );
  }
}
