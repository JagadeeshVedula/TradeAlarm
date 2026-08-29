import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/alarm.dart';
import '../providers/alarm_provider.dart';
import 'alarm_detail_screen.dart';
import 'create_edit_alarm_screen.dart';

class AlarmsListScreen extends StatelessWidget {
  const AlarmsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.accentNeonGreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEditAlarmScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AlarmProvider>(
        builder: (context, provider, child) {
          final alarms = provider.alarms;

          if (alarms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off_rounded, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'No Alarms Configured',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to create your first GMX OI alarm.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateEditAlarmScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Alarm'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: alarms.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              final state = alarm.state;

              Color cardBorderColor;
              Color cardBgColor;
              Widget statusBadge;

              switch (state) {
                case AlarmState.triggered:
                  cardBorderColor = AppTheme.accentAmber;
                  cardBgColor = AppTheme.accentAmber.withValues(alpha: 0.14);
                  statusBadge = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'TRIGGERED',
                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  );
                  break;

                case AlarmState.active:
                  cardBorderColor = AppTheme.accentNeonGreen.withValues(alpha: 0.4);
                  cardBgColor = AppTheme.cardDark;
                  statusBadge = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentNeonGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ARMED',
                      style: TextStyle(color: AppTheme.accentNeonGreen, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  );
                  break;

                case AlarmState.disabled:
                  cardBorderColor = AppTheme.cardBorderDark;
                  cardBgColor = AppTheme.backgroundDark.withValues(alpha: 0.6);
                  statusBadge = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBorderDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PAUSED',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  );
                  break;
              }

              return Dismissible(
                key: Key(alarm.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
                ),
                onDismissed: (_) {
                  provider.deleteAlarm(alarm.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted "${alarm.label}"')),
                  );
                },
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlarmDetailScreen(alarmId: alarm.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorderColor, width: state == AlarmState.triggered ? 2 : 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                alarm.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: state == AlarmState.disabled ? AppTheme.textMuted : AppTheme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            statusBadge,
                            const SizedBox(width: 8),
                            Switch(
                              value: alarm.enabled,
                              activeTrackColor: AppTheme.accentNeonGreen,
                              onChanged: (_) => provider.toggleAlarm(alarm.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              alarm.direction == CrossDirection.up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              size: 16,
                              color: alarm.direction == CrossDirection.up ? AppTheme.accentNeonGreen : AppTheme.accentRed,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Target: ${alarm.direction == CrossDirection.up ? "≥" : "≤"} ${alarm.threshold}%',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${alarm.pollingIntervalSec}s poll',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        if (alarm.lastSeenPct != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.cardDark.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Text('Last seen OI: ', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                Text(
                                  '${alarm.lastSeenPct!.round()}%',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
