import 'package:meta/meta.dart';
import 'package:money/money.dart';
import 'package:x_rate_monitor/model/models.dart';

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
  final double baseAmount;
  final List<Currency> availableCurrencies;
  final List<RateItemState> rates;
  final bool isLoading;
  final String error;

  RatesListState({
    this.baseCurrency,
    this.baseAmount,
    this.availableCurrencies,
    this.rates,
    this.isLoading,
    this.error,
  });

  RatesListState copyWith({
    Currency baseCurrency,
    double baseAmount,
    List<Currency> availableCurrencies,
    List<RateItemState> rates,
    bool isLoading,
    String error,
  }) {
    return RatesListState(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      baseAmount: baseAmount ?? this.baseAmount,
      availableCurrencies: availableCurrencies ?? this.availableCurrencies,
      rates: rates ?? this.rates,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory RatesListState.initial() {
    return RatesListState(
      baseCurrency: _defaultCurrency,
      baseAmount: 0.0,
      availableCurrencies: [_defaultCurrency],
      rates: [],
      isLoading: false,
      error: null,
    );
  }
}

@immutable
class RateItemState {
  final Rate rate;
  final Currency baseCurrency;
  final double targetAmount;

  RateItemState({this.rate, this.baseCurrency, this.targetAmount});
}

class RatesHistoryState {}
