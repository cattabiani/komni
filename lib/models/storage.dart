import 'package:hive/hive.dart';
import 'note.dart';
import 'balance_sheet.dart';

part 'storage.g.dart';

@HiveType(typeId: 0)
class KStorage {
  @HiveField(0)
  List<KNote> notes = [];
  @HiveField(1)
  List<KBalanceSheet> balanceSheets = [];
  @HiveField(2)
  int initScreen = 0;
  @HiveField(3)
  String downloadPath = "";

  KStorage(this.notes, this.balanceSheets, this.initScreen, this.downloadPath);
  KStorage.defaults()
      : notes = [],
        balanceSheets = [],
        initScreen = 0,
        downloadPath = "";
}
