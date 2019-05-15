import 'package:meta/meta.dart';
import 'package:money/money.dart';
import 'package:x_rate_monitor/models/models.dart';

final _defaultCurrency = Currency("EUR");

@immutable
class AppState {
  final RatesListState ratesListState;
  final RatesHistoryState ratesHistoryState;

  AppState(
    this.ratesListState,
    this.ratesHistoryState,
  );

  factory AppState.initial() {
    return AppState(RatesListState.initial(), RatesHistoryState());
  }
}

@immutable
class RatesListState {
  final Currency baseCurrency;
  final List<CurrencyRate> rates;
  final double baseAmount;
  final bool isLoading;
  final String error;

  RatesListState({
    this.baseCurrency,
    this.rates,
    this.baseAmount,
    this.isLoading,
    this.error,
  });

  factory RatesListState.initial() {
    return RatesListState(
        baseAmount: 0.0,
        baseCurrency: _defaultCurrency,
        isLoading: false,
        rates: [],
        error: null);
  }
}

class RatesHistoryState {}
