//import 'package:money/money.dart';
import 'package:faker/faker.dart';

const defaultCurrency = "EUR";

final random = RandomGenerator();

class CurrencyRate {
  final String baseCurrency;
  final List<Rate> rates;

  CurrencyRate(this.baseCurrency, this.rates);
}

class Rate {
  final String currency;
  final double rate;

  Rate(this.currency, this.rate);

  bool operator ==(other) {
    return (other is Rate && other.currency == currency);
  }

  @override
  int get hashCode {
    return currency.hashCode;
  }

}

CurrencyRate getRates({String baseCurrency = defaultCurrency}) {
  // TODO api call
  return CurrencyRate(
      baseCurrency,
      List<Rate>.generate(
        random.integer(20, min: 0),
        (index) => Rate(faker.currency.code(), random.decimal(scale: 2, min: 0.1)),
      ).toSet().toList() // Remove duplicates from list
  );
}
