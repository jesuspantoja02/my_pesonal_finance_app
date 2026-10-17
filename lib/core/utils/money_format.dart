import 'package:intl/intl.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';

class MoneyFormat {
  MoneyFormat._();

  static NumberFormat _currency(String code) {
    return NumberFormat.simpleCurrency(name: code);
  }

  static String format(int cents, {String currencyCode = kDefaultCurrencyCode}) {
    final formatter = _currency(currencyCode);
    return formatter.format(cents / 100);
  }

  static String currencySymbol(String currencyCode) {
    return _currency(currencyCode).currencySymbol;
  }

  static int parseToCents(String input) {
    final normalized = input.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
    if (normalized.isEmpty) return 0;
    final value = double.tryParse(normalized) ?? 0;
    return (value * 100).round();
  }
}
