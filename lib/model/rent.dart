class Rent {
  final int id;
  final double price;
  final String startTime;
  final String endTime;
  final bool cancelled;
  final int userId;
  final int houseId;

  Rent({
    required this.id,
    required this.price,
    required this.startTime,
    required this.endTime,
    required this.cancelled,
    required this.userId,
    required this.houseId,
  });

  factory Rent.fromJson(Map<String, dynamic> json) {
    return Rent(
      id: json['id'],
      price: (json['price'] as num).toDouble(),
      startTime: json['startTime'],
      endTime: json['endTime'],
      cancelled: json['cancelled'],
      userId: json['userId'],
      houseId: json['houseId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'startTime': startTime,
      'endTime': endTime,
      'cancelled': cancelled,
      'userId': userId,
      'houseId': houseId,
    };
  }
}
