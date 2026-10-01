# دليل إعداد CI/CD لنشر تطبيقات Flutter على App Store و TestFlight تلقائياً

هذا الدليل يشرح بالتفصيل وخطوة بخطوة كيفية إعداد **GitHub Actions Workflow** متكامل لبناء ورفع تطبيق فلاتر (iOS) إلى **App Store Connect / TestFlight** بشكل آلي تماماً، مع ميزة **زيادة رقم الإصدار (Build Number) تلقائياً** في كل عملية رفع دون أي تعارض.

---

## 📌 المحتويات
1. [المتطلبات الأساسية](#1-المتطلبات-الأساسية)
2. [الخطوة 1: استخراج مفتاح App Store Connect API](#2-الخطوة-1-استخراج-مفتاح-app-store-connect-api)
3. [الخطوة 2: إنشاء شهادة التوزيع Apple Distribution (.p12)](#3-الخطوة-2-إنشاء-شهادة-التوزيع-apple-distribution-p12)
4. [الخطوة 3: إنشاء ملف الـ Provisioning Profile (.mobileprovision)](#4-الخطوة-3-إنشاء-ملف-الـ-provisioning-profile-mobileprovision)
5. [الخطوة 4: تحويل الملفات إلى Base64](#5-الخطوة-4-تحويل-الملفات-إلى-base64)
6. [الخطوة 5: إضافة الـ Secrets في GitHub](#6-الخطوة-5-إضافة-الـ-secrets-في-github)
7. [الخطوة 6: إعدادات ملفات المشروع (ExportOptions & Info.plist)](#7-الخطوة-6-إعدادات-ملفات-المشروع-exportoptions--infoplist)
8. [الخطوة 7: ملف الـ Workflow الكامل (.github/workflows/deploy_ios.yml)](#8-الخطوة-7-ملف-الـ-workflow-الكامل)
9. [الخطوة 8: كيفية التشغيل والمتابعة](#9-الخطوة-8-كيفية-التشغيل-والمتابعة)

---

## 1. المتطلبات الأساسية
- حساب **Apple Developer Program** مفعل.
- وجود **App ID** مسجل للتطبيق (Bundle Identifier) مثل: `com.example.myapp`.
- مستودع المشروع مرفوع على **GitHub**.

---

## 2. الخطوة 1: استخراج مفتاح App Store Connect API
هذا المفتاح يسمح لأداة Apple الرسمية في سيرفر GitHub Actions برفع التطبيق بدون الحاجة لاسم مستخدم أو كلمة سر أو التحقق بخطوتين (2FA).

1. ادخل على: **[App Store Connect > Users and Access > Integrations](https://appstoreconnect.apple.com/access/integrations/api)**.
2. (إذا كانت أول مرة) اضغط **Request Access** ووافق على الشروط.
3. اضغط على علامة **`+`** بجانب **Active**:
   - **Name:** `GitHub Actions`
   - **Access:** اختر `App Manager` أو `Admin`.
4. اضغط **Generate**.
5. ستحصل على الآتي (احفظهم في مكان آمن):
   - **Key ID:** (كود مكوّن من 10 خانات مثل: `U5943UX5VN`).
   - **Issuer ID:** (كود UUID الموجود بأعلى الصفحة مثل: `7b528716-19b5-407f-98dc-9ae2e3fab928`).
   - اضغط **Download API Key** لتحميل ملف المفتاح: `AuthKey_XXXXXXXXXX.p8` *(تنبيه: زر التحميل يظهر مرة واحدة فقط)*.

---

## 3. الخطوة 2: إنشاء شهادة التوزيع Apple Distribution (.p12)
لإنشاء شهادة ومفتاح خاص مشفر بدون أي تعقيد عبر جهاز الماك:

### أ) توليد ملف طلب الشهادة (CSR) والمفتاح الخاص
افتح الـ Terminal في جهازك ونفذ الأمر التالي:
```bash
openssl req -nodes -newkey rsa:2048 \
  -keyout distribution_private_key.key \
  -out CertificateSigningRequest.certSigningRequest \
  -subj "/emailAddress=your_email@example.com/CN=Apple Distribution/C=US"
```

### ب) رفع الـ CSR وتحميل الشهادة من Apple
1. ادخل على: **[Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)**.
2. اضغط **`+`** واختر **Apple Distribution** ثم اضغط **Continue**.
3. ارفع ملف `CertificateSigningRequest.certSigningRequest` الذي تم توليده.
4. اضغط **Generate** ثم اضغط **Download** لتحميل الشهادة (اسمها: `distribution.cer`).

### ج) دمج الشهادة مع المفتاح الخاص وتوليد ملف `.p12`
ضع ملف `distribution.cer` في نفس مسار المفتاح `distribution_private_key.key`، ثم نفذ:
```bash
# 1. تحويل الشهادة من DER إلى PEM
openssl x509 -in distribution.cer -inform DER -out distribution.pem -outform PEM

# 2. إنشاء ملف الـ p12 المحمي بكلمة سر باستخدام openssl المدمج في نظام الماك لضمان توافقه التام
/usr/bin/openssl pkcs12 -export \
  -inkey distribution_private_key.key \
  -in distribution.pem \
  -out distribution.p12 \
  -passout pass:YOUR_PASSWORD
```
> احفظ كلمة السر التي اخترتها للشهادة لأننا سنستخدمها في GitHub Secrets باسم `P12_PASSWORD`.

---

## 4. الخطوة 3: إنشاء ملف الـ Provisioning Profile (.mobileprovision)
1. ادخل على: **[Apple Developer Profiles](https://developer.apple.com/account/resources/profiles/list)**.
2. اضغط **`+`** لإنشاء بروفايل جديد:
   - نوع البروفايل: اختر **App Store** (تحت Distribution) ثم **Continue**.
   - **App ID:** اختر تطبيقك المحدد (Bundle Identifier).
   - **Certificates:** اختر شهادة الـ Distribution التي أنشأتها للتو.
   - **Profile Name:** اكتب اسماً واضحاً (مثال: `MyApp AppStore`).
3. اضغط **Generate** ثم **Download** لتحميل الملف (امتداده `.mobileprovision`).

---

## 5. الخطوة 4: تحويل الملفات إلى Base64
سيرفر GitHub Actions يحتاج هذه الملفات على شكل نصوص مشفرة Base64 في الـ Secrets. قم بتحويلها من الـ Terminal:

```bash
# 1. تحويل مفتاح الـ API (.p8)
base64 -i AuthKey_XXXXXXXXXX.p8 -o api_key_base64.txt

# 2. تحويل شهادة الـ p12
base64 -i distribution.p12 -o cert_base64.txt

# 3. تحويل البروفايل (.mobileprovision)
base64 -i MyApp_AppStore.mobileprovision -o profile_base64.txt
```

---

## 6. الخطوة 5: إضافة الـ Secrets في GitHub
ادخل على مستودعك في GitHub:
> **Settings** > **Secrets and variables** > **Actions** > اضغط **New repository secret**

أضف الـ 7 مفاتيح التالية:

| اسم المفتاح (Secret Name) | القيمة المطلوبة (Secret Value) |
|---|---|
| `APP_STORE_CONNECT_KEY_ID` | كود الـ Key ID (مثال: `U5943UX5VN`) |
| `APP_STORE_CONNECT_ISSUER_ID` | كود الـ Issuer ID (مثال: `7b528716-19b5-407f...`) |
| `APP_STORE_CONNECT_PRIVATE_KEY_BASE64` | محتوى ملف `api_key_base64.txt` كاملاً |
| `BUILD_CERTIFICATE_BASE64` | محتوى ملف `cert_base64.txt` كاملاً |
| `P12_PASSWORD` | كلمة سر شهادة الـ `.p12` التي حددتها في خطوة توليدها |
| `BUILD_PROVISION_PROFILE_BASE64` | محتوى ملف `profile_base64.txt` كاملاً |
| `KEYCHAIN_PASSWORD` | أي كلمة سر عشوائية لفتح الكي تشين المؤقت (مثال: `MyCiKeychainPass123!`) |

---

## 7. الخطوة 6: إعدادات ملفات المشروع (ExportOptions & Info.plist)

### 1) ملف `ios/ExportOptions.plist`
يحدد هذا الملف لـ Xcode كيفية تصدير الـ IPA والتوقيع عليه بدون واجهة مستخدم:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store</string>
	<key>teamID</key>
	<string>YOUR_TEAM_ID</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>com.yourcompany.app</key>
		<string>MyApp AppStore</string>
	</dict>
	<key>destination</key>
	<string>export</string>
	<key>uploadSymbols</key>
	<true/>
	<key>compileBitcode</key>
	<false/>
	<key>stripSwiftSymbols</key>
	<true/>
</dict>
</plist>
```
*(ملاحظة: استبدل `YOUR_TEAM_ID` و `com.yourcompany.app` و `MyApp AppStore` باسم البروفايل الخاص بك)*.

### 2) ملف `ios/Runner/Info.plist`
تأكد أن مفاتيح الإصدار تستخدم متغيرات فلاتر الديناميكية:
```xml
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
```

### 3) ملف `ios/Flutter/Release.xcconfig`
لمنع Xcode من البحث عن حسابات Apple ID أو بروفايلات Development أثناء البناء على الـ CI، أضف إعدادات التوقيع اليدوي:
```xcconfig
CODE_SIGN_STYLE = Manual
CODE_SIGN_IDENTITY = Apple Distribution
PROVISIONING_PROFILE_SPECIFIER = Mondera AppStore
DEVELOPMENT_TEAM = YOUR_TEAM_ID
```

---

## 8. الخطوة 7: ملف الـ Workflow الكامل (.github/workflows/deploy_ios.yml)
أنشئ الملف في المسار: `.github/workflows/deploy_ios.yml`:

```yaml
name: Deploy iOS to App Store

on:
  push:
    branches:
      - release # يعمل عند عمل Push أو دمج PR على برانش release
  pull_request:
    branches:
      - release # يعمل عند فتح أو تحديث Pull Request موجه لبرانش release
  workflow_dispatch:
    inputs:
      custom_build_number:
        description: 'رقم إصدار محدد يدوياً (اختياري - اتركه فارغاً للزيادة التلقائية)'
        required: false
        default: ''

jobs:
  deploy:
    name: Build & Upload to App Store
    runs-on: macos-26 # يحتوي على Xcode 26 و iOS 26 SDK المعتمدين لدى Apple
    timeout-minutes: 60

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Verify Xcode & iOS SDK
        run: |
          xcodebuild -version
          echo "iOS SDK: $(xcrun --show-sdk-version --sdk iphoneos)"

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Calculate Version & Auto-Increment Build Number
        id: versioning
        run: |
          # استخراج رقم النسخة والـ Build من pubspec.yaml
          RAW_VERSION=$(grep '^version:' pubspec.yaml | sed -E 's/version:[[:space:]]*//')
          VERSION_NAME=$(echo "$RAW_VERSION" | cut -d'+' -f1)
          BASE_BUILD=$(echo "$RAW_VERSION" | cut -d'+' -f2)

          if [ -z "$BASE_BUILD" ] || [ "$BASE_BUILD" = "$VERSION_NAME" ]; then
            BASE_BUILD=108
          fi

          # التحقق إذا كان هناك Build Number مدخل يدوياً
          CUSTOM_BUILD="${{ inputs.custom_build_number }}"
          if [ -n "$CUSTOM_BUILD" ]; then
            BUILD_NUMBER="$CUSTOM_BUILD"
          else
            # زيادة تلقائية تصاعدية تراكمية مع كل عملية تشغيل على جيت هب
            BUILD_NUMBER=$(( BASE_BUILD + GITHUB_RUN_NUMBER ))
          fi

          # حقن رقم الإصدار في pubspec و xcode
          sed -i '' "s/^version:.*/version: $VERSION_NAME+$BUILD_NUMBER/g" pubspec.yaml
          sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $BUILD_NUMBER;/g" ios/Runner.xcodeproj/project.pbxproj
          sed -i '' "s/MARKETING_VERSION = [^;]*;/MARKETING_VERSION = $VERSION_NAME;/g" ios/Runner.xcodeproj/project.pbxproj

          echo "VERSION_NAME=$VERSION_NAME" >> $GITHUB_ENV
          echo "BUILD_NUMBER=$BUILD_NUMBER" >> $GITHUB_ENV
          echo "========================================="
          echo "🚀 Deploying Version: $VERSION_NAME (Build $BUILD_NUMBER)"
          echo "========================================="

      - name: Install Apple Certificate
        env:
          BUILD_CERTIFICATE_BASE64: ${{ secrets.BUILD_CERTIFICATE_BASE64 }}
          P12_PASSWORD: ${{ secrets.P12_PASSWORD }}
          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
          CERT_PATH: ${{ runner.temp }}/certificate.p12
          KEYCHAIN_PATH: ${{ runner.temp }}/app-signing.keychain-db
        run: |
          # فك تشفير الشهادة بالبايثون مع معالجة الـ padding تلقائياً
          python3 -c "import base64, os; s = os.environ['BUILD_CERTIFICATE_BASE64'].strip(); s += '=' * (-len(s) % 4); open(os.environ['CERT_PATH'], 'wb').write(base64.b64decode(s))"
          /usr/bin/openssl pkcs12 -in "$CERT_PATH" -noout -info -passin "pass:$P12_PASSWORD"

          /usr/bin/security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
          /usr/bin/security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
          /usr/bin/security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
          /usr/bin/security list-keychains -d user -s "$KEYCHAIN_PATH" $(/usr/bin/security list-keychains -d user | tr -d '"')

          /usr/bin/security import "$CERT_PATH" -k "$KEYCHAIN_PATH" -P "$P12_PASSWORD" -T /usr/bin/codesign -T /usr/bin/security
          /usr/bin/security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

      - name: Install Provisioning Profile
        env:
          BUILD_PROVISION_PROFILE_BASE64: ${{ secrets.BUILD_PROVISION_PROFILE_BASE64 }}
          PP_PATH: ${{ runner.temp }}/Mondera_AppStore.mobileprovision
        run: |
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          python3 -c "import base64, os; s = os.environ['BUILD_PROVISION_PROFILE_BASE64'].strip(); s += '=' * (-len(s) % 4); open(os.environ['PP_PATH'], 'wb').write(base64.b64decode(s))"
          cp "$PP_PATH" ~/Library/MobileDevice/Provisioning\ Profiles/15eb9bd3-df05-4a64-82bc-41de4c8b9f8a.mobileprovision
          cp "$PP_PATH" ~/Library/MobileDevice/Provisioning\ Profiles/Mondera_AppStore.mobileprovision

      - name: Setup Environment Files
        run: |
          mkdir -p env
          if [ ! -f env/.env ]; then
            echo "API_BASE_DEV_URL=https://mondera-realestate.com/api/v1" > env/.env
            echo "API_BASE_TEST_URL=https://mondera-realestate.com/api/v1" >> env/.env
            echo "API_BASE_PROD_URL=https://mondera-realestate.com/api/v1" >> env/.env
            echo "API_KEY=" >> env/.env
            echo "APP_NAME=Mondera" >> env/.env
            echo "APP_VERSION=1.0.1" >> env/.env
            echo "APP_MODE=production" >> env/.env
            echo "SENTRY_DSN=" >> env/.env
            echo "GOOGLE_MAPS_ANDROID_MAP_ID=" >> env/.env
            echo "GOOGLE_MAPS_IOS_MAP_ID=" >> env/.env
          fi

      - name: Install Dependencies
        run: |
          flutter config --no-enable-swift-package-manager
          mkdir -p build/ios/SourcePackages
          flutter pub get

      - name: Prepare CocoaPods & Firebase SDK
        run: |
          if [ -f ios/install_pods.sh ]; then
            bash ios/install_pods.sh
          else
            cd ios && pod install --repo-update
          fi

      - name: Build iOS IPA
        run: |
          flutter build ipa --release \
            --build-name="$VERSION_NAME" \
            --build-number="$BUILD_NUMBER" \
            --export-options-plist=ios/ExportOptions.plist

      - name: Upload to App Store Connect / TestFlight
        env:
          APP_STORE_CONNECT_KEY_ID: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          APP_STORE_CONNECT_PRIVATE_KEY_BASE64: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY_BASE64 }}
        run: |
          mkdir -p ~/.appstoreconnect/private_keys
          mkdir -p ~/.private_keys
          python3 -c "import base64, os; s = os.environ['APP_STORE_CONNECT_PRIVATE_KEY_BASE64'].strip(); s += '=' * (-len(s) % 4); open(os.path.expanduser('~/.appstoreconnect/private_keys/AuthKey_' + os.environ['APP_STORE_CONNECT_KEY_ID'] + '.p8'), 'wb').write(base64.b64decode(s))"
          cp ~/.appstoreconnect/private_keys/AuthKey_${APP_STORE_CONNECT_KEY_ID}.p8 ~/.private_keys/AuthKey_${APP_STORE_CONNECT_KEY_ID}.p8

          IPA_PATH=$(find build/ios/ipa -name "*.ipa" | head -n 1)

          if [ -z "$IPA_PATH" ]; then
            echo "❌ Error: IPA file not found in build/ios/ipa"
            exit 1
          fi

          echo "🚀 Uploading $IPA_PATH to App Store Connect..."
          xcrun altool --upload-app \
            --type ios \
            --file "$IPA_PATH" \
            --apiKey "$APP_STORE_CONNECT_KEY_ID" \
            --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID"
          
          echo "✅ Upload completed successfully to App Store Connect!"
```

---

## 9. الخطوة 8: استراتيجية فرع `release` والتشغيل

### أ) آلية عمل برانش `release`:
الورك فلو مبرمج ليعمل **فقط** عند عمل Push أو دمج (Merge / Pull Request) على فرع `release`:
1. يمكنك العمل بحرية والتطوير على فرع `version2` أو `main` بدون استهلاك دقائق GitHub Actions وبدون تشغيل الرفع في كل تعديل كود.
2. عندما يصبح التطبيق جاهزاً لنشر إصدار رسمي جديد على TestFlight، تقوم بدمج التعديلات في فرع `release`:
   ```bash
   git checkout release
   git merge version2
   git push origin release
   ```
3. بمجرد دفع التعديلات إلى `release`، سيبدأ الـ Workflow تلقائياً في زيادة الـ Build Number وبناء الـ IPA والرفع المباشر لـ Apple.

### ب) التشغيل اليدوي (Workflow Dispatch):
- يمكنك أيضاً تشغيل الـ Workflow في أي وقت يدوياً من صفحة **Actions** على GitHub:
  - اضغط على **Deploy iOS to App Store** > اضغط **Run workflow**.
  - اختر الفرع وحدد رقم الـ Build لو رغبت بتحديده يدوياً.

### ج) الاستلام على TestFlight:
- تستغرق Apple من 5 إلى 15 دقيقة لمعالجة النسخة المرفوعة (Processing).
- بعد انتهاء المعالجة، تظهر النسخة فوراً في TestFlight وتصلك رسالة تأكيد على البريد الإلكتروني.

---

## 10. جدول المشاكل والأخطاء الشائعة وحلولها (Troubleshooting Guide)

تم تسجيل كافة الأخطاء الفعلية التي تمت مواجهتها أثناء إعداد الـ CI/CD وحلولها المعتمدة لضمان سهولة تكرارها:

| # | الخطأ (Error Message) | السبب الدقيق (Root Cause) | الحل المعتمد (Solution) |
|---|---|---|---|
| **1** | `SecKeychainItemImport: Unknown format in import` | تم إنشاء ملف الـ `.p12` باستخدام OpenSSL 3 الحديث المشفر بـ AES-256، بينما أداة `security` في macOS تتطلب تشفير 3DES الكلاسيكي أو أن الملف المؤقت يفتقد امتداد `.p12`. | استخدام `/usr/bin/openssl` المدمج بنظام ماك لإنشاء الـ `.p12`، وفك التشفير إلى مسار ينتهي بـ `.p12`. |
| **2** | `binascii.Error: Incorrect padding` | نصوص Base64 في GitHub Secrets قد تُقتطع مسافاتها أو تفقد علامات `=` في نهايتها أثناء النقل عبر المتغيرات البيئية. | إضافة سطر تصحيح الـ padding التلقائي في بايثون: `s += '=' * (-len(s) % 4)`. |
| **3** | `KeyError: 'CERT_PATH'` | عدم تعريف المتغيرات البيئية تحت مفتاح `env:` داخل خطوة التشغيل في الـ Workflow. | كتابة مسار الملف في الـ `env:` الخاص بالـ step قبل استدعائه في كود البايثون. |
| **4** | `No Accounts / No profiles found matching com.codebyte.mondera` | محاولة Xcode البحث عن حساب مطور Apple أونلاين لأن إعدادات التوقيع كانت Automatic. | ضبط `CODE_SIGN_STYLE = Manual` و `PROVISIONING_PROFILE_SPECIFIER` في `Release.xcconfig` و `project.pbxproj`. |
| **5** | `The following plugins do not support Swift Package Manager for ios: google_maps_flutter_ios` | تفعيل فلاتر لـ SPM افتراضياً مع وجود إضافات قديمة تعتمد على CocoaPods فقط. | تنفيذ `flutter config --no-enable-swift-package-manager` وإنشاء مجلد `build/ios/SourcePackages`. |
| **6** | `lib/core/service/env/env.dart: No such file or directory` | كتابة `env/` في `.gitignore` بدون شرطة مائلة في البداية فتسببت في تجاهل كود الدارت داخل `lib/core/service/env/`. | تعديل السطر في `.gitignore` إلى `/env/` وتتبع ملفات `env.dart` و `env.g.dart` في Git. |
| **7** | `could not find expected ':' while scanning a simple key` في الـ YAML | عدم محاذاة الأسطر (Indentation) داخل كتلة `run: \|` في ملف الـ Workflow. | استخدام أوامر `echo` واضحة ومباشرة لتوليد الملفات بدلاً من الهيردوك المتداخل. |
| **8** | `Validation failed (409) SDK version issue ... must be built with iOS 26 SDK` | تشغيل الـ Workflow على سيرفر `macos-15` الذي يحتوي على iOS 18.5 SDK القديم، بينما تشترط Apple حالياً iOS 26 SDK. | ترقية السيرفر في الـ Workflow إلى `runs-on: macos-26` المزود بـ macOS 26 Tahoe و Xcode 26.6 و iOS 26.5 SDK. |
