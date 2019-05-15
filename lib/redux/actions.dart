import 'package:money/money.dart';
import 'package:x_rate_monitor/models/models.dart';

class ActionSetBaseCurrency {
  final Currency baseCurrency;

  ActionSetBaseCurrency(this.baseCurrency);
}

class ActionSetBaseAmount {
  final double baseAmount;

  ActionSetBaseAmount(this.baseAmount);
}

class ActionRatesUpdated {
  final CurrencyRate ratesResponse;

  ActionRatesUpdated(this.ratesResponse);
}

class ActionRatesUpdateError {
  // TODO think of error via enums, add error filtering
  final Object error;

  ActionRatesUpdateError(this.error);
}

class ActionRatesLoading {}