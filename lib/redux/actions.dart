import 'package:money/money.dart';
import 'package:x_rate_monitor/model/models.dart';

class ActionSetBaseCurrency {
  final Currency baseCurrency;

  const ActionSetBaseCurrency(this.baseCurrency);
}

class ActionSetBaseAmount {
  final double baseAmount;

  const ActionSetBaseAmount(this.baseAmount);
}

class ActionRatesUpdated {
  final CurrencyRate ratesResponse;

  const ActionRatesUpdated(this.ratesResponse);
}

class ActionRatesUpdateError {
  // TODO think of error via enums, add error filtering
  final Object error;

  const ActionRatesUpdateError(this.error);
}

class ActionRetryLoadRates {
  const ActionRetryLoadRates();
}

class ActionRatesLoading {}