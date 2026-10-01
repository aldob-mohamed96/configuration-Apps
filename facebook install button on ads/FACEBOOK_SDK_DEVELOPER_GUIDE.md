# 📘 الدليل الشامل لربط Facebook SDK و Meta App Events في أي تطبيق Flutter
> **مرجع تقني وإرشادي للمطور ومدير المشروع**  
> يغطي هذا الدليل كافة المتطلبات النظرية والعملية لربط تتبع حملات تثبيت التطبيق (App Installs) وتسجيل الأحداث (App Events) بين تطبيق فلاتر ولوحة تحكم Meta.

---

## 📑 الفهرس
1. [الهدف والفوائد](#1-الهدف-والفوائد)
2. [المتطلبات المسبقة والبيانات المطلوبة](#2-المتطلبات-المسبقة-والبيانات-المطلوبة)
3. [خطوات إعداد لوحة Meta for Developers](#3-خطوات-إعداد-لوحة-meta-for-developers)
4. [التنفيذ البرمجي خطوة بخطوة](#4-التنفيذ-البرمجي-خطوة-بخطوة)
   - [أ. حزم فلاتر (pubspec.yaml)](#أ-حزم-فلاتر-pubspecyaml)
   - [ب. إعدادات نظام Android](#ب-إعدادات-نظام-android)
   - [ج. إعدادات نظام iOS](#ج-إعدادات-نظام-ios)
   - [د. كود خدمة الفلاتر (FacebookEventsService)](#د-كود-خدمة-الفلاتر-facebookeventsservice)
   - [هـ. التهيئة عند إقلاع التطبيق (main.dart)](#هـ-التهيئة-عند-إقلاع-التطبيق-maindart)
5. [طرق الاختبار والتحقق المحلي والسحابي](#5-طرق-الاختبار-والتحقق-المحلي-والسحابي)
6. [أشهر المشاكل وحلولها المباشرة](#6-أشهر-المشاكل-وحلولها-المباشرة)

---

## 1. الهدف والفوائد
ربط Facebook SDK يتيح:
1. **تتبع التثبيتات التلقائي (App Installs):** معرفة المستخدمين القادمين من إعلانات فيسبوك وإنستغرام بدقة واحتساب تكلفة التثبيت (CPI).
2. **تتبع الأحداث المخصصة (Custom Events):** مثل التسجيل (Registration)، عرض عقار/منتج (View Content)، الإضافة للمفضلة أو الشراء.
3. **إعادة الاستهداف (Retargeting):** إنشاء جماهير مخصصة (Custom Audiences & Lookalike) بناءً على سلوك المستخدمين داخل التطبيق.

---

## 2. المتطلبات المسبقة والبيانات المطلوبة

### أ. بيانات يجب الحصول عليها من لوحة Meta (يسلمها المسوق أو ينشئها المطور):
| البيان | الوصف | مثال | أين تجده؟ |
|---|---|---|---|
| **Facebook App ID** | المعرف الرقمي للتطبيق | `1003409726093633` | أعلى صفحة التطبيق في developers.facebook.com |
| **Client Token** | رمز العميل المشفر (32 خانة Hex) | `403196df8e10cd71601b022eaff33dd0` | Settings > Advanced > Security > Client Token |
| **App Display Name** | اسم التطبيق المعروض | `Mondera Real Estate App` | Settings > Basic > Display Name |

### ب. بيانات يجب تقديمها للوحة Meta لربط المنصات:
1. **لنظام Android:**
   - **Package Name:** اسم الحزمة (مثل `com.codebyte.mondera`).
   - **Class Name:** الكلاس الرئيسي للإقلاع (غالباً: `com.codebyte.mondera.MainActivity`).
   - **Key Hashes:** بصمة مفتاح التوقيع (Debug & Release) بصيغة Base64 (مثل `pTziRzWWka54QHpWVTXkBoAColo=`).
2. **لنظام iOS:**
   - **Bundle ID:** معرف الحزمة (مثل `com.codebyte.mondera`).
   - **iPhone Store ID:** معرف التطبيق في App Store (الرقم المكون من 10 أرقام، مثل `6792721128`).

---

## 3. خطوات إعداد لوحة Meta for Developers
1. الدخول على [Meta for Developers](https://developers.facebook.com/apps/).
2. إنشاء تطبيق جديد واختيار النوع المناسب (مثل **Business**).
3. إضافة منصة **Android**:
   - إدخال Package Name و Class Name.
   - لصق الـ Key Hashes.
4. إضافة منصة **iOS**:
   - إدخال Bundle Identifier و App Store ID.
5. استخراج الـ **Client Token**:
   - الذهاب إلى: **Settings (الإعدادات) > Advanced (خيارات متقدمة) > قسم Security (الأمان)**.
   - نسخ القيمة الموجودة في حقل **Client Token**.

---

## 4. التنفيذ البرمجي خطوة بخطوة

### أ. حزم فلاتر (`pubspec.yaml`)
أضف الحزمة الرسمية المدعومة:
```yaml
dependencies:
  flutter:
    sdk: flutter
  facebook_app_events: ^0.30.5
```
ثم نفذ:
```bash
flutter pub get
```

---

### ب. إعدادات نظام Android

#### 1. ملف القيم `android/app/src/main/res/values/strings.xml`
(إذا لم يكن الملف موجوداً، قم بإنشائه):
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- استبدل بالأرقام والمفاتيح الخاصة بمشروعك -->
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
</resources>
```

#### 2. ملف المانيفست `android/app/src/main/AndroidManifest.xml`
داخل وسم `<application>` أضف وسوم الميتا داتا التالية:
```xml
<manifest ...>
    <!-- تأكد من وجود إذن الإنترنت -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <application ...>
        
        <!-- إعدادات Facebook SDK -->
        <meta-data
            android:name="com.facebook.sdk.ApplicationId"
            android:value="@string/facebook_app_id" />
        <meta-data
            android:name="com.facebook.sdk.ClientToken"
            android:value="@string/facebook_client_token" />

    </application>
</manifest>
```

---

### ج. إعدادات نظام iOS

#### 1. ملف `ios/Runner/Info.plist`
داخل الوسم الرئيسي `<dict>` أضف التالي:
```xml
<dict>
    <!-- مخطط فتح التطبيق لفيسبوك -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>fbYOUR_FACEBOOK_APP_ID</string>
            </array>
        </dict>
    </array>

    <!-- بيانات الربط والتفعيل التلقائي -->
    <key>FacebookAppID</key>
    <string>YOUR_FACEBOOK_APP_ID</string>
    <key>FacebookClientToken</key>
    <string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
    <key>FacebookDisplayName</key>
    <string>YOUR_APP_NAME</string>
    <key>FacebookAutoLogAppEventsEnabled</key>
    <true/>
    <key>FacebookAdvertiserIDCollectionEnabled</key>
    <true/>
</dict>
```

#### 2. تثبيت مكتبات CocoaPods
في الـ Terminal انتقل لمجلد `ios` وشغّل:
```bash
cd ios
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install
cd ..
```
*(ملاحظة: استخدام `LANG=en_US.UTF-8` يتفادى خطأ الترميز الشهير في نظام ماك مع روبي).*

---

### د. كود خدمة الفلاتر (`FacebookEventsService`)
أنشئ ملفاً مستقلاً في مسار الخدمات لديك، مثلاً:
`lib/core/service/generic/facebook_events_service.dart`

```dart
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class FacebookEventsService {
  FacebookEventsService._();

  static final FacebookEventsService instance = FacebookEventsService._();
  static final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  FacebookAppEvents get client => _facebookAppEvents;

  /// تهيئة الخدمة وتمكين التتبع التلقائي وجمع معرفات الإعلانات
  Future<void> initialize() async {
    try {
      await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
      await _facebookAppEvents.setAdvertiserIdCollectionEnabled(true);
      debugPrint('✅ [FacebookSDK] Initialized successfully. AutoLogAppEvents enabled.');
    } catch (e) {
      debugPrint('❌ FacebookEventsService init error: $e');
    }
  }

  /// تسجيل حدث مخصص عام
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

  /// تسجيل حدث استعراض محتوى (عقار / منتج)
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

  /// تسجيل حدث إتمام إنشاء حساب جديد
  Future<void> logCompletedRegistration({String? registrationMethod}) async {
    try {
      await _facebookAppEvents.logCompletedRegistration(
        registrationMethod: registrationMethod,
      );
    } catch (e) {
      debugPrint('❌ FacebookEventsService logCompletedRegistration error: $e');
    }
  }

  /// ربط معرف المستخدم (User ID) لتتبع رحلة العميل
  Future<void> setUserID(String id) async {
    try {
      await _facebookAppEvents.setUserID(id);
    } catch (e) {
      debugPrint('❌ FacebookEventsService setUserID error: $e');
    }
  }

  /// حذف معرف المستخدم عند تسجيل الخروج
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

### هـ. التهيئة عند إقلاع التطبيق (`main.dart`)
في دالة الإقلاع الرئيسية (Main Startup):
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'path/to/facebook_events_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تشغيل تهيئة فيسبوك بشكل غير متزامن دون تعطيل فتح الشاشات
  unawaited(FacebookEventsService.instance.initialize());

  runApp(const MyApp());
}
```

---

## 5. طرق الاختبار والتحقق المحلي والسحابي

### 1. عبر الـ Terminal لمحاكي iOS (iOS Simulator):
```bash
xcrun simctl spawn booted log stream --predicate 'processImagePath CONTAINS "Runner" AND (eventMessage CONTAINS[c] "FBSDK" OR eventMessage CONTAINS[c] "FacebookSDK")' --style compact
```
عند تشغيل التطبيق ستشاهد:
```text
✅ [FacebookSDK] Initialized successfully. AutoLogAppEvents enabled.
```

### 2. عبر الـ Terminal لأجهزة Android (عبر ADB):
```bash
adb logcat -s FacebookSDK:V
```
ستشاهد رسائل:
```text
FacebookSDK.AppEvents: Flushing [1] events to server: OK
```

### 3. أداة الفحص المباشر السحابية (Meta App Ads Helper):
1. افتح: [Facebook App Ads Helper](https://developers.facebook.com/tools/app-ads-helper/).
2. اختر تطبيقك أو ضع الـ App ID.
3. اضغط **Submit** وتأكد من قسم **App Events**؛ سيظهر مؤشر أخضر بأن التطبيق يستقبل البيانات وتاريخ آخر حدث.

### 4. أداة اختبار الأحداث اللحظية (Meta Events Manager):
1. افتح: [Events Manager](https://business.facebook.com/events_manager2/).
2. اختر التطبيق من قائمة مصادر البيانات (Data Sources).
3. افتح تبويب **Test Events**، وشغّل التطبيق؛ ستجد ظهور حدث `fb_mobile_activate_app` لحظياً أمامك على الشاشة.

---

## 6. أشهر المشاكل وحلولها المباشرة

| المشكلة | السبب | الحل |
|---|---|---|
| **خطأ ترميز عند `pod install`** | روبي على ماك يتطلب ترميز UTF-8 | نفّذ: `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install` |
| **تحذير `setAdvertiserTracking is deprecated`** | فيسبوك حدّث طريقة التتبع في الإصدارات الحديثة | استخدم `setAdvertiserIdCollectionEnabled(true)` بدلاً منها |
| **الأحداث لا تظهر في Meta** | الـ Client Token غير موجود أو خاطئ | تأكد من نسخه بدقة من (Settings > Advanced > Security > Client Token) ووضعه في `strings.xml` و `Info.plist` |
| **تطبيق iOS يرفض الرفع للمتجر** | تتبع الإعلانات يحتاج إشعار خصوصية إذا استُخدم الـ IDFA | إذا رغبت في طلب إذن التتبع على iOS 14.5+، استخدم حزمة `app_tracking_transparency` وأضف `NSUserTrackingUsageDescription` في `Info.plist` |
