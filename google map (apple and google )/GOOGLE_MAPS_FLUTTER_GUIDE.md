# 🗺️ دليل وقاعدة إعداد خرائط جوجل في Flutter (iOS & Android)
### (Google Maps Flutter Master Guide for Apple & Google Platforms)

دليل هندسي متكامل ومفصل خطوة بخطوة لربط وتشغيل **خرائط جوجل (Google Maps SDK)** في تطبيقات **Flutter** على منصتي **Android** و **iOS**، مع ضبط الصلاحيات، استخراج وتأمين المفاتيح، دعم الثيم الداكن (Dark Mode)، والتحكم بالكاميرا والعلامات (Markers).

---

## 📌 المحتويات
1. [المتطلبات الأساسية والحزم](#1-المتطلبات-الأساسية-والحزم)
2. [الخطوة 1: إعداد Google Cloud Console والمفاتيح](#2-الخطوة-1-إعداد-google-cloud-console-والمفاتيح)
   - تفعيل Maps SDK for Android و Maps SDK for iOS
   - تقييد المفاتيح أمنياً (API Key Restrictions)
3. [الخطوة 2: تهيئة نظام Android](#3-الخطوة-2-تهيئة-نظام-android)
   - إضافة مفتاح الـ Geo في `AndroidManifest.xml`
   - صلاحيات الموقع الجغرافي (Location Permissions)
4. [الخطوة 3: تهيئة نظام iOS (Apple)](#4-الخطوة-3-تهيئة-نظام-ios)
   - إعداد `Info.plist` ومفتاح `GMSApiKey`
   - ضبط `AppDelegate.swift` واستدعاء `GMSServices.provideAPIKey`
   - نصوص أذونات الموقع الجغرافي لمتجر App Store
5. [الخطوة 4: كود واستخدام الخريطة في Flutter](#5-الخطوة-4-كود-واستخدام-الخريطة-في-flutter)
   - طلب إذن الموقع وجلب الإحداثيات عبر `geolocator`
   - العلامات المخصصة (Custom Markers)
   - تحريك الكاميرا بسلاسة (Camera Animation)
   - التبديل بين وضع الأقمار الصناعية والثيم الداكن (Dark Mode)
   - حل مشكلة التمرير داخل الـ ScrollView (Gesture Recognizers)
6. [أشهر الأخطاء وحلولها المضمونة (Troubleshooting)](#6-أشهر-الأخطاء-وحلولها-المضمونة)

---

## 1. المتطلبات الأساسية والحزم

أضف الحزم التالية إلى ملف `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Google Maps & Geolocation
  google_maps_flutter: ^2.18.0    # الحزمة الرسمية لخرائط جوجل
  geolocator: ^14.0.2             # جلب موقع المستخدم وإدارة الصلاحيات
  geocoding: ^4.0.0              # تحويل الإحداثيات إلى عناوين والعكس
  permission_handler: ^12.0.3     # فحص وطلب الأذونات
```

ثم نفّذ:
```bash
flutter pub get
```

---

## 2. الخطوة 1: إعداد Google Cloud Console والمفاتيح

1. ادخل على **[Google Cloud Console](https://console.cloud.google.com)** وتأكد من اختيار مشروعك.
2. توجه إلى **APIs & Services > Library** وقم بتفعيل الـ APIs التالية بالضغط على **Enable**:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Geocoding API** *(اختياري لتحويل الأسماء لإحداثيات)*
   - **Places API (New)** *(اختياري للبحث التلقائي عن الأماكن)*
3. **إنشاء وتأمين مفتاح الـ API:**
   - انتقل إلى **APIs & Services > Credentials** > اضغط **+ Create Credentials > API Key**.
   - انسخ المفتاح، ثم اضغط على اسمه لضبط **قيود الأمان (Restrictions)**:
     - **تقييد أندرويد (Android apps):** أضف اسم الحزمة (`com.example.your_app`) وبصمة **SHA-1** الخاصة بـ Debug و Release.
     - **تقييد أبل (iOS apps):** أضف الـ Bundle Identifier (`com.example.your_app`).
     - **تقييد واجهات الـ API (API restrictions):** حدد فقط Maps SDK for Android و Maps SDK for iOS لمنع استغلال المفتاح في خدمات أخرى.

---

## 3. الخطوة 2: تهيئة نظام Android

### أ) إضافة المفتاح في `AndroidManifest.xml`
افتح الملف: `android/app/src/main/AndroidManifest.xml` وأضف وسم `<meta-data>` داخل `<application>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- 1. أذونات الموقع الجغرافي والإنترنت -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <application
        android:label="Your App Name"
        android:icon="@mipmap/ic_launcher">

        <!-- 2. مفتاح خرائط جوجل الرسمي لأندرويد (ضع مفتاحك الحقيقي هنا) -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY" />

    </application>
</manifest>
```

> [!TIP]
> إذا كنت تستخدم `android/key.properties` أو GitHub Secrets، يمكنك تمرير المفتاح عبر `manifestPlaceholders` داخل `build.gradle.kts`.

---

## 4. الخطوة 3: تهيئة نظام iOS (Apple)

تتطلب خرائط جوجل في iOS تزويد الـ SDK بالمفتاح عند بدء تشغيل التطبيق في `AppDelegate` وتحديد مفتاح الـ API في `Info.plist`.

### أ) إعداد `ios/Runner/Info.plist`
أضف المفتاح ونصوص طلب أذونات الموقع الجغرافي:

```xml
<dict>
    <!-- مفتاح خرائط جوجل لنظام iOS (ضع مفتاحك الحقيقي هنا) -->
    <key>GMSApiKey</key>
    <string>YOUR_GOOGLE_MAPS_API_KEY</string>

    <!-- نصوص أذونات الموقع (ضرورية لقبول التطبيق في App Store) -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>يحتاج التطبيق للوصول لموقعك لعرض الأماكن والخدمات القريبة منك على الخريطة.</string>

    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>يحتاج التطبيق للوصول لموقعك لتسهيل الملاحة والوصول للخدمات القريبة منك.</string>

    <key>NSLocationAlwaysUsageDescription</key>
    <string>يستخدم التطبيق موقعك الجغرافي لعرض النتائج القريبة منك أثناء استخدامك للتطبيق.</string>

    <!-- دعم فتح تطبيق خرائط جوجل الخارجي إذا رغبت -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>comgooglemaps</string>
    </array>
</dict>
```

### ب) ضبط `ios/Runner/AppDelegate.swift`
افتح `ios/Runner/AppDelegate.swift` وقم بقراءة المفتاح من `Info.plist` مباشرة وتمريره لـ `GMSServices`:

```swift
import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // قراءة مفتاح GMSApiKey تلقائياً من Info.plist
    if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !key.isEmpty {
      GMSServices.provideAPIKey(key)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 5. الخطوة 4: كود واستخدام الخريطة في Flutter

الملف الكامل الجاهز للإنتاج موجود في:
[`google map (apple and google )/google_map_view_template.dart`](file:///Users/mohamedgaber/projects/configuration%20Apps/google%20map%20%28apple%20and%20google%20%29/google_map_view_template.dart)

### أ) طلب إذن الموقع والتحريك لكاميرا المستخدم:
```dart
Future<void> goToUserLocation(GoogleMapController controller) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
    final position = await Geolocator.getCurrentPosition();
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.5,
        ),
      ),
    );
  }
}
```

### ب) حل مشكلة التمرير عندما تكون الخريطة داخل صفحة تمرير (Nested ScrollView):
عندما تكون الخريطة داخل `ListView` أو `SingleChildScrollView`، قد يتعارض تمرير الصفحة مع تحريك الخريطة. لحل ذلك استخدم `gestureRecognizers`:

```dart
GoogleMap(
  initialCameraPosition: CameraPosition(target: LatLng(30.0444, 31.2357), zoom: 14),
  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
    Factory<OneSequenceGestureRecognizer>(
      () => EagerGestureRecognizer(),
    ),
  },
  onMapCreated: (controller) { ... },
)
```

---

## 6. أشهر الأخطاء وحلولها المضمونة (Troubleshooting)

### ❌ 1. ظهور الخريطة كشاشة رمادية فارغة مع ظهور شعار Google فقط في الزاوية
- **السبب الأبرز:** مفتاح الـ API غير مفعل عليه **Maps SDK for Android** أو **Maps SDK for iOS** في Google Cloud Console، أو قيود الـ SHA-1 لا تطابق جهازك.
- **الحل:**
  1. ادخل على Google Cloud Console وتأكد من عمل **Enable** لكل من SDK الأندرويد و SDK أبل.
  2. تأكد من تفعيل الفوترة (Billing Account) على مشروع Google Cloud (تمنح جوجل 200 دولار مجانية شهرياً للخريطة).
  3. قم بإلغاء الـ Restrictions مؤقتاً للتأكد من عمل المفتاح، ثم أعد إضافة بصمة الـ SHA-1 الخاصة بك.

### ❌ 2. التطبيق ينهار فجراً على نظام iOS عند فتح شاشة الخريطة
- **السبب:** لم يتم استدعاء `GMSServices.provideAPIKey(key)` في `AppDelegate.swift` قبل فتح الخريطة، أو أن المفتاح فارغ.
- **الحل:** تأكد من كود `AppDelegate.swift` ووجود قيمة داخل `<key>GMSApiKey</key>` في `Info.plist`.

### ❌ 3. خطأ في تجميع الكود في نظام أبل (`pod install` أو خوادم M1/M2/M3)
- **الحل:** نفّذ الأوامر التالية لتنظيف ملفات الـ Pods:
```bash
cd ios
rm -rf Podfile.lock Pods
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

### ❌ 4. رفض التطبيق في متجر أبل بسبب أذونات الموقع
- **السبب:** كتابة نصوص عامة أو مبهمة في `NSLocationWhenInUseUsageDescription` (مثل "We need your location").
- **الحل:** اكتب سبباً واضحاً وصادقاً باللغتين العربية والإنجليزية يوضح الفائدة الحقيقية للمستخدم (مثال: "يستخدم التطبيق موقعك لتحديد أقرب الفروع والعقارات المتاحة حولك على الخريطة").
