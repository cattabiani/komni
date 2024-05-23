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

  KStorage(this.notes, this.balanceSheets);
  KStorage.defaults()
      : notes = [],
        balanceSheets = [];
}
