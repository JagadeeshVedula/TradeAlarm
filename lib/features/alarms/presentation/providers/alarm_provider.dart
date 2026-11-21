import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/api/gmx_api_client.dart';
import '../../../../core/database/local_storage.dart';
import '../../../../core/notifications/notification_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../../../../core/services/foreground_poller.dart';
import '../../domain/logic/alarm_evaluator.dart';
import '../../domain/models/alarm.dart';
import '../../domain/models/token_pair.dart';
import '../../domain/models/trigger_event.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/top_tokens.dart';

class AlarmProvider extends ChangeNotifier {
  final GmxApiClient _apiClient = GmxApiClient();

  List<Alarm> _alarms = [];
  List<TriggerEvent> _triggers = [];
  List<TokenPair> _livePairs = [];
  String _syncStatus = '🟢 Connected · updated just now';
  DateTime? _lastSyncTime;
  bool _isLoading = true;
  Timer? _uiPollerTimer;

  List<Alarm> get alarms => List.unmodifiable(_alarms);
  List<TriggerEvent> get triggers => List.unmodifiable(_triggers);
  List<TokenPair> get livePairs => List.unmodifiable(_livePairs);
  List<TokenOption> get allTokens => TopTokens.getAllTokens(livePairs: _livePairs);
  String get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isLoading => _isLoading;

  int get activeAlarmsCount => _alarms.where((a) => a.enabled).length;
  int get triggeredAlarmsCount => _alarms.where((a) => a.state == AlarmState.triggered).length;

  AlarmProvider() {
    init();
  }

  Future<void> init() async {
    await NotificationService.initialize();
    await NotificationService.requestPermissions();
    
    // Request Android 13+ Notification and Battery Exemption permissions
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
    
    ForegroundPoller.initService();

    await loadData();
    await fetchLivePairs();
    
    // Immediately evaluate all existing alarms against fresh live data.
    // This ensures the UI shows correct values from the moment the app opens,
    // without waiting for the 15-second background service cycle.
    await triggerManualPoll();
    
    await ForegroundPoller.startService();

    // Setup periodic UI refresh timer to sync background state
    _uiPollerTimer?.cancel();
    _uiPollerTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await loadData();
    });
  }


  @override
  void dispose() {
    _uiPollerTimer?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    _alarms = await LocalStorage.loadAlarms();
    _triggers = await LocalStorage.loadTriggers();
    
    final statusData = await LocalStorage.getSyncStatus();
    _lastSyncTime = statusData['lastSync'] as DateTime?;
    final rawStatus = statusData['status'] as String? ?? '🟢 Connected · active';
    if (_lastSyncTime != null && (rawStatus.contains('🟢') || rawStatus.contains('Connected'))) {
      _syncStatus = '🟢 Connected · updated ${Formatters.formatTimeAgo(_lastSyncTime)}';
    } else {
      _syncStatus = rawStatus;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLivePairs() async {
    try {
      _livePairs = await _apiClient.fetchPairs();
      _lastSyncTime = DateTime.now();
      _syncStatus = '🟢 Connected · updated ${Formatters.formatTimeAgo(_lastSyncTime)}';
      await LocalStorage.updateSyncStatus(_syncStatus, _lastSyncTime!);
    } catch (e) {
      _syncStatus = '🔴 Connection issue · retrying';
      await LocalStorage.updateSyncStatus(_syncStatus, DateTime.now());
    }
    notifyListeners();
  }

  Future<void> addAlarm(Alarm alarm) async {
    _alarms.add(alarm);
    await LocalStorage.saveAlarms(_alarms);
    notifyListeners();
    await triggerManualPoll();
  }

  Future<void> updateAlarm(Alarm updated) async {
    final index = _alarms.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _alarms[index] = updated;
      await LocalStorage.saveAlarms(_alarms);
      notifyListeners();
    }
  }

  Future<void> deleteAlarm(String alarmId) async {
    _alarms.removeWhere((a) => a.id == alarmId);
    await LocalStorage.saveAlarms(_alarms);
    notifyListeners();
  }

  Future<void> toggleAlarm(String alarmId) async {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      final current = _alarms[index];
      final isEnabling = !current.enabled;
      final updated = current.copyWith(
        enabled: isEnabling,
        armed: isEnabling,
        // When re-enabling, reset baseline so the evaluator can fire
        // immediately on the next poll if the condition is already met.
        clearLastSeenPct: isEnabling,
      );
      _alarms[index] = updated;
      await LocalStorage.saveAlarms(_alarms);
      notifyListeners();
    }
  }


  Future<void> acknowledgeAlarm(String alarmId) async {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      final current = _alarms[index];
      if (!current.acknowledged) {
        final updated = current.copyWith(acknowledged: true);
        _alarms[index] = updated;
        await LocalStorage.saveAlarms(_alarms);
        notifyListeners();
      }
    }
  }

  List<TriggerEvent> getTriggersForAlarm(String alarmId) {
    return _triggers.where((t) => t.alarmId == alarmId).toList();
  }

  Future<void> triggerManualPoll() async {
    if (_livePairs.isEmpty) {
      await fetchLivePairs();
    }

    if (_livePairs.isEmpty) return;

    bool updatedAny = false;

    for (int i = 0; i < _alarms.length; i++) {
      final alarm = _alarms[i];
      if (!alarm.enabled) continue;

      final matchingPair = TopTokens.findMatchingPair(alarm.tokenSymbol, _livePairs);

      final result = AlarmEvaluator.evaluate(
        alarm: alarm,
        currentPct: matchingPair.longPct,
        now: DateTime.now(),
      );

      if (result.didTrigger) {
        updatedAny = true;
        if (result.triggerEvent != null) {
          _triggers.insert(0, result.triggerEvent!);
          await LocalStorage.addTriggerEvent(result.triggerEvent!);
        }
        await NotificationService.showAlarmNotification(
          alarm: result.alarm,
          currentPct: matchingPair.longPct,
        );
      } else if (result.alarm.lastSeenPct != alarm.lastSeenPct || result.alarm.armed != alarm.armed) {
        updatedAny = true;
      }

      _alarms[i] = result.alarm;
    }

    if (updatedAny) {
      await LocalStorage.saveAlarms(_alarms);
      notifyListeners();
    }
  }
}
