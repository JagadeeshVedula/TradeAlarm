class AppConstants {
  static const String marketsInfoApiUrl = 'https://arbitrum-api.gmxinfra.io/markets/info';
  static const String primaryApiUrl = 'https://arbitrum.gmxapi.io/v1/pairs';
  static const String fallbackApiUrl = 'https://arbitrum.gmxapi.ai/v1/pairs';
  
  static const String defaultChain = 'Arbitrum';
  static const int defaultPollingIntervalSec = 15;
  static const double defaultHysteresisBuffer = 2.0;
  static const double defaultThreshold = 55.0;

  static const String prefsAlarmsKey = 'gmx_alarms_list_v1';
  static const String prefsTriggersKey = 'gmx_triggers_list_v1';
  static const String prefsLastSyncKey = 'gmx_last_sync_timestamp';
  static const String prefsSyncHealthKey = 'gmx_sync_health_status';
}
