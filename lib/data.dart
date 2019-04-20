import 'dart:async';
import 'dart:convert' as convert;

import 'package:faker/faker.dart'
    hide Currency;
import 'package:http/http.dart' as http;
import 'package:money/money.dart';
// we use currency class from money dart


final defaultCurrency = Currency("EUR");

final random = RandomGenerator();

class CurrencyRate {
  final Currency baseCurrency;
  final List<Rate> rates;

  CurrencyRate([this.baseCurrency, this.rates]);

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> ratesMap = json['rates'];
    return CurrencyRate(
        Currency(json['base']),
        // rates are key values like this { "USD" : 2.333 }
        ratesMap.keys.map((currencyKey) {
          return Rate(Currency(currencyKey), ratesMap[currencyKey]);
        }).toList());
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
