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
  List<KBalanceSheetResults> results;
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

  KBalanceSheet.defaults(this.name)
      : ledger = [],
        results = [],
        people = [],
        currencies = [],
        isEditTransactionMode = -1 {
    addPerson("self");
    addCurrency("EUR");
    addCurrency("CHF");
  }

  void addPerson(String s) {
    for (var r in results) {
      r.addPerson();
    }
    people.add(s);
    for (var t in ledger) {
      t.addPerson();
    }
  }

  bool _isPersonRemovable(int p) {
    bool ans = true;
    for (var r in results) {
      ans = r.isPersonRemovable(p);
      if (ans == false) return false;
    }
    for (var t in ledger) {
      ans = t.isPersonRemovable(p);
      if (ans == false) return false;
    }
    return true;
  }

  bool removePerson(int p) {
    if (_isPersonRemovable(p) == false) return false;
    for (var r in results) {
      r.removePerson(p);
    }
    people.removeAt(p);
    for (var t in ledger) {
      t.removePerson(p);
    }
    return true;
  }

  void addCurrency(String s) {
    s = s.substring(0, 3).toUpperCase();
    results.add(KBalanceSheetResults.defaults(people.length));
    currencies.add(s);
  }

  bool _isCurrencyRemovable(int c) {
    bool ans = results[c].isRemovable();
    if (ans == false) return false;
    for (var t in ledger) {
      ans = t.isCurrencyRemovable(c);
      if (ans == false) return false;
    }
    return true;
  }

  bool removeCurrency(int c) {
    if (_isCurrencyRemovable(c) == false) return false;
    results.removeAt(c);
    currencies.removeAt(c);
    for (var t in ledger) {
      t.removeCurrency(c);
    }
    return true;
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
        results[t.currency].add(i, t.creditor, t.debts[i] * multi);
      }
    }
  }

  KTransaction removeTransaction(int index) {
    applyTransaction(index, -1);
    return ledger.removeAt(index);
  }

  List<List<int>> recapPerson(int person) {
    List<List<int>> ans = [];
    for (int i = 0; i < results.length; ++i) {
      final r = results[i];
      final v = r.recap(person);
      v.sort((a, b) {
        return (a[1] == b[1]) ? a[0].compareTo(b[0]) : a[1].compareTo(b[1]);
      });
      for (var t in v) {
        ans.add([i, t[0], t[1]]);
      }
    }
    return ans;
  }

  void settlePerson(int creditor) {
    final recap = recapPerson(creditor);
    for (int i = 0; i < recap.length; ++i) {
      int amount = recap[i][2];
      if (amount == 0) continue;

      final currency = recap[i][0];
      int debtor = recap[i][1];
      if (amount < 0) {
        (creditor, debtor) = (debtor, creditor);
        amount = -amount;
      }
      final t = KTransaction.one2one(
          "Settle ${people[creditor]} ${ledger.length}", amount, currency, creditor, people.length, debtor);
      ledger.add(t);
      applyTransaction(ledger.length - 1, 1);
    }
  }
}
