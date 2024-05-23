import 'package:hive/hive.dart';
import 'package:tuple/tuple.dart';

part 'balance_sheet_results.g.dart';

@HiveType(typeId: 4)
class KBalanceSheetResults {
  @HiveField(0)
  final Map<Tuple3<int, int, int>, int> _s;

  KBalanceSheetResults(this._s);
  KBalanceSheetResults.defaults() : _s = {};

  void applyTransaction(int curr, int person0, int person1, int amount) {
    if (amount == 0 || person0 == person1) {
      return;
    }

    if (person0 > person1) {
      // int swapping without temporary variable
      person0 ^= person1;
      person1 ^= person0;
      person0 ^= person1;
      // swap transaction
      amount *= -1;
    }
    final key = Tuple3(curr, person0, person1);
    _s[key] = amount + (_s[key] ?? 0);
    // we do not remove keys with 0 values for performance
  }

  void removePerson(int person) {
    _s.removeWhere((key, _) => key.item2 == person || key.item3 == person);
  }
}
