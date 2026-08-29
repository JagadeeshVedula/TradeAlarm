enum CrossDirection { up, down }

enum TriggerMode { oneTime, repeating }

enum AlarmState { active, triggered, disabled }

class Alarm {
  final String id;
  final String chain;
  final String tokenSymbol;
  final String label;
  final CrossDirection direction;
  final double threshold;
  final TriggerMode triggerMode;
  final double hysteresisBuffer;
  final int pollingIntervalSec;
  final String? note;
  final bool enabled;
  final bool armed;
  final double? lastSeenPct;
  final DateTime? lastTriggeredAt;
  final bool acknowledged;
  final DateTime createdAt;

  Alarm({
    required this.id,
    this.chain = 'Arbitrum',
    required this.tokenSymbol,
    required this.label,
    required this.direction,
    required this.threshold,
    required this.triggerMode,
    this.hysteresisBuffer = 2.0,
    this.pollingIntervalSec = 15,
    this.note,
    this.enabled = true,
    this.armed = true,
    this.lastSeenPct,
    this.lastTriggeredAt,
    this.acknowledged = true,
    required this.createdAt,
  });

  AlarmState get state {
    if (!enabled) return AlarmState.disabled;
    if (lastTriggeredAt != null && !acknowledged) return AlarmState.triggered;
    return AlarmState.active;
  }

  static String generateDefaultLabel(String tokenSymbol, CrossDirection direction, double threshold) {
    final arrow = direction == CrossDirection.up ? '↑' : '↓';
    final thresholdStr = threshold % 1 == 0 ? threshold.toInt().toString() : threshold.toStringAsFixed(1);
    return '$tokenSymbol Long OI $arrow $thresholdStr%';
  }

  Alarm copyWith({
    String? id,
    String? chain,
    String? tokenSymbol,
    String? label,
    CrossDirection? direction,
    double? threshold,
    TriggerMode? triggerMode,
    double? hysteresisBuffer,
    int? pollingIntervalSec,
    String? note,
    bool? enabled,
    bool? armed,
    double? lastSeenPct,
    bool clearLastSeenPct = false, // set true to explicitly reset lastSeenPct → null
    DateTime? lastTriggeredAt,
    bool? acknowledged,
    DateTime? createdAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      chain: chain ?? this.chain,
      tokenSymbol: tokenSymbol ?? this.tokenSymbol,
      label: label ?? this.label,
      direction: direction ?? this.direction,
      threshold: threshold ?? this.threshold,
      triggerMode: triggerMode ?? this.triggerMode,
      hysteresisBuffer: hysteresisBuffer ?? this.hysteresisBuffer,
      pollingIntervalSec: pollingIntervalSec ?? this.pollingIntervalSec,
      note: note ?? this.note,
      enabled: enabled ?? this.enabled,
      armed: armed ?? this.armed,
      lastSeenPct: clearLastSeenPct ? null : (lastSeenPct ?? this.lastSeenPct),
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
      acknowledged: acknowledged ?? this.acknowledged,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      chain: json['chain'] as String? ?? 'Arbitrum',
      tokenSymbol: json['tokenSymbol'] as String,
      label: json['label'] as String,
      direction: json['direction'] == 'down' ? CrossDirection.down : CrossDirection.up,
      threshold: (json['threshold'] as num).toDouble(),
      triggerMode: json['triggerMode'] == 'oneTime' ? TriggerMode.oneTime : TriggerMode.repeating,
      hysteresisBuffer: (json['hysteresisBuffer'] as num?)?.toDouble() ?? 2.0,
      pollingIntervalSec: (json['pollingIntervalSec'] as num?)?.toInt() ?? 15,
      note: json['note'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      armed: json['armed'] as bool? ?? true,
      lastSeenPct: (json['lastSeenPct'] as num?)?.toDouble(),
      lastTriggeredAt: json['lastTriggeredAt'] != null ? DateTime.parse(json['lastTriggeredAt'] as String).toLocal() : null,
      acknowledged: json['acknowledged'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chain': chain,
        'tokenSymbol': tokenSymbol,
        'label': label,
        'direction': direction == CrossDirection.up ? 'up' : 'down',
        'threshold': threshold,
        'triggerMode': triggerMode == TriggerMode.oneTime ? 'oneTime' : 'repeating',
        'hysteresisBuffer': hysteresisBuffer,
        'pollingIntervalSec': pollingIntervalSec,
        'note': note,
        'enabled': enabled,
        'armed': armed,
        'lastSeenPct': lastSeenPct,
        'lastTriggeredAt': lastTriggeredAt?.toUtc().toIso8601String(),
        'acknowledged': acknowledged,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };
}
