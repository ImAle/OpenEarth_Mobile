class ReviewCreation {
  final String comment;
  final int houseId;

  ReviewCreation({
    required this.comment,
    required this.houseId,
  });

  factory ReviewCreation.fromJson(Map<String, dynamic> json) {
    return ReviewCreation(
      comment: json['comment'],
      houseId: json['houseId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'houseId': houseId,
    };
  }
}
