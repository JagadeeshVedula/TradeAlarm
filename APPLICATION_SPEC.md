# GMX Open Interest Alarm — Application Architecture & Extension Spec

> **Purpose of this Document:**  
> This specification details the codebase architecture, data schemas, background polling service hooks, alarm evaluation algorithms, and step-by-step developer guidelines. Future developers and AI agents can introduce new features or modify existing behavior by following this spec without having to read through the entire framework source code.

---

## 1. Project Overview & Tech Stack

- **Framework:** Flutter 3.44.1 (Dart 3.12)
- **Target Platform:** Android (API Level 23+)
- **Architecture Pattern:** Clean Layered Architecture (Domain, Core, Data, Presentation)
- **State Management:** Reactive `Provider` (`ChangeNotifier`)
- **Background Execution:** Android Foreground Service (`flutter_foreground_task`) maintaining a 15-second polling loop
- **Notifications:** `flutter_local_notifications` with high importance channels & sound/vibration
- **Data Persistence:** `shared_preferences` JSON-serialized storage

---

## 2. Directory & Component Map

```text
lib/
├── core/
│   ├── api/
│   │   └── gmx_api_client.dart       # REST client fetching GMX market data with fallback URL handling
│   ├── constants/
│   │   ├── app_constants.dart        # Endpoints, default thresholds, hysteresis buffers, storage keys
│   │   └── top_tokens.dart           # Static dataset of top 30 GMX Arbitrum Perp markets
│   ├── database/
│   │   └── local_storage.dart        # JSON-serialized persistence for Alarms, Triggers, and Sync Status
│   ├── notifications/
│   │   └── notification_service.dart # Local notification channel configuration & alert dispatcher
│   ├── services/
│   │   └── foreground_poller.dart    # Android Foreground Service executing on-device 15s polling loop
│   └── theme/
│       └── app_theme.dart            # GMX Dark Theme (Neon Emerald, Glassmorphism, Outfit Font)
├── features/
│   └── alarms/
│       ├── domain/
│       │   ├── logic/
│       │   │   └── alarm_evaluator.dart # Pure edge-triggered alarm evaluation engine with hysteresis
│       │   └── models/
│       │       ├── alarm.dart        # Core Alarm entity schema & state logic
│       │       ├── token_pair.dart   # GMX Market Pair DTO & longPct / shortPct calculator
│       │       └── trigger_event.dart# Timestamped crossing event log model
│       └── presentation/
│           ├── providers/
│           │   └── alarm_provider.dart# App state management & UI synchronization
│           ├── screens/
│           │   ├── home_screen.dart               # Connection status, quick metrics, action buttons
│           │   ├── create_edit_alarm_screen.dart  # Alarm form + Live OI preview card
│           │   ├── alarms_list_screen.dart        # Color-coded state list (Active, Triggered, Disabled)
│           │   └── alarm_detail_screen.dart       # Detailed settings & nested trigger history
│           └── widgets/
│               ├── live_preview_card.dart         # Dynamic Long/Short OI ratio visual bar
│               ├── metric_card.dart               # Glassmorphic summary metric widget
│               └── status_banner.dart             # Connection & polling health banner
└── main.dart                         # Entry point, Provider injection, Theme application
```

---

## 3. Core Metric & Calculation Rules

GMX Open Interest percentages match GMX's official UI:

$$\text{longPct} = \frac{\text{longInterestUsd}}{\text{longInterestUsd} + \text{shortInterestUsd}} \times 100$$

$$\text{shortPct} = 100 - \text{longPct}$$

- **Spot Pool Filtering:** Pools where `long_open_interest` or `short_open_interest` are missing/null or sum to `0` are filtered out automatically by `TokenPair.isValidPerp`.

---

## 4. Data Models & JSON Schemas

### 4.1 `Alarm` Model (`lib/features/alarms/domain/models/alarm.dart`)

```json
{
  "id": "e6a0d2f1-2856-4c7b-a320-1b2c3d4e5f6a",
  "chain": "Arbitrum",
  "tokenSymbol": "BTC-USD",
  "label": "BTC-USD Long OI ↑ 55%",
  "direction": "up",
  "threshold": 55.0,
  "triggerMode": "repeating",
  "hysteresisBuffer": 2.0,
  "pollingIntervalSec": 15,
  "note": "Contrarian long signal",
  "enabled": true,
  "armed": true,
  "lastSeenPct": 54.2,
  "lastTriggeredAt": "2026-08-01T12:00:00.000Z",
  "acknowledged": false,
  "createdAt": "2026-08-01T10:00:00.000Z"
}
```

- **States (`alarm.state`):**
  - **`AlarmState.disabled`**: when `enabled == false` (greyed out card styling).
  - **`AlarmState.triggered`**: when `lastTriggeredAt != null && acknowledged == false` (highlighted amber card + badge).
  - **`AlarmState.active`**: default when `enabled == true` and acknowledged (normal glass card styling).

