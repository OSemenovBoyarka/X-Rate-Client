import 'package:faker/faker.dart' hide Currency;
import 'package:money/money.dart';

final defaultCurrency = Currency("EUR");

final random = RandomGenerator();

class CurrencyRate {
  final Currency baseCurrency;
  final List<Rate> rates;

  CurrencyRate(this.baseCurrency, this.rates);
}

class Rate {
  final Currency currency;
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

CurrencyRate getRates({Currency baseCurrency}) {
  // TODO think of default const parameter
  final base = baseCurrency != null ? baseCurrency : defaultCurrency;
  // TODO api call
  return CurrencyRate(
      base,
      List<Rate>.generate(
        random.integer(20, min: 0),
            (index) =>
            Rate(Currency(faker.currency.code()),
                random.decimal(scale: 2, min: 0.1)),
      ).toSet().toList() // Remove duplicates from list
  );
}
