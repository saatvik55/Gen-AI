class Topic {
  final int id;
  final String title;
  final String? summary;
  final double strengthScore;
  final DateTime? lastReviewed;

  Topic({
    required this.id,
    required this.title,
    this.summary,
    required this.strengthScore,
    this.lastReviewed,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as int,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      strengthScore: (json['strength_score'] as num).toDouble(),
      lastReviewed: json['last_reviewed'] != null
          ? DateTime.parse(json['last_reviewed'] as String)
          : null,
    );
  }
}

