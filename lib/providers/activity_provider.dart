import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/activity_log.dart';

class ActivityProvider extends ChangeNotifier {
  static const _logsKey = 'bcn_activity_logs';
  static const _vaccinesKey = 'bcn_vaccine_schedule';

  final _uuid = const Uuid();
  List<ActivityLog> _logs = [];
  Map<String, List<VaccineSchedule>> _vaccineSchedules = {};
  final Map<String, Map<ActivityType, ActivityLog>> _lastLogs = {};

  List<ActivityLog> get logs => List.unmodifiable(_logs);

  Future<void> init() async {
    await _load();
    _rebuildLastLogIndex();
    notifyListeners();
  }

  Future<void> _load() async {
    final raw = await StorageService.instance.getString(_logsKey);
    if (raw != null && raw.isNotEmpty) {
      _logs = StorageService.decodeList(raw).map(ActivityLog.fromJson).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    final vaxRaw = await StorageService.instance.getData(_vaccinesKey);
    if (vaxRaw != null) {
      _vaccineSchedules = vaxRaw.map(
        (k, v) => MapEntry(
          k,
          (v as List).map((e) => VaccineSchedule.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        ),
      );
    }
  }

  Future<void> _saveLogs() async {
    await StorageService.instance.saveString(
      _logsKey,
      StorageService.encodeList(_logs.map((l) => l.toJson()).toList()),
    );
  }

  Future<void> _saveVaccines() async {
    final data = _vaccineSchedules.map(
      (k, v) => MapEntry(k, v.map((s) => s.toJson()).toList()),
    );
    await StorageService.instance.saveData(_vaccinesKey, data);
  }

  void _rebuildLastLogIndex() {
    _lastLogs.clear();
    for (final log in _logs) {
      _lastLogs.putIfAbsent(log.babyId, () => {}).putIfAbsent(log.type, () => log);
    }
  }

  void _updateLastLogIndex(ActivityLog log) {
    _lastLogs.putIfAbsent(log.babyId, () => {})[log.type] = log;
  }

  void _invalidateLastLogIndex(String babyId, ActivityType type) {
    _lastLogs[babyId]?.remove(type);
    final latest = logsForBaby(babyId, type: type).firstOrNull;
    if (latest != null) {
      _lastLogs.putIfAbsent(babyId, () => {})[type] = latest;
    }
  }

  List<ActivityLog> logsForBaby(String babyId, {ActivityType? type}) {
    return _logs.where((l) {
      if (l.babyId != babyId) return false;
      if (type != null && l.type != type) return false;
      return true;
    }).toList();
  }

  ActivityLog? lastLog(String babyId, ActivityType type) => _lastLogs[babyId]?[type];

  String? timeAgoLabel(DateTime? dt, {bool vi = false}) {
    if (dt == null) return null;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return vi ? 'Vừa xong' : 'Just now';
    if (diff.inMinutes < 60) return vi ? '${diff.inMinutes} phút trước' : '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return vi ? '${diff.inHours} giờ trước' : '${diff.inHours}h ago';
    if (diff.inDays < 7) return vi ? '${diff.inDays} ngày trước' : '${diff.inDays}d ago';
    final weeks = (diff.inDays / 7).floor();
    return vi ? '$weeks tuần trước' : '${weeks}w ago';
  }

  TodaySummary todaySummary(String babyId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayLogs = _logs.where((l) {
      if (l.babyId != babyId) return false;
      final d = DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day);
      return d == today;
    }).toList();

    var sleepMinutes = 0;
    for (final log in todayLogs.where((l) => l.type == ActivityType.sleep)) {
      final start = log.data['start'] as String?;
      final end = log.data['end'] as String?;
      if (start != null && end != null) {
        sleepMinutes += DateTime.parse(end).difference(DateTime.parse(start)).inMinutes;
      } else {
        sleepMinutes += (log.data['durationMinutes'] as num?)?.toInt() ?? 0;
      }
    }

    return TodaySummary(
      feedingCount: todayLogs.where((l) => l.type == ActivityType.feeding).length,
      sleepMinutes: sleepMinutes,
      diaperCount: todayLogs.where((l) => l.type == ActivityType.diaper).length,
      totalLogs: todayLogs.length,
    );
  }

  Future<ActivityLog> addLog({
    required String babyId,
    required ActivityType type,
    DateTime? timestamp,
    Map<String, dynamic> data = const {},
    String? note,
  }) async {
    final log = ActivityLog(
      id: _uuid.v4(),
      babyId: babyId,
      type: type,
      timestamp: timestamp ?? DateTime.now(),
      data: data,
      note: note,
    );
    _logs.insert(0, log);
    _updateLastLogIndex(log);
    await _saveLogs();
    notifyListeners();
    return log;
  }

  Future<void> updateLog(ActivityLog log) async {
    final i = _logs.indexWhere((l) => l.id == log.id);
    if (i >= 0) {
      final previous = _logs[i];
      _logs[i] = log;
      _logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (previous.babyId != log.babyId || previous.type != log.type) {
        _invalidateLastLogIndex(previous.babyId, previous.type);
      }
      _updateLastLogIndex(log);
      await _saveLogs();
      notifyListeners();
    }
  }

  Future<void> deleteLog(String id) async {
    final existing = _logs.where((l) => l.id == id).firstOrNull;
    _logs.removeWhere((l) => l.id == id);
    if (existing != null) {
      _invalidateLastLogIndex(existing.babyId, existing.type);
    }
    await _saveLogs();
    notifyListeners();
  }

  List<ActivityLog> searchLogs(String babyId, String query) {
    final q = query.toLowerCase();
    return logsForBaby(babyId).where((l) {
      if (l.note?.toLowerCase().contains(q) == true) return true;
      if (l.type.name.contains(q)) return true;
      return l.timestamp.toString().contains(q);
    }).toList();
  }

  List<ActivityLog> logsForDate(String babyId, DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return logsForBaby(babyId).where((l) {
      final ld = DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day);
      return ld == d;
    }).toList();
  }

