import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/baby.dart';

class BabyProvider extends ChangeNotifier {
  static const _babiesKey = 'bcn_babies';
  static const _activeBabyKey = 'bcn_active_baby';

  final _uuid = const Uuid();
  List<Baby> _babies = [];
  String? _activeBabyId;

  List<Baby> get babies => List.unmodifiable(_babies);
  Baby? get activeBaby {
    if (_babies.isEmpty) return null;
    if (_activeBabyId != null) {
      return _babies.where((b) => b.id == _activeBabyId).firstOrNull ?? _babies.first;
    }
    return _babies.first;
  }

  bool get hasBabies => _babies.isNotEmpty;

  Future<void> init() async {
    await _load();
    notifyListeners();
  }

  Future<void> _load() async {
    final raw = await StorageService.instance.getString(_babiesKey);
    if (raw != null && raw.isNotEmpty) {
      _babies = StorageService.decodeList(raw).map(Baby.fromJson).toList();
    }
    _activeBabyId = await StorageService.instance.getString(_activeBabyKey);
  }

  Future<void> _save() async {
    await StorageService.instance.saveString(
      _babiesKey,
      StorageService.encodeList(_babies.map((b) => b.toJson()).toList()),
    );
    if (_activeBabyId != null) {
      await StorageService.instance.saveString(_activeBabyKey, _activeBabyId!);
    }
  }

  Future<Baby> addBaby({
    required String name,
    required DateTime birthDate,
    String? photoPath,
    String gender = 'unknown',
  }) async {
    final baby = Baby(
      id: _uuid.v4(),
      name: name,
      birthDate: birthDate,
      photoPath: photoPath,
      gender: gender,
    );
    _babies.add(baby);
    _activeBabyId = baby.id;
    await _save();
    notifyListeners();
    return baby;
  }

  Future<void> updateBaby(Baby baby) async {
    final i = _babies.indexWhere((b) => b.id == baby.id);
    if (i >= 0) {
      _babies[i] = baby;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteBaby(String id) async {
    _babies.removeWhere((b) => b.id == id);
    if (_activeBabyId == id) {
      _activeBabyId = _babies.isNotEmpty ? _babies.first.id : null;
    }
    await _save();
    notifyListeners();
  }

  void selectBaby(String id) {
    if (_babies.any((b) => b.id == id)) {
      _activeBabyId = id;
      _save();
      notifyListeners();
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
