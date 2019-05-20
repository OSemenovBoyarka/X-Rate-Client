import 'package:money/money.dart';

abstract class HistoryEvent {
  const HistoryEvent();
}

class GetHistoryEvent implements HistoryEvent {
  final Currency baseCurrency;
  final List<Currency> targetCurrencies;
  final int historyDays;

  const GetHistoryEvent(this.baseCurrency, this.targetCurrencies, this.historyDays);
}