  List<VaccineSchedule> vaccineSchedule(String babyId) {
    if (!_vaccineSchedules.containsKey(babyId)) {
      _vaccineSchedules[babyId] = defaultVaccines.map((v) => v).toList();
      _saveVaccines();
    }
    return _vaccineSchedules[babyId]!;
  }

  Future<void> toggleVaccine(String babyId, String vaccineId, {DateTime? date}) async {
    final list = vaccineSchedule(babyId);
    final i = list.indexWhere((v) => v.id == vaccineId);
    if (i < 0) return;
    final current = list[i];
    list[i] = current.copyWith(
      completed: !current.completed,
      completedDate: !current.completed ? (date ?? DateTime.now()) : null,
    );
    _vaccineSchedules[babyId] = list;
    await _saveVaccines();
    notifyListeners();
  }

  List<Map<String, dynamic>> growthData(String babyId) {
    return logsForBaby(babyId, type: ActivityType.growth)
        .map((l) => {
              'date': l.timestamp,
              'height': (l.data['height'] as num?)?.toDouble(),
              'weight': (l.data['weight'] as num?)?.toDouble(),
              'head': (l.data['head'] as num?)?.toDouble(),
            })
        .where((e) => e['height'] != null || e['weight'] != null || e['head'] != null)
        .toList()
      ..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
  }

  String exportData(String babyId) {
    final babyLogs = logsForBaby(babyId);
    final buffer = StringBuffer();
    buffer.writeln('BabyCare Notes Export');
    buffer.writeln('---');
    for (final log in babyLogs) {
      buffer.writeln('${log.timestamp.toIso8601String()} | ${log.type.name} | ${log.data} | ${log.note ?? ''}');
    }
    return buffer.toString();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
