import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:money/money.dart';
// we use currency class from money dart

final defaultCurrency = Currency("EUR");

class CurrencyRate {
  final Currency baseCurrency;
  final List<Rate> rates;

  CurrencyRate([this.baseCurrency, this.rates]);

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> ratesMap = json['rates'];
    var baseCurrency = json['base'];
    return CurrencyRate(
        Currency(baseCurrency),
        ratesMap.keys
        // for some currencies api return base currency in the list of rates, we need to skip it
            .where((code) => code != baseCurrency)
        // rates are key values like this { "USD" : 2.333 }
            .map((code) => Rate(Currency(code), ratesMap[code])
        ).toList());
  }
}

class Rate {
  final Currency currency;
  final double rate;

  Rate(this.currency, this.rate);
}

//region Http calls
const _baseUrl = "https://api.exchangeratesapi.io";

Future<CurrencyRate> getRates({Currency baseCurrency}) {
  String url = "$_baseUrl/latest";
  // add base code as param if we have so
  if (baseCurrency != null) {
    url += "?base=${baseCurrency.code}";
  }

  return http.get(url).then((response) {
    // check for successful codes
    if (response.statusCode / 100 == 2) {
      // parse response
      final jsonResponse = convert.jsonDecode(response.body);
      return CurrencyRate.fromJson(jsonResponse);
    }
  });
}
//endregion
