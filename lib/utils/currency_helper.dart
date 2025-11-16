class CurrencyHelper {
  // Exchange rates terhadap IDR (1 IDR = ?)
  static Map<String, double> exchangeRates = {
    'IDR': 1.0,
    'USD': 0.000064, // 1 IDR ≈ 0.000064 USD
    'EUR': 0.000059, // 1 IDR ≈ 0.000059 EUR
    'SGD': 0.000086, // 1 IDR ≈ 0.000086 SGD
    'MYR': 0.00030, // 1 IDR ≈ 0.00030 MYR (Ringgit)
    'JPY': 0.0095, // 1 IDR ≈ 0.0095 JPY (Yen)
  };

  static Map<String, String> currencySymbols = {
    'IDR': 'Rp',
    'USD': '\$',
    'EUR': '€',
    'SGD': 'S\$',
    'MYR': 'RM',
    'JPY': '¥',
  };

  static String convertAndFormat(dynamic amount, String targetCurrency) {
    // Parse amount ke integer
    int amountIDR;
    if (amount is int) {
      amountIDR = amount;
    } else if (amount is double) {
      amountIDR = amount.toInt();
    } else if (amount is String) {
      amountIDR = int.tryParse(amount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    } else {
      amountIDR = 0;
    }

    // Jika amount 0, return "0"
    if (amountIDR == 0) {
      final symbol = currencySymbols[targetCurrency] ?? '';
      return '$symbol 0';
    }

    final rate = exchangeRates[targetCurrency] ?? 1.0;
    final converted = (amountIDR * rate);
    final symbol = currencySymbols[targetCurrency] ?? '';

    if (targetCurrency == 'IDR') {
      // Format Indonesia: Rp 1.000.000
      final formatted = amountIDR.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return '$symbol $formatted';
    } else if (targetCurrency == 'JPY') {
      // Yen tanpa desimal
      final formatted = converted.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '$symbol $formatted';
    } else {
      // Format International: $ 1,000.00
      final formatted = converted.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+\.)', caseSensitive: false),
            (Match m) => '${m[1]},',
          );
      return '$symbol $formatted';
    }
  }
}
