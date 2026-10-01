# دليل إعداد CI/CD لنشر تطبيقات Flutter على Google Play Store تلقائياً

هذا الدليل يشرح بالتفصيل وخطوة بخطوة كيفية إعداد **GitHub Actions Workflow** متكامل لبناء وتوقيع ورفع تطبيق فلاتر (Android) إلى **Google Play Console (Internal Testing / Closed Testing / Production)** بشكل آلي تماماً، مع ميزة **زيادة رقم الإصدار (Build Number / Version Code) تلقائياً** في كل عملية رفع دون أي تعارض.

---

## 📌 المحتويات
1. [المتطلبات الأساسية](#1-المتطلبات-الأساسية)
2. [الخطوة 1: استخراج مفتاح Google Cloud Service Account (ملف JSON)](#2-الخطوة-1-استخراج-مفتاح-google-cloud-service-account)
3. [الخطوة 2: ربط وإعطاء الصلاحيات في Google Play Console](#3-الخطوة-2-ربط-وإعطاء-الصلاحيات-في-google-play-console)
4. [الخطوة 3: ملف التوقيع Keystore (.jks) وكلمات السر](#4-الخطوة-3-ملف-التوقيع-keystore)
5. [الخطوة 4: إضافة الـ Secrets في GitHub](#5-الخطوة-4-إضافة-الـ-secrets-في-github)
6. [الخطوة 5: إعداد ملفات المشروع (build.gradle.kts & key.properties)](#6-الخطوة-5-إعداد-ملفات-المشروع)
7. [الخطوة 6: ملف الـ Workflow الكامل (.github/workflows/deploy_android.yml)](#7-الخطوة-6-ملف-الـ-workflow-الكامل)
8. [الخطوة 7: استراتيجية فرع release والتشغيل والمتابعة](#8-الخطوة-7-استراتيجية-فرع-release-والتشغيل)
9. [الخطوة 8: نصائح هامة وتجنب الأخطاء الشائعة (Tips & Troubleshooting)](#9-الخطوة-8-نصائح-هامة-وتجنب-الأخطاء-الشائعة)

---

## 1. المتطلبات الأساسية
- حساب مطور **Google Play Developer Console** مفعل.
- مشروع مسجل على **Google Cloud Console**.
- وجود حزمة التطبيق (Package Name / Application ID) مثل: `com.codebyte.mondera`.
- مستودع المشروع مرفوع على **GitHub**.

---

## 2. الخطوة 1: استخراج مفتاح Google Cloud Service Account
هذا المفتاح يسمح لـ GitHub Actions برفع ملف الـ App Bundle (`.aab`) إلى Google Play Console بدون الحاجة لتسجيل دخول تفاعلي أو التحقق بخطوتين:

1. ادخل على: **[Google Cloud Console](https://console.cloud.google.com)** وتأكد من اختيار مشروع التطبيق في الأعلى.
2. فعّل الـ API بالدخول على الرابط التالي والضغط على زر **Enable**:
   👉 **[Google Play Android Developer API](https://console.cloud.google.com/apis/library/androidpublisher.googleapis.com)**
3. ادخل على صفحة حسابات الخدمة:
   👉 **[IAM & Admin > Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)**
4. اضغط على **`+ Create service account`**:
   - **Service account name:** `play-store-actions`
   - اضغط **Create and continue**.
   - في خانة **Role**: اختر `Basic` > **Editor** (أو `Service Account User`).
   - اضغط **Done**.
5. ستجد الحساب ظهر في الجدول ومعه إيميل ينتهي بـ:
   `...@<project-id>.iam.gserviceaccount.com` *(انسخ هذا الإيميل لاستخدامه في الخطوة التالية)*.
6. على نفس السطر في أقصى اليمين، اضغط على النقاط الثلاث **⋮ (Actions)** > اختر **Manage keys**.
7. اضغط **Add key** > ثم **Create new key** > اختر نوع **JSON** واضغط **Create**.
   *(سيتم تنزيل ملف بامتداد `.json` على جهازك - احفظه لأن هذا هو مفتاح الرفع).*

---

## 3. الخطوة 2: ربط وإعطاء الصلاحيات في Google Play Console
1. افتح **[Google Play Console](https://play.google.com/console)**.
2. من القائمة الجانبية الرئيسية، ادخل على: **المستخدمون والأذونات** (Users and permissions).
3. اضغط على زر **دعوة مستخدمين جدد** (Invite new users).
4. في خانة البريد الإلكتروني: ضع إيميل حساب الخدمة الذي نسخته في الخطوة السابقة (`...@...iam.gserviceaccount.com`).
5. في تبويب **أذونات التطبيق** (App permissions):
   - اضغط **إضافة تطبيق** واختر تطبيقك.
   - فعّل صلاحيات: **إصدار التطبيقات للمسارات الاختبارية والإنتاج** (Releases).
6. اضغط في الأسفل على **إرسال الدعوة** (Invite user).

---

## 4. الخطوة 3: ملف التوقيع Keystore (.jks) وكلمات السر
لتوقيع التطبيق رسمياً بنسخة Release:

### أ) إذا كان لديك ملف Keystore مسبقاً:
قم بتحويل ملف الـ Keystore إلى نص Base64:
```bash
base64 -i android/app/keystore.jks | tr -d '\r\n' > android_keystore_base64.txt
```

### ب) إذا كنت تريد إنشاء Keystore جديد:
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload -storepass YOUR_STORE_PASSWORD -keypass YOUR_KEY_PASSWORD
```

---

## 5. الخطوة 4: إضافة الـ Secrets في GitHub
ادخل على مستودعك في GitHub:
> **Settings** > **Secrets and variables** > **Actions** > اضغط **New repository secret**

أضف الـ 5 مفاتيح التالية:

| اسم المفتاح (Secret Name) | القيمة المطلوبة (Secret Value) |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | محتوى ملف `android_keystore_base64.txt` كاملاً |
| `ANDROID_STORE_PASSWORD` | كلمة سر مخزن المفاتيح (`storePassword`) |
| `ANDROID_KEY_ALIAS` | اسم المفتاح (`keyAlias`) |
| `ANDROID_KEY_PASSWORD` | كلمة سر المفتاح (`keyPassword`) |
| `PLAY_STORE_JSON_KEY` | محتوى ملف الـ `.json` الذي قمنا بتنزيله من Google Cloud كاملاً |

---

## 6. الخطوة 5: إعداد ملفات المشروع

### 1) ملف `android/app/build.gradle.kts`:
تأكد من وجود إعدادات قراءة التوقيع من `key.properties`:
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}
```

---

## 7. الخطوة 6: ملف الـ Workflow الكامل (.github/workflows/deploy_android.yml)

أنشئ الملف في المسار: `.github/workflows/deploy_android.yml`:

```yaml
name: Deploy Android to Google Play Store

on:
  push:
    branches:
      - release # يعمل فقط عند عمل Push أو دمج PR على برانش release
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
    name: Build & Upload to Google Play
    runs-on: ubuntu-latest # سيرفر لينكس مجاني وسريع جداً
    timeout-minutes: 30

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
          cache: 'gradle'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Calculate Version & Auto-Increment Build Number
        id: versioning
        run: |
          RAW_VERSION=$(grep '^version:' pubspec.yaml | sed -E 's/version:[[:space:]]*//')
          VERSION_NAME=$(echo "$RAW_VERSION" | cut -d'+' -f1)
          BASE_BUILD=$(echo "$RAW_VERSION" | cut -d'+' -f2)

          if [ -z "$BASE_BUILD" ] || [ "$BASE_BUILD" = "$VERSION_NAME" ]; then
            BASE_BUILD=108
          fi

          CUSTOM_BUILD="${{ inputs.custom_build_number }}"
          if [ -n "$CUSTOM_BUILD" ]; then
            BUILD_NUMBER="$CUSTOM_BUILD"
          else
            BUILD_NUMBER=$(( BASE_BUILD + GITHUB_RUN_NUMBER ))
          fi

          sed -i "s/^version:.*/version: $VERSION_NAME+$BUILD_NUMBER/g" pubspec.yaml

          echo "VERSION_NAME=$VERSION_NAME" >> $GITHUB_ENV
          echo "BUILD_NUMBER=$BUILD_NUMBER" >> $GITHUB_ENV
          echo "========================================="
          echo "🚀 Deploying Android Version: $VERSION_NAME (Build $BUILD_NUMBER)"
          echo "========================================="

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

      - name: Configure Keystore & Signing Credentials
        env:
          ANDROID_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
          ANDROID_STORE_PASSWORD: ${{ secrets.ANDROID_STORE_PASSWORD }}
          ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
        run: |
          python3 -c "import base64, os; s = os.environ['ANDROID_KEYSTORE_BASE64'].strip(); s += '=' * (-len(s) % 4); open('android/app/keystore.jks', 'wb').write(base64.b64decode(s))"

          cat << EOF > android/key.properties
          storePassword=$ANDROID_STORE_PASSWORD
          keyPassword=$ANDROID_KEY_PASSWORD
          keyAlias=$ANDROID_KEY_ALIAS
          storeFile=keystore.jks
          EOF
          sed -i 's/^[[:space:]]*//' android/key.properties

      - name: Install Dependencies
        run: flutter pub get

      - name: Build Android App Bundle (AAB)
        run: |
          flutter build appbundle --release \
            --build-name="$VERSION_NAME" \
            --build-number="$BUILD_NUMBER"

      - name: Upload to Google Play (Internal Testing)
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_JSON_KEY }}
          packageName: com.codebyte.mondera
          releaseFiles: build/app/outputs/bundle/release/*.aab
          track: internal # أو production / alpha / beta
          status: completed
```

---

## 8. الخطوة 7: استراتيجية فرع `release` والتشغيل

1. **التطوير الحر:** اعمل بحرية على فرع `version2` أو أي فرع عمل دون تشغيل بناء الأندرويد.
2. **النشر التلقائي:** عند الرغبة في إطلاق نسخة رسمية جديدة، ادمج التعديلات في فرع `release`:
   ```bash
   git checkout release
   git merge version2
   git push origin release
   ```
3. سيبدأ الـ Workflow فوراً في فحص الكود، بناء الـ AAB الموقّع، ورفعه تلقائياً لمسار **Internal testing** في Google Play.
4. **التشغيل اليدوي:** يمكنك دائماً تشغيله بضغطة زر من صفحة **Actions** > **Deploy Android to Google Play Store** > **Run workflow**.

---

## 9. الخطوة 8: نصائح هامة وتجنب الأخطاء الشائعة (Tips & Troubleshooting)

### 💡 شرط الرفع اليدوي لأول نسخة (Initial Release Requirement):
- **قاعدة صارمة لدى Google Play Console:** لا تسمح واجهة الـ API برفع التطبيق للمرة الأولى على الإطلاق.
- **الحل:** يجب رفع أول ملف `.aab` **يدوياً لمرة واحدة فقط** من خلال لوحة التحكم (مثلاً داخل مسار Internal Testing). بعد رفع أول ملف يدوياً، تنجح كل عمليات الرفع التلقائية عبر GitHub Actions للأبد.

### 💡 تحديد المسار (Track Selection):
- في خطوة الرفع: `track: internal` تعني المسار التجريبي الداخلي (Internal Testing) وهو الأفضل لاختبار الفريق قبل الطرح العام.
- لتغيير المسار لاحقاً للإنتاج العام، كل ما عليك هو تعديل القيمة في الـ Workflow إلى:
  `track: production`
