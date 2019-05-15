import 'package:money/money.dart';

class SetBaseCurrencyAction {
  final Currency baseCurrency;

  SetBaseCurrencyAction(this.baseCurrency);
}

class SetBaseAmountAction {
  final double baseAmount;

  SetBaseAmountAction(this.baseAmount);
}
