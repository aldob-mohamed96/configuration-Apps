# 🔐 دليل وقاعدة إعداد تسجيل الدخول بواسطة جوجل وأبل في Flutter
### (Google Sign-In & Sign in with Apple Master Guide for iOS & Android)

دليل هندسي متكامل ومفصل خطوة بخطوة لإعداد وربط خدمة تسجيل الدخول الاجتماعي عبر **حسابات جوجل (Google Sign-In)** و **حسابات أبل (Sign in with Apple)** لتطبيقات **Flutter** على منصتي **Android** و **iOS**، مع الربط التلقائي بـ **Firebase Authentication** أو الـ **Backend الخاص بك**.

---

## 📌 المحتويات
1. [نظرة عامة وهندسة المصادقة (Authentication Architecture)](#1-نظرة-عامة-وهندسة-المصادقة)
2. [حزم Flutter المطلوبة (Dependencies)](#2-حزم-flutter-المطلوبة)
3. [القسم الأول: إعداد تسجيل الدخول بواسطة جوجل (Google Sign-In)](#3-القسم-الأول-إعداد-تسجيل-الدخول-بواسطة-جوجل)
   - [أ) إعدادات Google Cloud & Firebase Console](#أ-إعدادات-google-cloud--firebase-console)
   - [ب) استخراج بصمات التوقيع SHA-1 و SHA-256](#ب-استخراج-بصمات-التوقيع-sha-1-و-sha-256)
   - [ج) تهيئة نظام Android](#ج-تهيئة-نظام-android)
   - [د) تهيئة نظام iOS (Info.plist & Schemes)](#د-تهيئة-نظام-ios)
4. [القسم الثاني: إعداد تسجيل الدخول بواسطة أبل (Sign in with Apple)](#4-القسم-الثاني-إعداد-تسجيل-الدخول-بواسطة-أبل)
   - [أ) إعداد حساب مطوري أبل (Apple Developer Portal)](#أ-إعداد-حساب-مطوري-أبل)
   - [ب) تهيئة نظام iOS في Xcode (Capabilities & Entitlements)](#ب-تهيئة-نظام-ios-في-xcode)
   - [ج) تهيئة نظام أندرويد لـ Apple Sign-In (Service ID & Intent Filter)](#ج-تهيئة-نظام-أندرويد-لـ-apple-sign-in)
   - [د) خوارزمية الأمان والتشفير (Cryptographic Nonce & SHA-256)](#د-خوارزمية-الأمان-والتشفير-nonce)
5. [كود خدمة المصادقة الموحدة (SocialAuthService)](#5-كود-خدمة-المصادقة-الموحدة)
6. [الربط مع السيرفر أو Firebase (Backend Integration)](#6-الربط-مع-السيرفر-أو-firebase)
7. [أشهر الأخطاء وحلولها المضمونة (Troubleshooting & FAQs)](#7-أشهر-الأخطاء-وحلولها-المضمونة)

---

## 1. نظرة عامة وهندسة المصادقة

تعتمد آلية تسجيل الدخول الاجتماعي الحديثة على تدفق آمن خالٍ من تمرير كلمات المرور:
1. **Google Sign-In (v7 API):** يطلب التطبيق تفويض المستخدم، فتح نافذة جوجل الرسمية لاختيار الحساب، واستلام `idToken` و `accessToken` للتحقق منه في السيرفر أو Firebase.
2. **Apple Sign-In:** متطلب إلزامي في متجر App Store إذا كان تطبيقك يدعم أي تسجيل دخول خارجي (مثل جوجل أو فيسبوك). يمرر التطبيق رمز `nonce` مشفراً لحماية الطلب من هجمات Replay Attacks، وتستلم منه `identityToken` واسم المستخدم والبريد المشفر (Privatized Relay).
3. **الدعم المتبادل:** تعمل خدمة جوجل على أندرويد و iOS، كما تعمل خدمة أبل على أجهزة iOS بصورة مدمجة (Native Sheet) وعلى أندرويد عبر نافذة ويب مؤمنة (Web Authentication Session).

---

## 2. حزم Flutter المطلوبة

أضف الحزم التالية إلى ملف `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Social Authentication
  google_sign_in: ^7.2.0       # أحدث إصدار متوافق مع بنية v7 الحديثة
  sign_in_with_apple: ^8.1.0   # دعم أصلي لـ iOS ونافذة ويب لـ Android
  firebase_auth: ^6.5.4        # اختياري: إذا كنت تستخدم Firebase كمظلة مصادقة
  crypto: ^3.0.7               # لتوليد وتشفير الـ SHA-256 Nonce المطلوب لـ Apple
```

ثم نفّذ:
```bash
flutter pub get
```

---

## 3. القسم الأول: إعداد تسجيل الدخول بواسطة جوجل

### أ) إعدادات Google Cloud & Firebase Console
1. افتح **[Firebase Console](https://console.firebase.google.com)** وأنشئ مشروعاً (أو استخدم مشروعاً قائماً).
2. في قسم **Authentication > Sign-in method**:
   - فعّل خيار **Google**.
   - اختر اسم المشروع وبريد الدعم، ثم اضغط **Save**.
3. في صفحة **Project Settings**:
   - ستجد **Web API Key** وقائمة بالـ Client IDs المولدة.
   - نحتاج ثلاثة أنواع من الـ **OAuth Client IDs**:
     - **Web Client ID:** (مهم جداً للتحقق من التوكن في السيرفر و Firebase).
     - **iOS Client ID:** مخصص لتطبيق الـ iOS.
     - **Android Client ID:** مخصص لتطبيق الأندرويد ومربوط ببصمة الـ SHA-1.

---

### ب) استخراج بصمات التوقيع SHA-1 و SHA-256
لن يعمل تسجيل الدخول بجوجل على أندرويد إلا بعد إضافة بصمة الـ SHA-1 و SHA-256 إلى Firebase:

#### 1) بصمة بيئة التطوير (Debug Keystore):
نفّذ الأمر التالي في مجلد المشروع:
```bash
# macOS / Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

#### 2) بصمة نسخة الإنتاج (Release Keystore):
```bash
keytool -list -v -keystore android/app/keystore.jks -alias upload -storepass YOUR_STORE_PASS -keypass YOUR_KEY_PASS
```

#### 3) بصمة متجر جوجل بلاي (Play App Signing):
إذا كان التطبيق مرفوعاً على Google Play، اذهب إلى:
> **Google Play Console > Release > Setup > App Integrity > App Signing key certificate**
> وانسخ **SHA-1** و **SHA-256** وأضفها إلى Firebase Console أيضاً!

---

### ج) تهيئة نظام Android

1. نزّل ملف `google-services.json` من Firebase وضعه داخل: `android/app/google-services.json`.
2. في ملف `android/settings.gradle.kts` (أو `android/build.gradle`):
   ```kotlin
   plugins {
       id("com.google.gms.google-services") version "4.4.2" apply false
   }
   ```
3. في ملف `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
       id("com.android.application")
       id("kotlin-android")
       id("com.google.gms.google-services")
   }
   ```

---

### د) تهيئة نظام iOS

1. نزّل ملف `GoogleService-Info.plist` من Firebase وضعه في المسار: `ios/Runner/GoogleService-Info.plist` (واحرص على إضافته عبر Xcode ليكون داخل الـ Target).
2. افتح ملف `GoogleService-Info.plist` وانسخ قيمة المفتاحين:
   - `CLIENT_ID`: مثلاً `YOUR_IOS_CLIENT_ID.apps.googleusercontent.com`
   - `REVERSED_CLIENT_ID`: مثلاً `com.googleusercontent.apps.YOUR_IOS_CLIENT_ID`
3. افتح ملف `ios/Runner/Info.plist` وأضف الإعدادات التالية:

```xml
<dict>
    <!-- 1. معرف عميل جوجل لنظام iOS -->
    <key>GIDClientID</key>
    <string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>

    <!-- 2. مخطط عناوين الـ URL للرجوع للتطبيق بعد المصادقة -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
            </array>
        </dict>
    </array>
</dict>
```

---

## 4. القسم الثاني: إعداد تسجيل الدخول بواسطة أبل

> [!IMPORTANT]
> **قاعدة أبل الإلزامية (Guideline 4.8):** إذا كان تطبيقك يحتوي على خيار تسجيل دخول بواسطة جوجل أو فيسبوك، فإن توفير "Sign in with Apple" كخيار مكافئ إلزامي لقبول التطبيق في متجر App Store.

### أ) إعداد حساب مطوري أبل (Apple Developer Portal)
1. افتح **[Apple Developer Portal](https://developer.apple.com/account/)**.
2. **تفعيل الميزة في الـ App ID:**
   - توجه إلى: **Certificates, Identifiers & Profiles > Identifiers**.
   - اختر **App IDs** ثم اضغط على معرّف تطبيقك (مثل: `com.example.app`).
   - تحت تبويب **Capabilities**، ضع علامة صح بجانب: **Sign In with Apple**.
   - اضغط **Save**.

3. **إعداد Service ID (لتشغيل أبل على أندرويد والويب):**
   - اضغط **+** لإضافة Identifier جديد > اختر **Services IDs**.
   - **Description:** `App Web Auth`
   - **Identifier:** `com.example.app.web` (يُفضل إضافة `.web` في النهاية).
   - فعّل **Sign In with Apple** بجانبه واضغط **Configure**:
     - اختر **Primary App ID** لتطبيقك الأساسي.
     - **Domains and Subdomains:** نطاق موقعك (مثل: `yourdomain.com`).
     - **Return URLs:** رابط الـ Callback لمعالجة الرد (مثل: `https://yourdomain.com/callbacks/sign_in_with_apple`).
   - اضغط **Save** ثم **Continue** ثم **Register**.

4. **إنشاء مفتاح خاص (.p8 Key) لـ Firebase أو الـ Backend:**
   - توجه إلى: **Keys** واضغط **+**.
   - سمّ المفتاح **Sign in with Apple Key**.
   - فعّل **Sign in with Apple** واربطه بـ Primary App ID.
   - نزّل ملف المفتاح (`AuthKey_XXXXXX.p8`) واحتفظ به، وسجّل الـ **Key ID** و **Team ID**.

---

### ب) تهيئة نظام iOS في Xcode
1. افتح مجلد `ios` في برنامج Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. اختر **Runner** من القائمة اليسرى > ثم توجه لتبويب **Signing & Capabilities**.
3. اضغط على **`+ Capability`** في الأعلى واختر: **Sign In with Apple**.
4. سيقوم Xcode تلقائياً بإنشاء ملف `Runner/Runner.entitlements` وإضافة الصلاحية:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>com.apple.developer.applesignin</key>
       <array>
           <string>Default</string>
       </array>
   </dict>
   </plist>
   ```

---

### ج) تهيئة نظام أندرويد لـ Apple Sign-In
لكي تستقبل نتيجة تسجيل الدخول من نافذة المتصفح في أجهزة أندرويد، أضف `intent-filter` التالي داخل `<activity>` الرئيسية في ملف `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    ...>
    
    <!-- Intent Filter لـ Sign in with Apple على Android -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="signinwithapple" android:host="callback"/>
    </intent-filter>

</activity>
```

---

### د) خوارزمية الأمان والتشفير (Nonce & SHA-256)
تطلب منصة أبل تشفير رمز عشوائي سري (Cryptographic Nonce) لمنع هجمات الاحتيال:
1. يولد التطبيق نصاً عشوائياً قوياً (`rawNonce`).
2. يتم تشفيره عبر خوارزمية `SHA-256` وإرساله لأبل في المعامل `nonce`.
3. تستلم أبل الرمز وتختمه داخل الـ `identityToken`.
4. عند التحقق عبر Firebase Auth أو السيرفر، يتم تقديم الـ `rawNonce` الأصلي للتأكد من تطابق البصمة المشفرة.

---

## 5. كود خدمة المصادقة الموحدة (SocialAuthService)

الملف الكامل الجاهز للإنتاج موجود في:
[`apple and google authentication login/social_auth_service.dart`](file:///Users/mohamedgaber/projects/configuration%20Apps/apple%20and%20google%20authentication%20login/social_auth_service.dart)

### كيفية الاستخدام في تطبيقك:
```dart
final authService = SocialAuthService(
  googleWebClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
  googleIosClientId: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
  googleAndroidClientId: 'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com',
  appleServiceId: 'com.example.app.web',
  appleRedirectUri: 'https://yourdomain.com/callbacks/sign_in_with_apple',
  linkWithFirebase: true, // يربط الحساب بـ FirebaseAuth تلقائياً
);

// تسجيل الدخول بجوجل
final result = await authService.signInWithGoogle();
switch (result) {
  case SocialAuthSuccess(:final user):
    print('نجح الدخول: ${user.displayName} - ${user.email}');
    print('ID Token: ${user.idToken}');
  case SocialAuthCanceled():
    print('قام المستخدم بإلغاء العملية');
  case SocialAuthFailure(:final message):
    print('فشل الدخول: $message');
}

// تسجيل الدخول بأبل
final appleResult = await authService.signInWithApple();
switch (appleResult) {
  case SocialAuthSuccess(:final user):
    print('نجح دخول أبل: ${user.displayName} - ${user.email}');
  case SocialAuthCanceled():
    print('أُلغيت نافذة أبل');
  case SocialAuthFailure(:final message):
    print('خطأ أبل: $message');
}
```

---

## 6. الربط مع السيرفر أو Firebase

### أ) في حال استخدام Firebase Authentication:
تقوم الدالة `SocialAuthService` تلقائياً بربط الحساب واستدعاء:
```dart
// Google
FirebaseAuth.instance.signInWithCredential(
  GoogleAuthProvider.credential(idToken: idToken, accessToken: accessToken),
);

// Apple
FirebaseAuth.instance.signInWithCredential(
  OAuthProvider('apple.com').credential(idToken: identityToken, rawNonce: rawNonce),
);
```

### ب) في حال استخدام Custom Backend (Laravel / Node.js / Django):
أرسل الـ `idToken` إلى الـ API في سيرفرك:
```dart
final response = await dio.post('/api/v1/auth/social-login', data: {
  'provider': user.provider,
  'id_token': user.idToken,
  'email': user.email,
  'name': user.displayName,
});
```
يقوم السيرفر بالتحقق من صحة التوكن باستخدام مكتبة التحقق الرسمية من جوجل (`google-auth-library`) وأبل (`apple-signin-auth`) وإصدار JWT Token خاص بتطبيقك.

---

## 7. أشهر الأخطاء وحلولها المضمونة (Troubleshooting)

### ❌ 1. `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10, null, null)`
- **السبب:** عدم تطابق بصمة SHA-1 أو اسم الحزمة Package Name في Firebase Console.
- **الحل:** استخرج بصمة SHA-1 لـ Debug و Release، وضعها في Firebase، ونزّل ملف `google-services.json` الجديد واستبدله.

### ❌ 2. `ApiException: 12500`
- **السبب:** بريد الدعم (Support Email) غير محدد داخل Firebase Authentication أو Google Cloud Console.
- **الحل:** اذهب لـ Firebase > Project Settings > General وحدد Support Email.

### ❌ 3. عدم ظهور اسم المستخدم أو بريده في أبل إلا في المرة الأولى (Null Email / Name)
- **السبب:** سياسة خصوصية صارمة لدى شركة أبل؛ تُرسل أبل الاسم والإيميل **فقط في أول عملية تسجيل دخول على الإطلاق**. في المرات التالية تُرسل `identityToken` فقط.
- **الحل:**
  1. احفظ الاسم والإيميل في قاعدة بيانات السيرفر أو `flutter_secure_storage` فور استلامهما في أول تسجيل.
  2. للاختبار من جديد، اذهب في هاتف الآيفون إلى: **Settings > Apple ID > Sign-In & Security > Sign in with Apple > اختر تطبيقك > اضغط Stop using Apple ID** ليعيد إرسال الاسم والإيميل مجدداً.

### ❌ 4. خطأ شاشة بيضاء أو `AuthorizationErrorCode.unknown` في iOS
- **السبب:** عدم تفعيل خاصية `Sign In with Apple` في تبويب Signing & Capabilities في Xcode، أو عدم تفعيلها في App ID على موقع مطوري أبل.
- **الحل:** تأكد من وجود ملف `Runner.entitlements` ومطابقة Bundle Identifier تماماً.
