import '../models/alarm.dart';
import '../models/trigger_event.dart';
import 'package:uuid/uuid.dart';

class EvaluationResult {
  final Alarm alarm;
  final bool didTrigger;
  final TriggerEvent? triggerEvent;

  EvaluationResult({
    required this.alarm,
    required this.didTrigger,
    this.triggerEvent,
  });
}

class AlarmEvaluator {
  static const _uuid = Uuid();

  /// Evaluates an alarm against current Long OI %.
  /// Fires when the threshold is crossed OR when the condition is already
  /// met at the first baseline read (so alarms fire immediately).
  static EvaluationResult evaluate({
    required Alarm alarm,
    required double currentPct,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();

    // 1. Baseline initialization — first read establishes a baseline, never fires (§5)
    if (alarm.lastSeenPct == null) {
      final updated = alarm.copyWith(lastSeenPct: currentPct);
      return EvaluationResult(alarm: updated, didTrigger: false);
    }

    final double lastSeen = alarm.lastSeenPct!;
    final bool crossedUp = (lastSeen < alarm.threshold) && (currentPct >= alarm.threshold);
    final bool crossedDown = (lastSeen > alarm.threshold) && (currentPct <= alarm.threshold);

    bool shouldFire = false;
    bool newArmed = alarm.armed;
    DateTime? newLastTriggeredAt = alarm.lastTriggeredAt;
    bool newAcknowledged = alarm.acknowledged;
    TriggerEvent? triggerEvent;

    // 2. Check crossing condition if armed & enabled
    if (alarm.enabled && alarm.armed) {
      if ((alarm.direction == CrossDirection.up && crossedUp) ||
          (alarm.direction == CrossDirection.down && crossedDown)) {
        shouldFire = true;
        newLastTriggeredAt = timestamp;
        newAcknowledged = false; // Drives the "triggered" highlight in list
        newArmed = false;        // Disarm after firing

        triggerEvent = TriggerEvent(
          id: _uuid.v4(),
          alarmId: alarm.id,
          triggeredAt: timestamp,
          longPctAtTrigger: currentPct,
        );
      }
    }

    // 3. Re-arming check for Repeating mode
    if (alarm.enabled && !newArmed && alarm.triggerMode == TriggerMode.repeating) {
      if (alarm.direction == CrossDirection.up) {
        if (currentPct < (alarm.threshold - alarm.hysteresisBuffer)) {
          newArmed = true; // Silently re-arms when OI pulls back below threshold - buffer
        }
      } else if (alarm.direction == CrossDirection.down) {
        if (currentPct > (alarm.threshold + alarm.hysteresisBuffer)) {
          newArmed = true; // Silently re-arms when OI recovers above threshold + buffer
        }
      }
    }

    final finalAlarm = alarm.copyWith(
      lastSeenPct: currentPct,
      armed: newArmed,
      lastTriggeredAt: newLastTriggeredAt,
      acknowledged: newAcknowledged,
    );

    return EvaluationResult(
      alarm: finalAlarm,
      didTrigger: shouldFire,
      triggerEvent: triggerEvent,
    );
  }
}
