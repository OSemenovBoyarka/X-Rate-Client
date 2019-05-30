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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppState &&
              runtimeType == other.runtimeType &&
              ratesListState == other.ratesListState &&
              ratesHistoryState == other.ratesHistoryState;

  @override
  int get hashCode =>
      ratesListState.hashCode ^
      ratesHistoryState.hashCode;



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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RatesListState &&
              runtimeType == other.runtimeType &&
              baseCurrency == other.baseCurrency &&
              baseAmount == other.baseAmount &&
              availableCurrencies == other.availableCurrencies &&
              rates == other.rates &&
              isLoading == other.isLoading &&
              error == other.error;

  @override
  int get hashCode =>
      baseCurrency.hashCode ^
      baseAmount.hashCode ^
      availableCurrencies.hashCode ^
      rates.hashCode ^
      isLoading.hashCode ^
      error.hashCode;
}

@immutable
class RateItemState {
  final Rate rate;
  final Currency baseCurrency;
  final double targetAmount;

  RateItemState({this.rate, this.baseCurrency, this.targetAmount});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RateItemState &&
              runtimeType == other.runtimeType &&
              rate == other.rate &&
              baseCurrency == other.baseCurrency &&
              targetAmount == other.targetAmount;

  @override
  int get hashCode =>
      rate.hashCode ^
      baseCurrency.hashCode ^
      targetAmount.hashCode;

  @override
  String toString() {
    return 'RateItemState{rate: $rate, baseCurrency: $baseCurrency, targetAmount: $targetAmount}';
  }

}

class RatesHistoryState {}
