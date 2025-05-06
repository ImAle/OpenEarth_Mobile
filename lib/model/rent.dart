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
}
