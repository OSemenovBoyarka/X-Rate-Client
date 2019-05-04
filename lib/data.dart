import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:money/money.dart';
// we use currency class from money dart

final defaultCurrency = Currency("EUR");

//region Models and parsing
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

class Rate {
  final Currency currency;
  final double rate;

  Rate(this.currency, this.rate);
}

class HistoricalRates {
  final Currency baseCurrency;
  final Map<DateTime, List<Rate>> rates;

  HistoricalRates(this.baseCurrency, this.rates);

  factory HistoricalRates.fromJson(Map<String, dynamic> json) {
    final baseCurrency = json['base'];
    return HistoricalRates(
      Currency(baseCurrency),
      json['rates'].map((date, dailyRatesMap) {
        // here we have map of date to list of rates for that date
        MapEntry(
          DateTime.parse(date),
          _parseRates(dailyRatesMap, baseCurrency),
        );
      }),
    );
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

//endregion

//region Http calls
final _baseUrl = Uri.https("api.exchangeratesapi.io", "");

Future<CurrencyRate> getRates({Currency baseCurrency}) {
  final url = _baseUrl.replace(path: "latest", queryParameters: {
    "base": baseCurrency != null ? baseCurrency.code : null
  });

  return http.get(url).then((response) {
    // check for successful codes
    if (response.statusCode / 100 == 2) {
      // parse response
      final jsonResponse = convert.jsonDecode(response.body);
      return CurrencyRate.fromJson(jsonResponse);
    }
  });
}

Future<HistoricalRates> getRatesHistory(
    {Currency baseCurrency, @required DateTime from, @required DateTime to}) {
  final paramDateFormat = DateFormat("YYYY-MM-dd");
  final url = _baseUrl.replace(path: "history", queryParameters: {
    "base": baseCurrency != null ? baseCurrency.code : null,
    "start_at": paramDateFormat.format(from),
    "end_at": paramDateFormat.format(to)
  });

  return http.get(url).then((response) {
    // check for successful codes
    if (response.statusCode / 100 == 2) {
      // parse response
      final jsonResponse = convert.jsonDecode(response.body);
      return HistoricalRates.fromJson(jsonResponse);
    }
  });
}
//endregion
