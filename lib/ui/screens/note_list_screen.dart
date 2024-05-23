import 'package:flutter/material.dart';
import 'package:komni/models/storage.dart';
import 'package:komni/models/note.dart';
import 'package:komni/utils/styles.dart';

class KNoteListScreen extends StatefulWidget {
  final KStorage storage;

  const KNoteListScreen({super.key, required this.storage});

  @override
  State<KNoteListScreen> createState() => _KNoteListScreenState();
}

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
      // appBar: KAppBar(name: "Notes", storage: widget.storage),
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
                      color: KStyles.altGrey(index),
                      child: Padding(
                          padding: KStyles.stdEdgeInset,
                          child: ListTile(
                            trailing: KStyles.stdDragHandle(index),
                            onTap: () {
                              _editNote(index);
                            },
                            title: Text(widget.storage.notes[index].name,
                                style: KStyles.stdTextStyle),
                            subtitle: widget.storage.notes[index].info == ""
                                ? null
                                : Text(widget.storage.notes[index].info,
                                    style: KStyles.stdTextStyle),
                          ))))
          ]),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          final n = widget.storage.notes.length;
          setState(() {
            widget.storage.notes.add(KNote.defaults("Note $n"));
          });
          _editNote(n);
          // Handle adding new notes here
          // For example, you can navigate to a new screen to add notes
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editNote(int index) {
    final item = widget.storage.notes[index];
    final TextEditingController nameController =
        TextEditingController(text: item.name);
    final TextEditingController infoController =
        TextEditingController(text: item.info);
    final nameFocus = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        nameController.selection = TextSelection(
            baseOffset: 0, extentOffset: nameController.text.length);
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
              ),
              TextField(
                controller: infoController,
                style: KStyles.stdTextStyle,
                decoration: const InputDecoration(labelText: 'Info'),
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
                  item.name = nameController.text;
                  item.info = infoController.text;
                });
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
    });

    nameFocus.requestFocus();
  }
}
