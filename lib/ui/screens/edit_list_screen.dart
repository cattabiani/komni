import 'package:flutter/material.dart';
import 'package:komni/utils/styles.dart';
import 'dart:async';

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
                          await editItem(context, index, widget.l);
                          setState(() {});
                        })));
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          final n = widget.l.length;
          widget.l.add("${widget.newItemBaseName} $n");
          await editItem(context, n, widget.l);
          setState(() {});
        },
        tooltip: 'Add',
        child: widget.icon,
      ),
    );
  }
}

Future<void> editItem(BuildContext context, int index, List<String> l) async {
  final item = l[index];
  final TextEditingController nameController =
      TextEditingController(text: item);
  final nameFocus = FocusNode();
  final Completer<void> completer = Completer<void>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      nameController.selection = TextSelection(
          baseOffset: 0, extentOffset: nameController.text.length);
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
              l[index] = nameController.text;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  ).then((_) {
    nameController.dispose();
    nameFocus.dispose();
    completer.complete();
  });

  nameFocus.requestFocus();
  return completer.future;
}
