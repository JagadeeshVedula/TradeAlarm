class TriggerEvent {
  final String id;
  final String alarmId;
  final DateTime triggeredAt;
  final double longPctAtTrigger;

  TriggerEvent({
    required this.id,
    required this.alarmId,
    required this.triggeredAt,
    required this.longPctAtTrigger,
  });

  factory TriggerEvent.fromJson(Map<String, dynamic> json) {
    return TriggerEvent(
      id: json['id'] as String,
      alarmId: json['alarmId'] as String,
      triggeredAt: DateTime.parse(json['triggeredAt'] as String).toLocal(),
      longPctAtTrigger: (json['longPctAtTrigger'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'alarmId': alarmId,
        'triggeredAt': triggeredAt.toUtc().toIso8601String(),
        'longPctAtTrigger': longPctAtTrigger,
      };
}
