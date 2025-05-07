class ReportCreation {
  final String comment;
  final int reportedId;

  ReportCreation({
    required this.comment,
    required this.reportedId,
  });

  factory ReportCreation.fromJson(Map<String, dynamic> json) {
    return ReportCreation(
      comment: json['comment'],
      reportedId: json['reportedId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'reportedId': reportedId,
    };
  }
}
