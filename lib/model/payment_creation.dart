class PaymentCreation {
  final String currency;
  final String description;
  final double amount;

  PaymentCreation({
    required this.currency,
    required this.description,
    required this.amount,
  });

  factory PaymentCreation.fromJson(Map<String, dynamic> json) {
    return PaymentCreation(
      currency: json['currency'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'description': description,
      'amount': amount,
    };
  }
}
