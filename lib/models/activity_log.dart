enum ActivityType {
  feeding,
  sleep,
  diaper,
  growth,
  memory,
  vaccine,
  note,
}

enum FeedingType { breast, formula, pump }

enum DiaperType { wet, dirty, both }

enum MilestoneType {
  firstSmile,
  rollOver,
  sitUp,
  crawl,
  stand,
  walk,
  firstWord,
  other,
}

class ActivityLog {
  final String id;
  final String babyId;
  final ActivityType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final String? note;

  ActivityLog({
    required this.id,
    required this.babyId,
    required this.type,
    required this.timestamp,
    this.data = const {},
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'babyId': babyId,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'data': data,
        'note': note,
      };

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
        id: json['id'] as String,
        babyId: json['babyId'] as String,
        type: ActivityType.values.byName(json['type'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
        note: json['note'] as String?,
      );

  ActivityLog copyWith({
    DateTime? timestamp,
    Map<String, dynamic>? data,
    String? note,
  }) =>
      ActivityLog(
        id: id,
        babyId: babyId,
        type: type,
        timestamp: timestamp ?? this.timestamp,
        data: data ?? this.data,
        note: note ?? this.note,
      );
}

class TodaySummary {
  final int feedingCount;
  final int sleepMinutes;
  final int diaperCount;
  final int totalLogs;

  const TodaySummary({
    this.feedingCount = 0,
    this.sleepMinutes = 0,
    this.diaperCount = 0,
    this.totalLogs = 0,
  });
}

class VaccineSchedule {
  final String id;
  final String name;
  final int recommendedWeeks;
  final bool completed;
  final DateTime? completedDate;

  const VaccineSchedule({
    required this.id,
    required this.name,
    required this.recommendedWeeks,
    this.completed = false,
    this.completedDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'recommendedWeeks': recommendedWeeks,
        'completed': completed,
        'completedDate': completedDate?.toIso8601String(),
      };

  factory VaccineSchedule.fromJson(Map<String, dynamic> json) => VaccineSchedule(
        id: json['id'] as String,
        name: json['name'] as String,
        recommendedWeeks: json['recommendedWeeks'] as int,
        completed: json['completed'] as bool? ?? false,
        completedDate: json['completedDate'] != null
            ? DateTime.parse(json['completedDate'] as String)
            : null,
      );

  VaccineSchedule copyWith({bool? completed, DateTime? completedDate}) =>
      VaccineSchedule(
        id: id,
        name: name,
        recommendedWeeks: recommendedWeeks,
        completed: completed ?? this.completed,
        completedDate: completedDate ?? this.completedDate,
      );
}

const defaultVaccines = [
  VaccineSchedule(id: 'bcg', name: 'BCG', recommendedWeeks: 0),
  VaccineSchedule(id: 'hepb1', name: 'HepB #1', recommendedWeeks: 0),
  VaccineSchedule(id: 'dtap1', name: 'DTaP #1', recommendedWeeks: 8),
  VaccineSchedule(id: 'ipv1', name: 'IPV #1', recommendedWeeks: 8),
  VaccineSchedule(id: 'hib1', name: 'Hib #1', recommendedWeeks: 8),
  VaccineSchedule(id: 'pcv1', name: 'PCV #1', recommendedWeeks: 8),
  VaccineSchedule(id: 'rotav1', name: 'Rotavirus #1', recommendedWeeks: 8),
  VaccineSchedule(id: 'dtap2', name: 'DTaP #2', recommendedWeeks: 12),
  VaccineSchedule(id: 'ipv2', name: 'IPV #2', recommendedWeeks: 12),
  VaccineSchedule(id: 'mmr1', name: 'MMR #1', recommendedWeeks: 52),
];
