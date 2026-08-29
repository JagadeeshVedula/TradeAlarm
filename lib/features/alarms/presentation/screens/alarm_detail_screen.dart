import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/alarm.dart';
import '../providers/alarm_provider.dart';
import 'create_edit_alarm_screen.dart';

class AlarmDetailScreen extends StatefulWidget {
  final String alarmId;

  const AlarmDetailScreen({super.key, required this.alarmId});

  @override
  State<AlarmDetailScreen> createState() => _AlarmDetailScreenState();
}

class _AlarmDetailScreenState extends State<AlarmDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Acknowledge alarm on view open to clear "triggered" highlight in list screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AlarmProvider>(context, listen: false).acknowledgeAlarm(widget.alarmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm:ss');

    return Consumer<AlarmProvider>(
      builder: (context, provider, child) {
        final alarm = provider.alarms.firstWhere(
          (a) => a.id == widget.alarmId,
          orElse: () => Alarm(
            id: '',
            tokenSymbol: 'Deleted',
            label: 'Alarm Deleted',
            direction: CrossDirection.up,
            threshold: 0,
            triggerMode: TriggerMode.oneTime,
            createdAt: DateTime.now(),
          ),
        );

        if (alarm.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Alarm Detail')),
            body: const Center(child: Text('Alarm no longer exists.')),
          );
        }

        final triggers = provider.getTriggersForAlarm(alarm.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(alarm.label),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateEditAlarmScreen(existingAlarm: alarm),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed),
                onPressed: () {
                  provider.deleteAlarm(alarm.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Parameter Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.cardBorderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              alarm.tokenSymbol,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            Switch(
                              value: alarm.enabled,
                              activeTrackColor: AppTheme.accentNeonGreen,
                              onChanged: (_) => provider.toggleAlarm(alarm.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppTheme.cardBorderDark),
                        const SizedBox(height: 12),

                        _buildInfoRow('Chain', alarm.chain),
                        _buildInfoRow('Direction', alarm.direction == CrossDirection.up ? 'Crosses UP ↑' : 'Crosses DOWN ↓'),
                        _buildInfoRow('Threshold', '${alarm.threshold}%'),
                        _buildInfoRow('Trigger Mode', alarm.triggerMode == TriggerMode.repeating ? 'Repeating' : 'One-time'),
                        if (alarm.triggerMode == TriggerMode.repeating)
                          _buildInfoRow('Re-arm Buffer', '${alarm.hysteresisBuffer}%'),
                        _buildInfoRow('Polling Interval', '${alarm.pollingIntervalSec} seconds'),
                        _buildInfoRow('Internal Armed State', alarm.armed ? 'ARMED (Ready to fire)' : 'DISARMED (Awaiting re-arm)'),
                        if (alarm.lastSeenPct != null)
                          _buildInfoRow('Last Evaluated OI', '${alarm.lastSeenPct!.round()}%'),
                        if (alarm.note != null && alarm.note!.isNotEmpty)
                          _buildInfoRow('Note', '"${alarm.note}"'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Trigger History Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trigger History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBorderDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${triggers.length} events',
                          style: const TextStyle(fontSize: 12, color: AppTheme.accentNeonGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (triggers.isEmpty)
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
                          Icon(Icons.history_toggle_off_rounded, size: 40, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 10),
                          const Text(
                            'No triggers recorded yet',
                            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: triggers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final event = triggers[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.cardBorderDark),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentAmber.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.notifications_active_rounded, color: AppTheme.accentAmber, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Crossed ${alarm.direction == CrossDirection.up ? "UP" : "DOWN"} at ${event.longPctAtTrigger.round()}%',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateFormat.format(event.triggeredAt.toLocal()),
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
