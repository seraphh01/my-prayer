class PrayerReminder {
  const PrayerReminder({
    required this.id,
    required this.prayerId,
    required this.prayerTitle,
    required this.prayerSubtitle,
    required this.hour,
    required this.minute,
    required this.daysOfWeek,
    this.enabled = true,
  });

  /// Opens the first prayer from today's liturgical calendar when tapped.
  static const calendarTodayPrayerId = '__calendar_today__';

  /// Opens the rosary prayer for the current weekday when tapped.
  static const rosaryOfDayPrayerId = '__rosary_of_day__';

  /// Placeholder — user must pick a prayer in the add dialog.
  static const templatePickPrayerId = '__pick_prayer__';

  /// Stored in [dateGroupPrayerId] for "first prayer of the day" reminders.
  static const firstOfDayGroupKey = '__first_of_day__';

  static const dateGroupPrayerIdPrefix = '__date_group__:';

  static String dateGroupPrayerId(String groupKey) =>
      '$dateGroupPrayerIdPrefix$groupKey';

  static String? dateGroupKeyFromPrayerId(String id) {
    if (!id.startsWith(dateGroupPrayerIdPrefix)) {
      return null;
    }
    return id.substring(dateGroupPrayerIdPrefix.length);
  }

  /// Liturgical reminder: date group key + prayer type id.
  static const liturgicalPrayerIdPrefix = '__liturgical__:';

  static String liturgicalPrayerId({
    required String dateGroupKey,
    required int prayerTypeId,
  }) =>
      '$liturgicalPrayerIdPrefix$dateGroupKey|$prayerTypeId';

  static ({String dateGroupKey, int prayerTypeId})? liturgicalSelectionFromPrayerId(
    String id,
  ) {
    if (!id.startsWith(liturgicalPrayerIdPrefix)) {
      return null;
    }
    final rest = id.substring(liturgicalPrayerIdPrefix.length);
    final separator = rest.lastIndexOf('|');
    if (separator <= 0) {
      return null;
    }
    final typeId = int.tryParse(rest.substring(separator + 1));
    if (typeId == null) {
      return null;
    }
    return (
      dateGroupKey: rest.substring(0, separator),
      prayerTypeId: typeId,
    );
  }

  final String id;
  final String prayerId;
  final String prayerTitle;
  final String prayerSubtitle;
  final int hour;
  final int minute;
  final List<int> daysOfWeek;
  final bool enabled;

  static const weekdayLabelsRo = {
    DateTime.monday: 'Lun',
    DateTime.tuesday: 'Mar',
    DateTime.wednesday: 'Mie',
    DateTime.thursday: 'Joi',
    DateTime.friday: 'Vin',
    DateTime.saturday: 'Sâm',
    DateTime.sunday: 'Dum',
  };

  String get timeLabel {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get daysLabel {
    final sorted = daysOfWeek.toList()..sort();
    return sorted.map((d) => weekdayLabelsRo[d] ?? '').where((s) => s.isNotEmpty).join(', ');
  }

  String get notificationBody {
    if (isLiturgicalDynamic) {
      if (prayerSubtitle.isNotEmpty) {
        return '$prayerTitle — $prayerSubtitle';
      }
      return '$prayerTitle — din calendarul liturgic';
    }
    if (isDateGroupDynamic) {
      if (prayerSubtitle.isNotEmpty) {
        return '$prayerTitle — $prayerSubtitle';
      }
      return '$prayerTitle — din calendarul liturgic';
    }
    if (prayerId == calendarTodayPrayerId) {
      return 'Rugăciunea zilei — deschide calendarul';
    }
    if (prayerId == rosaryOfDayPrayerId) {
      return 'Rozariul zilei — ${_rosaryMysteryLabelForWeekday(DateTime.now().weekday)}';
    }
    if (prayerSubtitle.isNotEmpty) {
      return '$prayerTitle — $prayerSubtitle';
    }
    return prayerTitle;
  }

  bool get isCalendarToday => prayerId == calendarTodayPrayerId;

  bool get isRosaryOfDay => prayerId == rosaryOfDayPrayerId;

  bool get isDateGroupDynamic =>
      prayerId.startsWith(dateGroupPrayerIdPrefix);

  bool get isLiturgicalDynamic =>
      prayerId.startsWith(liturgicalPrayerIdPrefix);

  bool get isDynamicLiturgical =>
      isLiturgicalDynamic ||
      isDateGroupDynamic ||
      isCalendarToday ||
      isRosaryOfDay;

  PrayerReminder copyWith({
    String? id,
    String? prayerId,
    String? prayerTitle,
    String? prayerSubtitle,
    int? hour,
    int? minute,
    List<int>? daysOfWeek,
    bool? enabled,
  }) {
    return PrayerReminder(
      id: id ?? this.id,
      prayerId: prayerId ?? this.prayerId,
      prayerTitle: prayerTitle ?? this.prayerTitle,
      prayerSubtitle: prayerSubtitle ?? this.prayerSubtitle,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prayerId': prayerId,
        'prayerTitle': prayerTitle,
        'prayerSubtitle': prayerSubtitle,
        'hour': hour,
        'minute': minute,
        'daysOfWeek': daysOfWeek,
        'enabled': enabled,
      };

  factory PrayerReminder.fromJson(Map<String, dynamic> json) {
    return PrayerReminder(
      id: json['id'] as String,
      prayerId: json['prayerId'] as String,
      prayerTitle: json['prayerTitle'] as String? ?? '',
      prayerSubtitle: json['prayerSubtitle'] as String? ?? '',
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  /// Deterministic notification id per reminder and weekday (Dart 1=Mon … 7=Sun).
  static int notificationIdFor(String reminderId, int weekday) {
    return (reminderId.hashCode.abs() + weekday * 10007) % 2147483646 + 1;
  }

  List<int> get notificationIds {
    return daysOfWeek
        .map((day) => notificationIdFor(id, day))
        .toList();
  }
}

String _rosaryMysteryLabelForWeekday(int weekday) {
  switch (weekday) {
    case DateTime.monday:
    case DateTime.saturday:
      return 'Misterele de Bucurie';
    case DateTime.tuesday:
    case DateTime.friday:
      return 'Misterele de Durere';
    case DateTime.wednesday:
    case DateTime.sunday:
      return 'Misterele de Mărire';
    case DateTime.thursday:
      return 'Misterele de Lumină';
    default:
      return 'Misterele din zi';
  }
}
