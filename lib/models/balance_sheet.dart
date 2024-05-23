import 'package:hive/hive.dart';
import 'transaction.dart';
import 'balance_sheet_results.dart';

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
      element.removePerson(index);
    }

    results.removePerson(index);
    people.removeAt(index);
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
    for (int i = 0; i < t.debts.length; ++i) {
      if (t.debtors[i]) {
        results.applyTransaction(
            t.currency, t.debts[i], t.creditor, t.amount * multi);
      }
    }
  }

  void removeTransaction(int index) {
    applyTransaction(index, -1);
    ledger.removeAt(index);
  }

  void addCurrency(String s) {
    s = s.substring(0, 3).toUpperCase();
    if (currencies.contains(s)) {
      return;
    }
    currencies.add(s);
  }
}
