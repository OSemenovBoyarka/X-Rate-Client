import 'package:flutter/services.dart';
import 'package:money/money.dart';

class CurrencyAmountTextInputFormatter extends TextInputFormatter {
  CurrencyAmountTextInputFormatter({this.currency}) : assert(currency != null);

  final Currency currency;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {


    double amountCopecs = double.tryParse(
        newValue.text.replaceAll(RegExp("[^0-9]+"), "") // clear anything but numbers
    );
    if (amountCopecs == null) {
      return oldValue; // invalid input
    }

    String newText = Money.fromDouble(amountCopecs / 100, this.currency).amountAsString;

    // move selection to the end
    TextSelection  newSelection = newValue.selection.copyWith(
      baseOffset: newText.length,
      extentOffset: newText.length,
    );
    return TextEditingValue(
      text: newText,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}
