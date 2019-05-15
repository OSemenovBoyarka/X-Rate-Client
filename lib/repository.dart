import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:money/money.dart';
import 'package:x_rate_monitor/models/models.dart';

abstract class Repository {
  Future<CurrencyRate> getRates({Currency baseCurrency});

  Future<HistoricalRates> getRatesHistory({
    Currency baseCurrency,
    @required List<Currency> targetCurrencies,
    @required DateTime from,
    @required DateTime to,
  });
}

//region Http calls

class ApiRepository extends Repository {
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
      } else {
        // TODO improve error handling
        return Future.error("${response.statusCode}: ${response.body}");
      }
    });
  }

  Future<HistoricalRates> getRatesHistory({
    Currency baseCurrency,
    @required List<Currency> targetCurrencies,
    @required DateTime from,
    @required DateTime to,
  }) {
    final paramDateFormat = DateFormat("yyyy-MM-dd");
    final url = _baseUrl.replace(path: "history", queryParameters: {
      "base": baseCurrency != null ? baseCurrency.code : null,
      // list of currencies to check historical data against
      "symbols": targetCurrencies.map((currency) => currency.code),
      "start_at": paramDateFormat.format(from),
      "end_at": paramDateFormat.format(to)
    });

    return http.get(url).then((response) {
      // check for successful codes
      if (response.statusCode / 100 == 2) {
        // parse response
        final jsonResponse = convert.jsonDecode(response.body);
        return HistoricalRates.fromJson(jsonResponse);
      } else {
        // TODO improve error handling
        return Future.error("${response.statusCode}: ${response.body}");
      }
    });
  }

}
//endregion
