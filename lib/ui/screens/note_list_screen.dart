import 'package:flutter/material.dart';
import 'package:komni/models/storage.dart';
import 'package:komni/models/note.dart';
import 'package:komni/utils/styles.dart';
import 'package:komni/utils/utils.dart';
// import 'package:komni/utils/utils.dart';

class KNoteListScreen extends StatefulWidget {
  final KStorage storage;
  // final Future<void> Function() saveFun;

  const KNoteListScreen(
      {super.key, required this.storage}); //, required this.saveFun});

  @override
  State<KNoteListScreen> createState() => _KNoteListScreenState();
}

// with SaveStateMixin<KNoteListScreen>
class _KNoteListScreenState extends State<KNoteListScreen> {
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
      appBar: AppBar(actions: [
        KStyles.stdButton(
            onPressed: () async {
              final n = widget.storage.notes.length;
              final note = KNote.defaults("Note $n");
              final bool edited = await _editNote(note);
              if (edited) {
                setState(() {
                  widget.storage.notes.add(note);
                });
              }
            },
            icon: const Icon(Icons.add)),
      ]),
      body: ReorderableListView(
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final l = widget.storage.notes.length - 1;
              newIndex = l - newIndex;
              oldIndex = l - oldIndex;
              final item = widget.storage.notes.removeAt(oldIndex);
              widget.storage.notes.insert(newIndex, item);
            });
          },
          children: [
            for (int index = widget.storage.notes.length - 1;
                index >= 0;
                --index)
              Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {
                    setState(() {
                      widget.storage.notes.removeAt(index);
                    });
                  },
                  background: KStyles.stdBackgroundDelete,
                  child: Container(
                      color: KStyles.altGrey(
                          invIdx(index, widget.storage.notes.length)),
                      child: ListTile(
                        trailing: KStyles.stdDragHandle(index),
                        onTap: () async {
                          final note = widget.storage.notes[index];
                          final bool edited = await _editNote(note);
                          if (edited) setState(() {});
                        },
                        title: Text(widget.storage.notes[index].name,
                            style: KStyles.boldTextStyle),
                        subtitle: widget.storage.notes[index].info == ""
                            ? null
                            : Text(widget.storage.notes[index].info,
                                style: KStyles.stdTextStyle),
                      )))
          ]),
    );
  }

  Future<bool> _editNote(KNote item) async {
    final TextEditingController nameController =
        TextEditingController(text: item.name);
    final TextEditingController infoController =
        TextEditingController(text: item.info);
    final nameFocus = FocusNode();
    final infoFocus = FocusNode();

    bool edited = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        selectAllText(nameController);
        nameFocus.requestFocus();
        return AlertDialog(
          title: const Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                focusNode: nameFocus,
                controller: nameController,
                style: KStyles.stdTextStyle,
                decoration: const InputDecoration(labelText: 'Name'),
                onEditingComplete: () {
                  selectAllText(infoController);
                  infoFocus.requestFocus();
                },
              ),
              TextField(
                focusNode: infoFocus,
                controller: infoController,
                style: KStyles.stdTextStyle,
                decoration: const InputDecoration(labelText: 'Info'),
                onEditingComplete: () {
                  infoFocus.unfocus();
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
                item.name = nameController.text;
                item.info = infoController.text;
                edited = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      infoController.dispose();
      nameFocus.dispose();
      infoFocus.dispose();
    });

    nameFocus.requestFocus();
    return edited;
  }
}
