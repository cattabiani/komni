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
    // print("Apply: $curr, $person0, $person1, $amount");
    if (amount == 0 || person0 == person1 || person0 < 0 || person1 < 0) {
      return;
    }
    // print("continued");

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
    // print("remove person $person");
    final Map<Tuple3<int, int, int>, int> modifiedMap = {};

    _s.forEach((key, value) {
      var item2 = key.item2;
      var item3 = key.item3;
      if (item2 != person && item3 != person) {
        if (item2 > person) item2--;
        if (item3 > person) item3--;

        final modifiedKey = Tuple3(key.item1, item2, item3);
        modifiedMap[modifiedKey] = value;
      }
    });

    _s.clear();
    _s.addAll(modifiedMap);
  }

  void removeCurrency(int index) {
    final Map<Tuple3<int, int, int>, int> modifiedMap = {};

    _s.forEach((key, value) {
      var item1 = key.item1;
      if (item1 != index) {
        if (item1 > index) item1--;

        final modifiedKey = Tuple3(item1, key.item2, key.item3);
        modifiedMap[modifiedKey] = value;
      }
    });

    _s.clear();
    _s.addAll(modifiedMap);
  }

  List<Tuple3<int, int, int>> personRecap(int person) {
    final List<Tuple3<int, int, int>> v = [];
    _s.forEach((key, value) {
      if ((key.item2 == person || key.item3 == person) && value != 0) {
        final multi = key.item2 == person ? 1 : -1;
        final other = key.item2 == person ? key.item3 : key.item2;
        v.add(Tuple3(key.item1, multi * value, other));
      }
    });
    v.sort((a, b) {
      if (a.item1 != b.item1) {
        return a.item1.compareTo(b.item1);
      } else if (a.item2 != b.item2) {
        return a.item2.compareTo(b.item2);
      } else {
        return a.item3.compareTo(b.item3);
      }
    });

    return v;
  }
}
