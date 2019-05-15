import 'package:money/money.dart';
import 'package:x_rate_monitor/models/models.dart';

class SetBaseCurrencyAction {
  final Currency baseCurrency;

  SetBaseCurrencyAction(this.baseCurrency);
}

class SetBaseAmountAction {
  final double baseAmount;

  SetBaseAmountAction(this.baseAmount);
}

class RatesUpdatedAction {
  final CurrencyRate ratesResponse;

  RatesUpdatedAction(this.ratesResponse);
}

class RatesUpdateErrorAction {
  // TODO think of error via enums
  final Object error;

  RatesUpdateErrorAction(this.error);
}

class RatesLoadingAction {}