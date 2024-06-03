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
  @HiveField(5)
  int isEditTransactionMode;

  KBalanceSheet(this.name, this.ledger, this.results, this.people,
      this.currencies, this.isEditTransactionMode) {
    endEditTransaction();
  }

  void beginEditTransaction(int index) {
    if (index < 0 || index >= ledger.length) return;
    if (isEditTransactionMode >= 0) {
      endEditTransaction();
    }

    isEditTransactionMode = index;
    applyTransaction(isEditTransactionMode, -1);
  }

  void endEditTransaction() {
    if (isEditTransactionMode >= 0) {
      applyTransaction(isEditTransactionMode, 1);
      isEditTransactionMode = -1;
    }
  }

  KBalanceSheet.defaults(this.name)
      : ledger = [],
        results = KBalanceSheetResults.defaults(),
        people = ["self"],
        currencies = ["EUR", "CHF"],
        isEditTransactionMode = -1;

  void addPerson(String s) {
    for (var element in ledger) {
      element.addPerson();
    }
    people.add(s);
  }

  void removePerson(int index) {
    for (var element in ledger) {
      element.removePerson(index);
    }

    results.removePerson(index);
    people.removeAt(index);
  }

  void removeCurrency(int index) {
    for (var element in ledger) {
      element.removeCurrency(index);
    }

    results.removeCurrency(index);
    currencies.removeAt(index);
  }

  bool isPersonRemovable(int index) {
    for (int i = 0; i < ledger.length; ++i) {
      if (!ledger[i].isPersonRemovable(index)) return false;
    }

    return true;
  }

  bool isCurrencyRemovable(int index) {
    for (int i = 0; i < ledger.length; ++i) {
      if (!ledger[i].isCurrencyRemovable(index)) return false;
    }

    return true;
  }

  void addOne2oneTransaction(
      String name_, int amount_, int currency_, int creditor_, int debtor_) {
    final n = ledger.length;
    addTransaction();
    ledger[n].one2one(name_, amount_, currency_, creditor_, debtor_);
    applyTransaction(n, 1);
  }

  void addTransaction() {
    final n = ledger.length;
    final currency = ledger.isEmpty ? 0 : ledger.last.currency;
    ledger
        .add(KTransaction.defaults("Transaction $n", people.length, currency));
  }

  void applyTransaction(int index, int multi) {
    final t = ledger[index];
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
    applyTransaction(index, -1);
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
      applyTransaction(ledger.length - 1, 1);
    }
  }
}
