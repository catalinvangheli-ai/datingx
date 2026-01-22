class CompatibilityResult {
  final String userId;
  final double overallScore;
  final Map<String, double> scoreBreakdown;
  final List<String> compatibleAreas;
  final List<String> incompatibleAreas;
  final String summaryText;
  
  CompatibilityResult({
    required this.userId,
    required this.overallScore,
    required this.scoreBreakdown,
    required this.compatibleAreas,
    required this.incompatibleAreas,
    required this.summaryText,
  });

  String getCompatibilityLevel() {
    if (overallScore >= 85) return 'Excelent';
    if (overallScore >= 70) return 'Foarte Bun';
    if (overallScore >= 55) return 'Bun';
    if (overallScore >= 40) return 'Moderat';
    return 'Scăzut';
  }

  bool isHighCompatibility() {
    return overallScore >= 70;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'overallScore': overallScore,
    'scoreBreakdown': scoreBreakdown,
    'compatibleAreas': compatibleAreas,
    'incompatibleAreas': incompatibleAreas,
    'summaryText': summaryText,
  };

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) => CompatibilityResult(
    userId: json['userId'] ?? '',
    overallScore: (json['overallScore'] ?? 0).toDouble(),
    scoreBreakdown: Map<String, double>.from(json['scoreBreakdown'] ?? {}),
    compatibleAreas: List<String>.from(json['compatibleAreas'] ?? []),
    incompatibleAreas: List<String>.from(json['incompatibleAreas'] ?? []),
    summaryText: json['summaryText'] ?? '',
  );
}
