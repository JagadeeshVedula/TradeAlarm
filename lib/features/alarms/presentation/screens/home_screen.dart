import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/alarm.dart';
import '../providers/alarm_provider.dart';
import '../widgets/live_clock_widget.dart';
import '../widgets/metric_card.dart';
import '../widgets/status_banner.dart';
import 'create_edit_alarm_screen.dart';
import 'alarms_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlarmProvider>(
      builder: (context, provider, child) {
        final activeCount = provider.activeAlarmsCount;
        final triggeredCount = provider.triggeredAlarmsCount;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentPurple.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: AppTheme.accentNeonGreen,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'GMX OI Alarm',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Arbitrum Open Interest Signals',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.cardBorderDark),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_outlined, color: AppTheme.accentNeonGreen, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Arbitrum',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Real-time Live Clock & Sync Widget
                  const LiveClockWidget(),
                  const SizedBox(height: 12),

                  // Connection/Data status banner
                  StatusBanner(
                    statusText: provider.syncStatus,
                    onRefresh: () => provider.triggerManualPoll(),
                  ),
                  const SizedBox(height: 24),

                  // Metrics summary
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Active Alarms',
                          value: '$activeCount',
                          icon: Icons.alarm_on_rounded,
                          accentColor: AppTheme.accentNeonGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          title: 'Triggered',
                          value: '$triggeredCount',
                          icon: Icons.error_outline_rounded,
                          accentColor: triggeredCount > 0 ? AppTheme.accentAmber : AppTheme.textMuted,
                          badge: triggeredCount > 0 ? 'ALERT' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Primary Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateEditAlarmScreen()),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 24),
                      label: const Text('+ Create Alarm'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AlarmsListScreen()),
                        );
                      },
                      icon: const Icon(Icons.list_alt_rounded, size: 22),
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('View Alarms'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBorderDark,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$activeCount active · $triggeredCount triggered',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.accentNeonGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Recent Active Alarms Quick List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Alarms',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AlarmsListScreen()),
                          );
                        },
                        child: const Text('See All', style: TextStyle(color: AppTheme.accentNeonGreen)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (provider.alarms.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorderDark),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.alarm_add_rounded, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'No alarms configured yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap "+ Create Alarm" to set your first OI threshold alert.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.alarms.length.clamp(0, 3),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final alarm = provider.alarms[index];
                        final isTriggered = alarm.state == AlarmState.triggered;

                        return Container(
                          decoration: BoxDecoration(
                            color: isTriggered ? AppTheme.accentAmber.withValues(alpha: 0.12) : AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isTriggered ? AppTheme.accentAmber : AppTheme.cardBorderDark,
                              width: isTriggered ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isTriggered
                                  ? AppTheme.accentAmber.withValues(alpha: 0.2)
                                  : AppTheme.accentNeonGreen.withValues(alpha: 0.15),
                              child: Icon(
                                isTriggered ? Icons.warning_amber_rounded : Icons.notifications_active_outlined,
                                color: isTriggered ? AppTheme.accentAmber : AppTheme.accentNeonGreen,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              alarm.label,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Threshold: ${alarm.threshold}% • ${alarm.triggerMode == TriggerMode.repeating ? "Repeating" : "One-time"}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            trailing: Switch(
                              value: alarm.enabled,
                              activeTrackColor: AppTheme.accentNeonGreen,
                              onChanged: (_) => provider.toggleAlarm(alarm.id),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
