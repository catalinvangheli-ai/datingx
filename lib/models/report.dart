enum ReportReason {
  inappropriateContent,
  harassment,
  fakeProfile,
  scam,
  underage,
  other,
}

class Report {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final ReportReason reason;
  final String description;
  final DateTime createdAt;
  final bool isResolved;

  Report({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.description,
    required this.createdAt,
    this.isResolved = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'reporterId': reporterId,
    'reportedUserId': reportedUserId,
    'reason': reason.toString(),
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'isResolved': isResolved,
  };

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'] ?? '',
    reporterId: json['reporterId'] ?? '',
    reportedUserId: json['reportedUserId'] ?? '',
    reason: ReportReason.values.firstWhere(
      (e) => e.toString() == json['reason'],
      orElse: () => ReportReason.other,
    ),
    description: json['description'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    isResolved: json['isResolved'] ?? false,
  );
}
