import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3)
class KTransaction {
  @HiveField(0)
  String name;
  @HiveField(1)
  int amount;
  @HiveField(2)
  int creditor;
  @HiveField(3)
  List<bool> debtors;
  @HiveField(4)
  List<int> debts;
  @HiveField(5)
  int currency;

  KTransaction(this.name, this.amount, this.creditor, this.debtors, this.debts,
      this.currency);
  KTransaction.copy(KTransaction other)
      : name = other.name,
        amount = other.amount,
        creditor = other.creditor,
        debtors = other.debtors,
        debts = other.debts,
        currency = other.currency;
  KTransaction.defaults(this.name, int n, this.currency)
      : amount = 0,
        creditor = 0,
        debtors = List<bool>.generate(n, (_) => true, growable: true),
        debts = List<int>.generate(n, (_) => 0, growable: true);

  KTransaction.one2one(
      this.name, this.amount, this.currency, this.creditor, int n, int debtor)
      : debtors = List<bool>.generate(n, (i) => (i == debtor), growable: true),
        debts = List<int>.generate(n, (i) => (i == debtor) ? amount : 0,
            growable: true);

  void one2one(
      String name_, int amount_, int currency_, int creditor_, int debtor_) {
    name = name_;
    amount = amount_;
    currency = currency_;
    creditor = creditor_;
    for (int i = 0; i < debts.length; ++i) {
      debtors[i] = (i == debtor_);
      debts[i] = i == debtor_ ? amount_ : 0;
    }
  }

  void addPerson() {
    debtors.add(false);
    debts.add(0);
  }

  void removePerson(int index) {
    final wasDebtor = debtors[index];
    final debt = debts[index];
    debtors.removeAt(index);
    debts.removeAt(index);

    if (creditor == index) {
      creditor = -1;
    } else if (creditor > index) {
      --creditor;
    }

    if (wasDebtor && creditor != -1) {
      amount -= debt;
    }
  }

  void removeCurrency(int index) {
    if (currency == index) {
      currency = -1;
    } else if (currency > index) {
      --currency;
    }
  }

  bool isPersonRemovable(int index) {
    return creditor != index && (!debtors[index] || debts[index] == 0);
  }

  bool isCurrencyRemovable(int index) {
    return currency != index;
  }

  void distributeEqually() {
    final n = debtors.where((element) => element).length;
    if (n == 0) {
      return;
    }

    final baseShare = amount ~/ n;
    int nHighShare = amount % n;
    for (int i = 0; i < debts.length; ++i) {
      if (debtors[i]) {
        debts[i] = baseShare;
        if (nHighShare > 0 && i != creditor) {
          --nHighShare;
          debts[i] += 1;
        }
      } else {
        debts[i] = 0;
      }
    }
  }
}
