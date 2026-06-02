class PrayerJournalEntry {
  const PrayerJournalEntry({
    required this.prayerId,
    required this.prayerTitle,
    required this.completedAt,
    this.prayerSubtitle = '',
  });

  final String prayerId;
  final String prayerTitle;
  final String prayerSubtitle;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
        'prayerId': prayerId,
        'prayerTitle': prayerTitle,
        'prayerSubtitle': prayerSubtitle,
        'completedAt': completedAt.toIso8601String(),
      };

  factory PrayerJournalEntry.fromJson(Map<String, dynamic> json) {
    return PrayerJournalEntry(
      prayerId: json['prayerId'] as String,
      prayerTitle: json['prayerTitle'] as String? ?? '',
      prayerSubtitle: json['prayerSubtitle'] as String? ?? '',
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}
