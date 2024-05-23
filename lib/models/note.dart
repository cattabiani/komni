import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 1)
class KNote {
  @HiveField(0)
  String name;
  @HiveField(1)
  String info;

  KNote(this.name, this.info);
  KNote.defaults(this.name) : info = "";
}
