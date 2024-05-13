import 'package:flutter/services.dart';

class NumberInputFormatter extends TextInputFormatter {
  const NumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int? newNum = int.tryParse(newValue.text);
    if (newNum == null) {
      return TextEditingValue(
        text: '0',
        composing: TextRange(start: 0, end: 0),
      );
    } else if (newValue.text.startsWith('0') && newValue.text.length > 1) {
      final match = RegExp(r'^0+(?!$)').firstMatch(newValue.text);
      if (match != null) {
        return newValue.replaced(
          TextRange(start: match.start, end: match.end),
          '',
        );
      }
    }
    return newValue;
  }
}
