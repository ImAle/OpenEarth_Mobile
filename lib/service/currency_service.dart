import 'package:flutter/foundation.dart';
import 'package:openearth_mobile/model/currency.dart';

class CurrencyService {
  final ValueNotifier<Currency> currentCurrency = ValueNotifier<Currency>(
      Currency(
          code: 'EUR',
          name: 'Euro',
          symbol: '€',
          continent: 'Europe'
      )
  );

  final List<Currency> currencies = [
    // Europe
    Currency(code: 'EUR', name: 'Euro', symbol: '€', continent: 'Europe'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', continent: 'Europe'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', continent: 'Europe'),
    Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', continent: 'Europe'),
    Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', continent: 'Europe'),
    Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr', continent: 'Europe'),
    Currency(code: 'PLN', name: 'Polish Złoty', symbol: 'zł', continent: 'Europe'),
    Currency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', continent: 'Europe'),
    Currency(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft', continent: 'Europe'),
    Currency(code: 'RON', name: 'Romanian Leu', symbol: 'lei', continent: 'Europe'),

    // North America
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', continent: 'North America'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', continent: 'North America'),
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: '\$', continent: 'North America'),

    // South America
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$', continent: 'South America'),
    Currency(code: 'ARS', name: 'Argentine Peso', symbol: '\$', continent: 'South America'),
    Currency(code: 'CLP', name: 'Chilean Peso', symbol: '\$', continent: 'South America'),
    Currency(code: 'COP', name: 'Colombian Peso', symbol: '\$', continent: 'South America'),
    Currency(code: 'PEN', name: 'Peruvian Sol', symbol: 'S/', continent: 'South America'),

    // Asia
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', continent: 'Asia'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', continent: 'Asia'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$', continent: 'Asia'),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', continent: 'Asia'),
    Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩', continent: 'Asia'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', continent: 'Asia'),
    Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', continent: 'Asia'),
    Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', continent: 'Asia'),
    Currency(code: 'PHP', name: 'Philippine Peso', symbol: '₱', continent: 'Asia'),
    Currency(code: 'THB', name: 'Thai Baht', symbol: '฿', continent: 'Asia'),
    Currency(code: 'VND', name: 'Vietnamese Dong', symbol: '₫', continent: 'Asia'),
    Currency(code: 'TWD', name: 'New Taiwan Dollar', symbol: 'NT\$', continent: 'Asia'),
    Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', continent: 'Asia'),
    Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', continent: 'Asia'),
    Currency(code: 'ILS', name: 'Israeli New Shekel', symbol: '₪', continent: 'Asia'),

    // Oceania
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', continent: 'Oceania'),
    Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$', continent: 'Oceania'),

    // Africa
    Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R', continent: 'Africa'),
    Currency(code: 'EGP', name: 'Egyptian Pound', symbol: 'E£', continent: 'Africa'),
    Currency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦', continent: 'Africa'),
    Currency(code: 'MAD', name: 'Moroccan Dirham', symbol: 'د.م.', continent: 'Africa'),
    Currency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh', continent: 'Africa'),
    Currency(code: 'GHS', name: 'Ghanaian Cedi', symbol: '₵', continent: 'Africa')
  ];

  // Continents en orden para mostrar
  final List<String> continentOrder = [
    'Europe', 'North America', 'South America', 'Asia', 'Oceania', 'Africa'
  ];

  late Map<String, List<Currency>> _currenciesByContinent;

  CurrencyService() {
    _currenciesByContinent = _groupCurrenciesByContinent();
  }

  Map<String, List<Currency>> _groupCurrenciesByContinent() {
    final result = <String, List<Currency>>{};

    for (final continent in continentOrder) {
      final continentCurrencies = currencies
          .where((c) => c.continent == continent)
          .toList()
        ..sort((a, b) => a.code.compareTo(b.code));

      result[continent] = continentCurrencies;
    }

    return result;
  }

  ValueNotifier<Currency> get current => currentCurrency;

  List<Currency> getAllCurrencies() {
    return currencies;
  }

  List<String> getAllCurrenciesCode() {
    return getAllCurrencies().map((currency) => currency.code).toList();
  }

  Map<String, List<Currency>> getContinentsWithCurrencies() {
    return _currenciesByContinent;
  }

  List<String> getContinentOrder() {
    return continentOrder;
  }

  void setCurrentCurrency(Currency currency) {
    currentCurrency.value = currency;
  }

  void setCurrencyByCode(String code) {
    final currency = currencies.firstWhere(
          (c) => c.code == code,
      orElse: () => currentCurrency.value,
    );

    currentCurrency.value = currency;
  }
}