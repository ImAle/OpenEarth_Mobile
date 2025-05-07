class Review {
  final int id;
  final String comment;
  final int houseId;
  final int userId;

  Review({
    required this.id,
    required this.comment,
    required this.houseId,
    required this.userId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      comment: json['comment'],
      houseId: json['houseId'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'houseId': houseId,
      'userId': userId,
    };
  }
}