### 4.2 `TriggerEvent` Model (`lib/features/alarms/domain/models/trigger_event.dart`)

```json
{
  "id": "c1f2e3d4-5678-90ab-cdef-1234567890ab",
  "alarmId": "e6a0d2f1-2856-4c7b-a320-1b2c3d4e5f6a",
  "triggeredAt": "2026-08-01T12:00:00.000Z",
  "longPctAtTrigger": 56.4
}
```

---

## 5. Alarm Evaluation Engine (`AlarmEvaluator`)

Evaluation is pure, deterministic, and edge-triggered with a hysteresis re-arm buffer:

1. **Baseline Phase (`lastSeenPct == null`):**
   - Sets `lastSeenPct = currentPct` without firing.
2. **Crossing Detection:**
   - `crossedUp = (lastSeenPct < threshold) && (currentPct >= threshold)`
   - `crossedDown = (lastSeenPct > threshold) && (currentPct <= threshold)`
3. **Firing Condition (`armed == true` and `enabled == true`):**
   - If (`direction == UP` & `crossedUp`) or (`direction == DOWN` & `crossedDown`):
     - Sets `didTrigger = true`.
     - Records `TriggerEvent`.
     - Sets `lastTriggeredAt = now()`, `acknowledged = false`, `armed = false`.
4. **Re-arming Phase (`armed == false`, `enabled == true`, `triggerMode == REPEATING`):**
   - If `direction == UP` and `currentPct < (threshold - hysteresisBuffer)`: `armed = true` (silently re-arms).
   - If `direction == DOWN` and `currentPct > (threshold + hysteresisBuffer)`: `armed = true` (silently re-arms).
   - For `oneTime` mode: `armed` remains `false` until the user manually re-enables the alarm.

---

## 6. GMX API & Failover Integration

- **Primary Endpoint:** `GET https://arbitrum.gmxapi.io/v1/pairs`
- **Fallback Endpoint:** `GET https://arbitrum.gmxapi.ai/v1/pairs`
- `GmxApiClient` automatically tries the primary endpoint with a 10-second timeout, failing over to the secondary host if an HTTP or socket error occurs.

---

## 7. Background Service & Foreground Execution

- **Service Wrapper:** `ForegroundPoller` (`lib/core/services/foreground_poller.dart`)
- **Android Manifest Entry:**
  ```xml
  <service
      android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
      android:foregroundServiceType="dataSync"
      android:exported="false" />
  ```
- **Ongoing Notification:** `"GMX OI Alarm Service Active • Watching X active alarms • Updated 12:45:00"`
- **Notification Triggering:** On crossing detection, `NotificationService.showAlarmNotification()` fires an Android High Priority alert with sound and vibration.

---

## 8. How to Add New Features (Developer Guide)

### 8.1 Adding a New Supported Chain (e.g. Avalanche)
1. Open [app_constants.dart](file:///d:/Personal/Trade_Alarm/lib/core/constants/app_constants.dart) and add the new API endpoint constant.
2. Update [gmx_api_client.dart](file:///d:/Personal/Trade_Alarm/lib/core/api/gmx_api_client.dart) to accept a `chain` parameter in `fetchPairs()`.
3. In [create_edit_alarm_screen.dart](file:///d:/Personal/Trade_Alarm/lib/features/alarms/presentation/screens/create_edit_alarm_screen.dart), add `'Avalanche'` to the Chain dropdown items.

### 8.2 Adding Dynamic Live Token List Ranking
1. Open [top_tokens.dart](file:///d:/Personal/Trade_Alarm/lib/core/constants/top_tokens.dart).
2. Modify `TopTokens.list` getter to merge static options with live pairs fetched dynamically from `GmxApiClient.fetchPairs()`.

### 8.3 Adding Absolute USD Open Interest Threshold Alarms
1. Update `Alarm` model in [alarm.dart](file:///d:/Personal/Trade_Alarm/lib/features/alarms/domain/models/alarm.dart) to add an enum `ThresholdType { percentage, absoluteUsd }`.
2. Update [alarm_evaluator.dart](file:///d:/Personal/Trade_Alarm/lib/features/alarms/domain/logic/alarm_evaluator.dart) to compare against `matchingPair.totalOpenInterestUsd` when `ThresholdType.absoluteUsd` is selected.
3. Update [create_edit_alarm_screen.dart](file:///d:/Personal/Trade_Alarm/lib/features/alarms/presentation/screens/create_edit_alarm_screen.dart) to display a toggle between `%` and `USD ($)`.

---

## 9. Build & Verification Commands

- **Run Unit Tests:**
  ```bash
  flutter test test/alarm_evaluator_test.dart
  ```
- **Run Static Analysis:**
  ```bash
  flutter analyze
  ```
- **Build Release APK:**
  ```bash
  flutter build apk --release
  ```
  *Output APK location:* `build/app/outputs/flutter-apk/app-release.apk`
