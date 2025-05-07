class RentCreation {
  final DateTime startTime;
  final DateTime endTime;
  final int houseId;

  RentCreation({
    required this.startTime,
    required this.endTime,
    required this.houseId,
  });

  factory RentCreation.fromJson(Map<String, dynamic> json) {
    return RentCreation(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      houseId: json['houseId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'houseId': houseId,
    };
  }
}
