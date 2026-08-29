import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/alarms/domain/models/alarm.dart';
import '../../features/alarms/domain/models/trigger_event.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Load all saved alarms
  static Future<List<Alarm>> loadAlarms() async {
    final prefs = await _instance;
    final jsonString = prefs.getString(AppConstants.prefsAlarmsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => Alarm.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save alarms list
  static Future<void> saveAlarms(List<Alarm> alarms) async {
    final prefs = await _instance;
    final jsonList = alarms.map((a) => a.toJson()).toList();
    await prefs.setString(AppConstants.prefsAlarmsKey, json.encode(jsonList));
  }

  /// Load all trigger history events
  static Future<List<TriggerEvent>> loadTriggers() async {
    final prefs = await _instance;
    final jsonString = prefs.getString(AppConstants.prefsTriggersKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => TriggerEvent.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Add trigger event
  static Future<void> addTriggerEvent(TriggerEvent event) async {
    final triggers = await loadTriggers();
    triggers.insert(0, event); // Latest first
    final prefs = await _instance;
    final jsonList = triggers.map((t) => t.toJson()).toList();
    await prefs.setString(AppConstants.prefsTriggersKey, json.encode(jsonList));
  }

  /// Save last sync timestamp & status
  static Future<void> updateSyncStatus(String statusText, DateTime timestamp) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.prefsSyncHealthKey, statusText);
    await prefs.setString(AppConstants.prefsLastSyncKey, timestamp.toUtc().toIso8601String());
  }

  /// Get last sync status
  static Future<Map<String, dynamic>> getSyncStatus() async {
    final prefs = await _instance;
    final status = prefs.getString(AppConstants.prefsSyncHealthKey) ?? 'Not started';
    final lastSync = prefs.getString(AppConstants.prefsLastSyncKey);
    return {
      'status': status,
      'lastSync': lastSync != null ? DateTime.parse(lastSync).toLocal() : null,
    };
  }
}
