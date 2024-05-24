import 'package:hive/hive.dart';
import 'transaction.dart';
import 'balance_sheet_results.dart';
import 'package:tuple/tuple.dart';

part 'balance_sheet.g.dart';

@HiveType(typeId: 2)
class KBalanceSheet {
  @HiveField(0)
  String name;
  @HiveField(1)
  List<KTransaction> ledger;
  @HiveField(2)
  KBalanceSheetResults results;
  @HiveField(3)
  List<String> people;
  @HiveField(4)
  List<String> currencies;

  KBalanceSheet(
      this.name, this.ledger, this.results, this.people, this.currencies);
  KBalanceSheet.defaults(this.name)
      : ledger = [],
        results = KBalanceSheetResults.defaults(),
        people = ["self"],
        currencies = ["EUR", "CHF"];

  void addPerson() {
    for (var element in ledger) {
      element.addPerson();
    }
    final n = people.length;

    people.add("Person $n");
  }

  void removePerson(int index) {
    for (var element in ledger) {
      // _applyTransaction(element, -1);
      element.removePerson(index);
      // _applyTransaction(element, 1);
    }

    results.removePerson(index);
    people.removeAt(index);
  }

  bool isRemovable(int index) {
    for (int i = 0; i < ledger.length; ++i) {
      if (!ledger[i].isRemovable(index)) return false;
    }

    return true;
  }

  void addTransaction() {
    final n = ledger.length;
    final currency = ledger.isEmpty ? 0 : ledger.last.currency;
    ledger
        .add(KTransaction.defaults("Transaction $n", people.length, currency));
  }

  void insertTransactionAt(int index, KTransaction t) {
    ledger.insert(index, t);
    _applyTransaction(ledger[index], 1);
  }

  void _applyTransaction(KTransaction t, int multi) {
    if (t.creditor < 0) {
      return;
    }
    if (t.amount == 0) {
      return;
    }

    for (int i = 0; i < t.debts.length; ++i) {
      if (t.debtors[i]) {
        results.applyTransaction(t.currency, i, t.creditor, t.debts[i] * multi);
      }
    }
  }

  KTransaction removeTransaction(int index) {
    _applyTransaction(ledger[index], -1);
    return ledger.removeAt(index);
  }

  void addCurrency(String s) {
    s = s.substring(0, 3).toUpperCase();
    if (currencies.contains(s)) {
      return;
    }
    currencies.add(s);
  }

  List<Tuple3<int, int, int>> personRecap(int person) {
    return results.personRecap(person);
  }

  settlePerson(int person, List<Tuple3<int, int, int>> recap) {
    for (int i = 0; i < recap.length; ++i) {
      final curr = recap[i].item1;
      final amount = recap[i].item2 < 0 ? -recap[i].item2 : recap[i].item2;
      final person0 = recap[i].item2 > 0 ? person : recap[i].item3;
      final person1 = recap[i].item2 < 0 ? person : recap[i].item3;
      final debtors = List<bool>.generate(
          people.length, (index) => index == person1,
          growable: true);
      final debts = List<int>.generate(
          people.length, (index) => index == person1 ? amount : 0,
          growable: true);
      final t = KTransaction(
          "Settle ${people[person]} $i", amount, person0, debtors, debts, curr);
      ledger.add(t);
      _applyTransaction(ledger.last, 1);
    }
  }
}
