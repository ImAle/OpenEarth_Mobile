class Currency {
  final String code;
  final String name;
  final String symbol;
  final String continent;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.continent,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'],
      name: json['name'],
      symbol: json['symbol'],
      continent: json['continent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'continent': continent,
    };
  }
}
