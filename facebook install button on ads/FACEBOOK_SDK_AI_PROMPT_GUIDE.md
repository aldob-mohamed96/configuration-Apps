# 🤖 AI Agent Directive: Integrating Meta Facebook SDK & App Events in Flutter
> **Purpose:** Hand this file directly to any AI coding assistant (Cursor, Antigravity, Claude, ChatGPT) to autonomously and flawlessly integrate Facebook SDK / Meta App Events & App Install Tracking into any Flutter codebase.

---

## 🎯 Objective
Integrate the Meta / Facebook App Events SDK into a Flutter project to support:
1. Automatic App Install and Activation tracking (`fb_mobile_activate_app`).
2. Campaign attribution for Meta App Promotion ads.
3. Custom in-app event tracking.

---

## 📋 Required Inputs from User
Before editing files, verify you have these 4 variables (request them if missing):
```yaml
FACEBOOK_APP_ID: "1003409726093633" # Example (numeric)
FACEBOOK_CLIENT_TOKEN: "403196df8e10cd71601b022eaff33dd0" # 32-char hex string from Meta Advanced Settings
FACEBOOK_APP_NAME: "My App Name" # App display name
BUNDLE_ID: "com.example.app" # iOS Bundle ID & Android Package Name
```

---

## 🛠️ Step-by-Step Execution Plan for AI

### Step 1: Add Flutter Dependency
Run:
```bash
flutter pub add facebook_app_events:^0.30.5
```
Or append to `pubspec.yaml` under `dependencies:`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  facebook_app_events: ^0.30.5
```

---

### Step 2: Configure Android Native Files

#### File 1: `android/app/src/main/res/values/strings.xml`
Create or update this file:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="facebook_app_id">{{FACEBOOK_APP_ID}}</string>
    <string name="fb_login_protocol_scheme">fb{{FACEBOOK_APP_ID}}</string>
    <string name="facebook_client_token">{{FACEBOOK_CLIENT_TOKEN}}</string>
</resources>
```

#### File 2: `android/app/src/main/AndroidManifest.xml`
Ensure internet permission exists before `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
Inside the `<application>` tag, append:
```xml
        <meta-data
            android:name="com.facebook.sdk.ApplicationId"
            android:value="@string/facebook_app_id" />
        <meta-data
            android:name="com.facebook.sdk.ClientToken"
            android:value="@string/facebook_client_token" />
```

---

### Step 3: Configure iOS Native Files

#### File 1: `ios/Runner/Info.plist`
Inside `<plist><dict>`, add/merge the following keys:
```xml
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>fb{{FACEBOOK_APP_ID}}</string>
			</array>
		</dict>
	</array>
	<key>FacebookAppID</key>
	<string>{{FACEBOOK_APP_ID}}</string>
	<key>FacebookClientToken</key>
	<string>{{FACEBOOK_CLIENT_TOKEN}}</string>
	<key>FacebookDisplayName</key>
	<string>{{FACEBOOK_APP_NAME}}</string>
	<key>FacebookAutoLogAppEventsEnabled</key>
	<true/>
	<key>FacebookAdvertiserIDCollectionEnabled</key>
	<true/>
```

#### File 2: CocoaPods Installation
Run the command with UTF-8 encoding environment flags to avoid Ruby encoding crashes on macOS:
```bash
cd ios && LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install && cd ..
```

---

### Step 4: Create Dart Service Wrapper
Create file: `lib/core/service/generic/facebook_events_service.dart` (or your project's appropriate service directory):

```dart
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class FacebookEventsService {
  FacebookEventsService._();

  static final FacebookEventsService instance = FacebookEventsService._();
  static final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  FacebookAppEvents get client => _facebookAppEvents;

  /// Initializes auto-logging & advertiser ID collection.
  /// NOTE: DO NOT use deprecated setAdvertiserTracking. Use setAdvertiserIdCollectionEnabled.
  Future<void> initialize() async {
    try {
      await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
      await _facebookAppEvents.setAdvertiserIdCollectionEnabled(true);
      debugPrint('✅ [FacebookSDK] Initialized successfully. AutoLogAppEvents enabled.');
    } catch (e) {
      debugPrint('❌ FacebookEventsService init error: $e');
    }
  }

  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
    double? valueToSum,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: name,
        parameters: parameters,
        valueToSum: valueToSum,
      );
      debugPrint('📊 [FacebookSDK] Event logged: $name, params: $parameters');
    } catch (e) {
      debugPrint('❌ FacebookEventsService logEvent error: $e');
    }
  }

  Future<void> logViewContent({
    String? id,
    String? type,
    String? currency,
    double? price,
  }) async {
    try {
      await _facebookAppEvents.logViewContent(
        id: id,
        type: type,
        currency: currency,
        price: price,
      );
    } catch (e) {
      debugPrint('❌ FacebookEventsService logViewContent error: $e');
    }
  }

  Future<void> logCompletedRegistration({String? registrationMethod}) async {
    try {
      await _facebookAppEvents.logCompletedRegistration(
        registrationMethod: registrationMethod,
      );
    } catch (e) {
      debugPrint('❌ FacebookEventsService logCompletedRegistration error: $e');
    }
  }

  Future<void> setUserID(String id) async {
    try {
      await _facebookAppEvents.setUserID(id);
    } catch (e) {
      debugPrint('❌ FacebookEventsService setUserID error: $e');
    }
  }

  Future<void> clearUserID() async {
    try {
      await _facebookAppEvents.clearUserID();
    } catch (e) {
      debugPrint('❌ FacebookEventsService clearUserID error: $e');
    }
  }
}
```

---

### Step 5: Initialize in `main.dart`
In the app's initialization sequence:
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/core/service/generic/facebook_events_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Non-blocking asynchronous initialization
  unawaited(FacebookEventsService.instance.initialize());

  runApp(const MyApp());
}
```

---

## 🔍 Verification & Self-Check Rules for AI

1. **Static Analysis:**
   Run:
   ```bash
   flutter analyze lib/core/service/generic/facebook_events_service.dart lib/main.dart
   ```
   Ensure 0 errors and 0 deprecation warnings.

2. **Check for Deprecated API:**
   Ensure `setAdvertiserTracking` is **NOT** used (it was deprecated in SDK 17+ in favor of `setAdvertiserIdCollectionEnabled`).

3. **Check Client Token Format:**
   Validate that `FACEBOOK_CLIENT_TOKEN` is a 32-character hexadecimal string, NOT the App Secret and NOT a User Access Token.

4. **Live Log Verification Commands:**
   - **iOS Simulator:**
     ```bash
     xcrun simctl spawn booted log stream --predicate 'processImagePath CONTAINS "Runner" AND (eventMessage CONTAINS[c] "FBSDK" OR eventMessage CONTAINS[c] "FacebookSDK")' --style compact
     ```
   - **Android Device/Emulator:**
     ```bash
     adb logcat -s FacebookSDK:V
     ```
