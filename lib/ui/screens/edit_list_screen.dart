import 'package:flutter/material.dart';
import 'package:komni/utils/styles.dart';
import 'dart:async';

import 'package:komni/utils/utils.dart';

class KEditListScreen extends StatefulWidget {
  final List<String> l;
  final bool Function(int index)? isRemovable;
  final void Function(int index)? removeAt;
  final Icon icon;
  final String newItemBaseName;
  final String title;

  const KEditListScreen(
      {super.key,
      required this.l,
      this.isRemovable,
      this.removeAt,
      required this.icon,
      this.newItemBaseName = "Item",
      this.title = "Item"});

  @override
  State<KEditListScreen> createState() => _KEditListScreenState();
}

class _KEditListScreenState extends State<KEditListScreen> {
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
      appBar: AppBar(
          title: Text('Edit ${widget.title}', style: KStyles.stdTextStyle)),
      body: ListView.builder(
          itemCount: widget.l.length,
          itemBuilder: (context, index) {
            return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  setState(() {
                    if (widget.isRemovable == null ||
                        widget.isRemovable!(index)) {
                      if (widget.removeAt != null) {
                        widget.removeAt!(index);
                      } else {
                        widget.l.removeAt(index);
                      }
                    } else {
                      // Showing error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '"${widget.l[index]}" is interacting with other parts of the app and cannot be removed right now. Try removing its interactions and retry.'),
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
                          widget.l[index],
                          style: KStyles.stdTextStyle,
                        ),
                        onTap: () async {
                          final (newVal, edited) =
                              await editItem(context, widget.l[index]);
                          if (edited) {
                            setState(() {
                              widget.l[index] = newVal;
                            });
                          }
                        })));
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          final n = widget.l.length;
          final String s = "${widget.newItemBaseName} $n";

          final (newVal, edited) = await editItem(context, s);
          if (edited) {
            setState(() {
              widget.l.add(newVal);
            });
          }
        },
        tooltip: 'Add',
        child: widget.icon,
      ),
    );
  }
}

Future<(String, bool)> editItem(BuildContext context, String item) async {
  final TextEditingController nameController =
      TextEditingController(text: item);
  final nameFocus = FocusNode();
  bool edited = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      selectAllText(nameController);
      nameFocus.requestFocus();
      return AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              focusNode: nameFocus,
              controller: nameController,
              style: KStyles.stdTextStyle,
              decoration: const InputDecoration(labelText: 'Name'),
              onEditingComplete: () {
                nameFocus.unfocus();
              },
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
              item = nameController.text;
              edited = true;
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
  return (item, edited);
}
