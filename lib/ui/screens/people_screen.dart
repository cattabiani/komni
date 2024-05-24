import 'package:flutter/material.dart';
import 'package:komni/models/balance_sheet.dart';
import 'package:komni/utils/styles.dart';

class KPeopleScreen extends StatefulWidget {
  final KBalanceSheet balanceSheet;

  const KPeopleScreen({super.key, required this.balanceSheet});

  @override
  State<KPeopleScreen> createState() => _KPeopleScreenState();
}

class _KPeopleScreenState extends State<KPeopleScreen> {
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
      appBar:
          AppBar(title: const Text('Edit People', style: KStyles.stdTextStyle)),
      body: ListView.builder(
          itemCount: widget.balanceSheet.people.length,
          itemBuilder: (context, index) {
            return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  setState(() {
                    if (widget.balanceSheet.isRemovable(index)) {
                      widget.balanceSheet.removePerson(index);
                    } else {
                      // Showing error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '"${widget.balanceSheet.people[index]}" is involved in some transactions and cannot be removed.'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  });
                },
                background: KStyles.stdBackgroundDelete,
                child: Container(
                    color: KStyles.altGrey(index),
                    child: ListTile(
                        title: Text(
                          widget.balanceSheet.people[index],
                          style: KStyles.stdTextStyle,
                        ),
                        onTap: () {
                          setState(() {
                            _editPerson(index);
                          });
                        })));
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          final n = widget.balanceSheet.people.length;
          setState(() {
            widget.balanceSheet.addPerson();
          });
          _editPerson(n);
        },
        tooltip: 'Add Person',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _editPerson(int index) {
    final person = widget.balanceSheet.people[index];
    final TextEditingController nameController =
        TextEditingController(text: person);
    final nameFocus = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        nameController.selection = TextSelection(
            baseOffset: 0, extentOffset: nameController.text.length);
        return AlertDialog(
          title: const Text('Edit Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                focusNode: nameFocus,
                controller: nameController,
                style: KStyles.stdTextStyle,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  widget.balanceSheet.people[index] = nameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      nameFocus.dispose();
    });

    nameFocus.requestFocus();
  }
}
