import 'package:flutter_test/flutter_test.dart';
import 'package:gmx_oi_alarm/features/alarms/domain/models/alarm.dart';
import 'package:gmx_oi_alarm/features/alarms/domain/logic/alarm_evaluator.dart';

void main() {
  group('AlarmEvaluator §5.2 Worked Example Test', () {
    late Alarm testAlarm;

    setUp(() {
      testAlarm = Alarm(
        id: 'test-1',
        tokenSymbol: 'BTC-USD',
        label: 'BTC-USD Long OI ↑ 55%',
        direction: CrossDirection.up,
        threshold: 55.0,
        triggerMode: TriggerMode.repeating,
        hysteresisBuffer: 2.0,
        createdAt: DateTime.now(),
      );
    });

    test('Runs worked example sequence t0 through t7 accurately', () {
      // t0: 52% baseline
      var r0 = AlarmEvaluator.evaluate(alarm: testAlarm, currentPct: 52.0);
      expect(r0.didTrigger, false);
      expect(r0.alarm.armed, true);
      expect(r0.alarm.lastSeenPct, 52.0);

      // t1: 54% (54 < 55) -> no trigger
      var r1 = AlarmEvaluator.evaluate(alarm: r0.alarm, currentPct: 54.0);
      expect(r1.didTrigger, false);
      expect(r1.alarm.armed, true);

      // t2: 56% (54 -> 56 passes 55) -> FIRES!
      var r2 = AlarmEvaluator.evaluate(alarm: r1.alarm, currentPct: 56.0);
      expect(r2.didTrigger, true);
      expect(r2.alarm.armed, false);
      expect(r2.alarm.acknowledged, false);
      expect(r2.triggerEvent, isNotNull);

      // t3: 57% -> not armed, silent
      var r3 = AlarmEvaluator.evaluate(alarm: r2.alarm, currentPct: 57.0);
      expect(r3.didTrigger, false);
      expect(r3.alarm.armed, false);

      // t4: 55.5% -> silent
      var r4 = AlarmEvaluator.evaluate(alarm: r3.alarm, currentPct: 55.5);
      expect(r4.didTrigger, false);
      expect(r4.alarm.armed, false);

      // t5: 53% -> 53 is not < 53 (threshold 55 - 2 buffer = 53), not re-armed yet
      var r5 = AlarmEvaluator.evaluate(alarm: r4.alarm, currentPct: 53.0);
      expect(r5.didTrigger, false);
      expect(r5.alarm.armed, false);

      // t6: 52% -> 52 < 53 -> silently re-arms!
      var r6 = AlarmEvaluator.evaluate(alarm: r5.alarm, currentPct: 52.0);
      expect(r6.didTrigger, false);
      expect(r6.alarm.armed, true); // re-armed!

      // t7: 56% -> FIRES AGAIN!
      var r7 = AlarmEvaluator.evaluate(alarm: r6.alarm, currentPct: 56.0);
      expect(r7.didTrigger, true);
      expect(r7.alarm.armed, false);
    });

    test('One-time mode does not re-arm', () {
      var oneTimeAlarm = testAlarm.copyWith(triggerMode: TriggerMode.oneTime);
      var r0 = AlarmEvaluator.evaluate(alarm: oneTimeAlarm, currentPct: 52.0);
      var r1 = AlarmEvaluator.evaluate(alarm: r0.alarm, currentPct: 56.0); // fires
      expect(r1.didTrigger, true);

      var r2 = AlarmEvaluator.evaluate(alarm: r1.alarm, currentPct: 50.0); // drops below hysteresis
      expect(r2.alarm.armed, false); // stays disarmed
    });

    test('First read above threshold establishes baseline and NEVER fires (§5)', () {
      // Alarm threshold 55%, initial currentPct 60%
      var r0 = AlarmEvaluator.evaluate(alarm: testAlarm, currentPct: 60.0);
      expect(r0.didTrigger, false); // Spec §5: baseline read never fires!
      expect(r0.alarm.lastSeenPct, 60.0);
      expect(r0.alarm.armed, true);

      // Next poll at 62% -> no crossing since lastSeen was 60% (already > 55%)
      var r1 = AlarmEvaluator.evaluate(alarm: r0.alarm, currentPct: 62.0);
      expect(r1.didTrigger, false);
    });

    test('Crosses DOWN direction evaluation and re-arming', () {
      var downAlarm = testAlarm.copyWith(
        direction: CrossDirection.down,
        threshold: 45.0,
        hysteresisBuffer: 2.0,
        label: 'BTC-USD Long OI ↓ 45%',
      );

      // t0: baseline 48%
      var r0 = AlarmEvaluator.evaluate(alarm: downAlarm, currentPct: 48.0);
      expect(r0.didTrigger, false);

      // t1: 43% -> (48 > 45 >= 43) -> FIRES!
      var r1 = AlarmEvaluator.evaluate(alarm: r0.alarm, currentPct: 43.0);
      expect(r1.didTrigger, true);
      expect(r1.alarm.armed, false);

      // t2: 46% -> 46 is not > (45 + 2 = 47) -> not re-armed yet
      var r2 = AlarmEvaluator.evaluate(alarm: r1.alarm, currentPct: 46.0);
      expect(r2.didTrigger, false);
      expect(r2.alarm.armed, false);

      // t3: 48% -> 48 > 47 -> silently re-arms!
      var r3 = AlarmEvaluator.evaluate(alarm: r2.alarm, currentPct: 48.0);
      expect(r3.didTrigger, false);
      expect(r3.alarm.armed, true);
    });
  });
}
