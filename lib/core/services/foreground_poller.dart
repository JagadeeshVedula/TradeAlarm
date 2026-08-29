import 'dart:async';
import 'dart:ui';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../api/gmx_api_client.dart';
import '../database/local_storage.dart';
import '../notifications/notification_service.dart';
import '../../features/alarms/domain/logic/alarm_evaluator.dart';
import '../../features/alarms/domain/models/alarm.dart';
import '../constants/top_tokens.dart';

@pragma('vm:entry-point')
void startCallback() {
  // Register Flutter plugin channels in this background isolate.
  // NOTE: Do NOT call WidgetsFlutterBinding.ensureInitialized() here —
  // flutter_foreground_task v8 initializes the engine internally.
  // Only DartPluginRegistrant is needed so platform channels work.
  DartPluginRegistrant.ensureInitialized();
  FlutterForegroundTask.setTaskHandler(ForegroundPollerTaskHandler());
}

class ForegroundPollerTaskHandler extends TaskHandler {
  final GmxApiClient _apiClient = GmxApiClient();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await NotificationService.initialize();
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    try {
      await NotificationService.initialize();

      final alarms = await LocalStorage.loadAlarms();
      final activeAlarms = alarms.where((a) => a.enabled).toList();

      if (activeAlarms.isEmpty) {
        FlutterForegroundTask.updateService(
          notificationTitle: 'GMX OI Alarm Service Active',
          notificationText: 'Watching 0 alarms • Idle',
        );
        await LocalStorage.updateSyncStatus('🟢 Idle · 0 active alarms', DateTime.now());
        return;
      }

      // Fetch market data from GMX
      final pairs = await _apiClient.fetchPairs();

      bool updatedAny = false;
      List<Alarm> newAlarms = [];

      for (var alarm in alarms) {
        if (!alarm.enabled) {
          newAlarms.add(alarm);
          continue;
        }

        // Find matching pair (picks highest-OI pool for this token)
        final matchingPair = TopTokens.findMatchingPair(alarm.tokenSymbol, pairs);

        final currentPct = matchingPair.longPct;
        final result = AlarmEvaluator.evaluate(
          alarm: alarm,
          currentPct: currentPct,
          now: DateTime.now(),
        );

        if (result.didTrigger) {
          updatedAny = true;
          if (result.triggerEvent != null) {
            await LocalStorage.addTriggerEvent(result.triggerEvent!);
          }

          // Trigger high priority system notification popup
          await NotificationService.showAlarmNotification(
            alarm: result.alarm,
            currentPct: currentPct,
          );

          // Update ongoing foreground service title
          FlutterForegroundTask.updateService(
            notificationTitle: '🚨 TRIGGERED: ${result.alarm.label}',
            notificationText: '${result.alarm.tokenSymbol} Long OI is now ${currentPct.round()}%',
          );
        } else if (result.alarm.lastSeenPct != alarm.lastSeenPct || result.alarm.armed != alarm.armed) {
          updatedAny = true;
        }

        newAlarms.add(result.alarm);
      }

      if (updatedAny) {
        await LocalStorage.saveAlarms(newAlarms);
      }

      final activeCount = newAlarms.where((a) => a.enabled).length;
      final triggeredCount = newAlarms.where((a) => a.state == AlarmState.triggered).length;
      final localTime = timestamp.toLocal();
      final timeStr = '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}';

      if (!newAlarms.any((a) => a.state == AlarmState.triggered)) {
        FlutterForegroundTask.updateService(
          notificationTitle: 'GMX OI Alarm Service Active',
          notificationText: 'Watching $activeCount alarms ($triggeredCount triggered) • $timeStr IST',
        );
      }

      await LocalStorage.updateSyncStatus('🟢 Connected · updated $timeStr IST', DateTime.now());
    } catch (e) {
      final localTime = timestamp.toLocal();
      final timeStr = '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}';
      FlutterForegroundTask.updateService(
        notificationTitle: 'GMX OI Alarm Service Active',
        notificationText: '🔴 Connection issue · retrying ($timeStr)',
      );
      await LocalStorage.updateSyncStatus('🔴 Connection issue · retrying', DateTime.now());
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}
}

class ForegroundPoller {
  static void initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'gmx_poller_service_channel',
        channelName: 'GMX Foreground Service',
        channelDescription: 'Maintains 15-second background polling for GMX OI alarms',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(15000), // 15s cadence
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
    } else {
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'GMX OI Alarm Service Active',
        notificationText: 'Initializing polling loop...',
        callback: startCallback,
      );
    }
  }

  static Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }
}
