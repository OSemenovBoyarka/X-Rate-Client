import 'package:money/money.dart';

class CurrencyRate {
  final Currency baseCurrency;
  final List<Rate> rates;

  CurrencyRate([this.baseCurrency, this.rates]);

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    final baseCurrency = json['base'];
    return CurrencyRate(
        Currency(baseCurrency), _parseRates(json['rates'], baseCurrency));
  }
}

class HistoricalRates {
  final Currency baseCurrency;
  final List<HistoryRatePoint> rates;

  HistoricalRates(this.baseCurrency, this.rates);

  factory HistoricalRates.fromJson(Map<String, dynamic> json) {
    final baseCurrency = json['base'];
    final Map<String, dynamic> ratesMap = json['rates'];
    return HistoricalRates(
      Currency(baseCurrency),
      ratesMap.entries.map((MapEntry<String, dynamic> entry) {
        // here we have map of date to list of rates for that date
        return HistoryRatePoint(
          DateTime.parse(entry.key),
          _parseRates(entry.value, baseCurrency),
        );
      }).toList(),
    );
  }
}

class HistoryRatePoint {
  final DateTime date;
  final List<Rate> rates;

  HistoryRatePoint(this.date, this.rates);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HistoryRatePoint &&
              runtimeType == other.runtimeType &&
              date == other.date &&
              rates == other.rates;

  @override
  int get hashCode =>
      date.hashCode ^
      rates.hashCode;



}

class Rate {
  final Currency currency;
  final double rate;

  Rate(this.currency, this.rate);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Rate &&
              runtimeType == other.runtimeType &&
              currency == other.currency &&
              rate == other.rate;

  @override
  int get hashCode =>
      currency.hashCode ^
      rate.hashCode;

  @override
  String toString() {
    return 'Rate{currency: $currency, rate: $rate}';
  }


}

List<Rate> _parseRates(Map<String, dynamic> ratesMap, String baseCurrencyCode) {
  return ratesMap.keys
      // for some currencies api return base currency in the list of rates, we need to skip it
      .where((code) => code != baseCurrencyCode)
      // rates are key values like this { "USD" : 2.333 }
      .map((code) => Rate(Currency(code), ratesMap[code]))
      .toList();
}
