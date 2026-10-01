# 🚀 Mobile Apps Configuration & CI/CD Automation Hub
### مستودع الإعدادات الاحترافية وأتمتة النشر والربط التسويقي والمصادقة والخرائط لتطبيقات الموبايل (Flutter / iOS / Android)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Google_Maps-4285F4?style=for-the-badge&logo=google-maps&logoColor=white" alt="Google Maps" />
  <img src="https://img.shields.io/badge/Google_Play-414141?style=for-the-badge&logo=google-play&logoColor=white" alt="Google Play" />
  <img src="https://img.shields.io/badge/Huawei_AppGallery-C7000B?style=for-the-badge&logo=huawei&logoColor=white" alt="Huawei" />
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Actions" />
  <img src="https://img.shields.io/badge/Meta_For_Developers-0668E1?style=for-the-badge&logo=meta&logoColor=white" alt="Meta" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License" />
</p>

---

## 📖 نظرة عامة | Overview

مستودع شامل ومخصص لمطوري تطبيقات الموبايل وفرق العمل التقنية. يحتوي على أدلة تقنية مفصلة، ملفات إعداد جاهزة للإنتاج (Production-ready Configurations)، وسير عمل مؤتمتة (CI/CD Pipelines) تهدف إلى توفير مئات الساعات في إعداد ونشر وتتبع وتطوير تطبيقات الهواتف الذكية:

1. **أتمتة النشر الكامل على متجر أبل (App Store & TestFlight CI/CD)** عبر GitHub Actions بدون الحاجة لجهاز ماك محلي عند النشر.
2. **أتمتة النشر الكامل على متجر جوجل بلاي (Google Play Store & Internal Testing CI/CD)** عبر GitHub Actions لبناء وتوقيع حزم Android App Bundle (`.aab`) وزيادة أرقام الإصدارات تلقائياً.
3. **الربط المتكامل لـ Facebook SDK & Meta App Events** لتتبع حملات التثبيت الإعلانية (App Install Ads) والأحداث المخصصة داخل التطبيق.
4. **دليل ونماذج متطلبات الـ Metadata لنشر التطبيقات على المتاجر الثلاثة (App Store / Google Play / Huawei AppGallery):** جداول المقاسات، الحدود القصوى للحروف، نماذج نصوص جاهزة وقابلة للتخصيص، وقواعد تجنب الرفض.
5. **تسجيل الدخول الاجتماعي عبر Google & Apple (Social Authentication):** الربط الآمن مع Firebase والـ Backend، استخراج بصمات SHA-1، تشفير Nonce بـ SHA-256، ودعم أحدث معايير v7.
6. **تكامل خرائط جوجل (Google Maps for iOS & Android):** إعداد الـ SDK والصلاحيات الدقيقة، حل مشكلات الـ API Keys والشاشة الرمادية، وإدارة الكاميرا والعلامات والوضع الليلي.
7. **توجيهات مخصصة لمساعدي الذكاء الاصطناعي (AI Coding Agents)** لتنفيذ العمليات البرمجية بشكل مستقل ودقيق في أي مشروع فلاتر.

---

## 📂 محتويات المستودع | Repository Structure

```text
configuration-Apps/
│
├── 📁 "apple and google authentication login"/
│   ├── 📘 GOOGLE_AND_APPLE_AUTH_GUIDE.md          # الدليل الشامل لمصادقة جوجل وأبل خطوة بخطوة
│   ├── 📄 social_auth_service.dart                # كود خدمة فلاتر كامل وجاهز للإنتاج (v7 API + Nonce)
│   └── 🌐 index.html                              # توثيق تفاعلي مرئي بمخصص حي للأكواد والـ Client IDs
│
├── 📁 "google map (apple and google )"/
│   ├── 📘 GOOGLE_MAPS_FLUTTER_GUIDE.md            # الدليل الشامل لربط خرائط جوجل وضبط الصلاحيات
│   ├── 📄 google_map_view_template.dart           # ويدجت خريطة فلاتر جاهز بالكامل (موقع، علامات، ثيم ليلي)
│   └── 🌐 index.html                              # توثيق تفاعلي مرئي بمخصص حي للمفاتيح والأكواد
│
├── 📁 "ci cd apple and google "/
│   ├── 📁 android/
│   │   ├── 📄 deploy_android.yml                  # سير عمل رفع حزم AAB إلى Google Play Store تلقائياً
│   │   ├── 📘 ANDROID_CI_CD_PLAY_STORE_GUIDE.md    # الدليل الشامل والمفصل خطوة بخطوة باللغة العربية
│   │   ├── 🌐 index.html                          # توثيق تفاعلي مرئي بتصميم عصري وخاص بـ Android
│   │   └── 🌐 android_playstore_github_actions_guide.html
│   │
│   └── 📁 ios/
│       └── 📁 workflows/
│           ├── 📄 deploy_ios.yml                  # ملف سير العمل الجاهز للرفع لـ App Store / TestFlight
│           ├── 📘 IOS_CI_CD_APP_STORE_GUIDE.md    # الدليل الشامل والمفصل خطوة بخطوة باللغة العربية
│           ├── 🌐 index.html                      # توثيق تفاعلي مرئي بتصميم عصري
│           └── 🌐 ios_appstore_github_actions_guide.html
│
├── 📁 "facebook install button on ads"/
│   ├── 📘 FACEBOOK_SDK_DEVELOPER_GUIDE.md        # الدليل الشامل لربط Meta SDK في Flutter (Android + iOS)
│   ├── 🤖 FACEBOOK_SDK_AI_PROMPT_GUIDE.md         # برومبت احترافي جاهز للذكاء الاصطناعي لتنفيذ الربط ذاتياً
│   ├── 🌐 FACEBOOK_SDK_GUIDE.html                 # صفحة ويب تفاعلية إرشادية وتوثيق مرئي للمطورين
│   └── 🌐 index.html
│
├── 📁 "meta data upload 3 store"/
│   └── 🌐 store-metadata-requirements.html        # الدليل الشامل ونماذج الـ Metadata الموحدة للمتاجر الثلاثة
│
└── 📄 README.md                                   # الفهرس والدليل العام للمستودع
```

---

## 🛠️ الأقسام الرئيسية | Core Modules

### 1️⃣ أتمتة الرفع لـ App Store و TestFlight (iOS CI/CD)
📂 **المسار:** [`ci cd apple and google /ios/workflows`](file:///Users/mohamedgaber/projects/configuration%20Apps/ci%20cd%20apple%20and%20google%20/ios/workflows)

سير عمل متكامل باستخدام **GitHub Actions** يتيح رفع تطبيقات Flutter مباشرة إلى App Store Connect و TestFlight بضغطة زر أو مع كل دمج مع فرع `main`.

#### ✨ أبرز المميزات:
- **Zero-Credential Login:** استخدام المفتاح الرسمي `App Store Connect API Key (.p8)` دون الحاجة إلى Apple ID أو كلمة مرور أو التحقق بخطوتين (2FA).
- **Auto-Increment Build Number:** زيادة رقم البناء تلقائياً في السحابة مع الحفاظ على صيغة `1.0.0+XX` لمنع أي تعارض مع الإصدارات السابقة.
- **Secure Keychain Handling:** إنشاء Keychain مشفر مؤقت داخل سيرفر الماك في GitHub لتركيب الشهادة التوزيعية (`Apple Distribution .p12`) وملف الـ Provisioning Profile وحذفه فور الانتهاء.
- **Ready-to-use Workflow:** ملف جاهز بالكامل [`deploy_ios.yml`](file:///Users/mohamedgaber/projects/configuration%20Apps/ci%20cd%20apple%20and%20google%20/ios/workflows/deploy_ios.yml).

> 🔗 **للاطلاع على الدليل الكامل:** اقرأ [دليل إعداد CI/CD لنشر تطبيقات Flutter على App Store](file:///Users/mohamedgaber/projects/configuration%20Apps/ci%20cd%20apple%20and%20google%20/ios/workflows/IOS_CI_CD_APP_STORE_GUIDE.md) أو تصفح [الدليل التفاعلي المرئي (HTML)](file:///Users/mohamedgaber/projects/configuration%20Apps/ci%20cd%20apple%20and%20google%20/ios/workflows/index.html).

---

### 2️⃣ أتمتة الرفع لـ Google Play Store (Android CI/CD)
📂 **المسار:** [`ci cd apple and google /android`](file:///Users/mohamedgaber/projects/configuration%20Apps/ci%20cd%20apple%20and%20google%20/android)

سير عمل متكامل وسريع للغاية يعمل على خوادم Linux المجانية (`ubuntu-latest`) في GitHub Actions، يقوم ببناء حزم أندرويد الحديثة (`.aab`) وتوقيعها بمفاتيح Release، ثم رفعها مباشرة إلى مسارات الاختبار في Google Play Console (مثل Internal Testing أو Production) بدون أي تدخل يدوي.

#### ✨ أبرز المميزات:
- **Fast & Free Linux Runners:** يعمل على بيئة `ubuntu-latest` فائقة السرعة بدون استهلاك دقائق الماك المكلفة.
- **Auto-Increment Version Code:** يقرأ الإصدار من `pubspec.yaml` ويقوم بزيادة رقم البناء (Build Number / Version Code) تلقائياً مع كل عملية بناء لتفادي خطأ تكرار الإصدارات في Google Play.
- **Secure Keystore & Credentials:** حفظ ملف التوقيع Keystore مشفراً كـ Secret في GitHub وفك تشفيره لحظياً أثناء البناء، مع توليد ملف `key.properties` مؤقتاً وحذفه فوراً عند انتهاء السيرفر.
- **Service Account API Authorization:** استخدام حساب خدمة Google Cloud الرسمي (`.json`) لرفع الحزم مباشرة دون الحاجة للتحقق بخطوتين أو تسجيل الدخول اليدوي.
- **Ready-to-use Workflow:** ملف جاهز بالكامل [`deploy_android.yml`](file:///Users/mohamedgaber/projects/configuration%20Apps/ci%20cd%20apple%20and%20google%20/android/deploy_android.yml).

> 🔗 **للاطلاع على الدليل الكامل:** اقرأ [دليل إعداد CI/CD لنشر تطبيقات Flutter على Google Play](file:///Users/mohamedgaber/projects/configuration%20Apps/ci%20cd%20apple%20and%20google%20/android/ANDROID_CI_CD_PLAY_STORE_GUIDE.md) أو تصفح [الدليل التفاعلي المرئي (HTML)](file:///Users/mohamedgaber/projects/configuration%20Apps/ci%20cd%20apple%20and%20google%20/android/index.html).

---

### 3️⃣ ربط Facebook SDK وتتبع إعلانات التثبيت (Meta App Events)
📂 **المسار:** [`facebook install button on ads`](file:///Users/mohamedgaber/projects/configuration%20Apps/facebook%20install%20button%20on%20ads)

دليل هندسي متكامل لربط تطبيق Flutter بمنصة **Meta for Developers** لتفعيل زر التثبيت في الإعلانات الموجهة وحساب تكلفة التثبيت (CPI) وتتبع مسار العميل داخل التطبيق.

#### ✨ ما يتم تغطيته:
- **تتبع التثبيتات التلقائي (App Installs):** إرسال إشعار التثبيت والإقلاع تلقائياً فور فتح التطبيق.
- **إعدادات Android:** ضبط `AndroidManifest.xml` و `res/values/strings.xml` وتوليد بصمات التوقيع (Key Hashes).
- **إعدادات iOS:** تهيئة `Info.plist` وتفعيل حوار أذونات التتبع `App Tracking Transparency (ATT)` لتوافق كامل مع iOS 14.5+.
- **خدمة فلاتر موحدة:** كود Dart احترافي لكلاس `FacebookEventsService` لإرسال الأحداث الأساسية والمخصصة (Registration, Purchase, ViewContent).
- **AI Agent Directive:** ملف [`FACEBOOK_SDK_AI_PROMPT_GUIDE.md`](file:///Users/mohamedgaber/projects/configuration%20Apps/facebook%20install%20button%20on%20ads/FACEBOOK_SDK_AI_PROMPT_GUIDE.md) مصمم خصيصاً لإعطائه لأي أداة ذكاء اصطناعي (Cursor / Claude / Antigravity) لتنفيذ الربط بشكل ذاتي بدون أخطاء.

> 🔗 **للاطلاع على الدليل الكامل:** اقرأ [دليل ربط Facebook SDK للمطورين](file:///Users/mohamedgaber/projects/configuration%20Apps/facebook%20install%20button%20on%20ads/FACEBOOK_SDK_DEVELOPER_GUIDE.md) أو تصفح [الدليل التفاعلي المرئي (HTML)](file:///Users/mohamedgaber/projects/configuration%20Apps/facebook%20install%20button%20on%20ads/FACEBOOK_SDK_GUIDE.html).

---

### 4️⃣ دليل ونماذج الـ Metadata لنشر المتاجر الثلاثة (Store Metadata Guide)
📂 **المسار:** [`meta data upload 3 store`](file:///Users/mohamedgaber/projects/configuration%20Apps/meta%20data%20upload%203%20store)

دليل مرجعي متكامل ومفصل يغطي كافة المتطلبات النصية والبصرية والتنظيمية اللازمة لرفع أي تطبيق على المتاجر الثلاثة الكبرى: **Apple App Store** و **Google Play Store** و **Huawei AppGallery**.

#### ✨ ما يحتويه الدليل:
- **نماذج نصوص جاهزة وقابلة للتخصيص (Templates):** نصوص عامة جاهزة للنسخ المباشر بالعربية والإنجليزية لأي تطبيق (اسم التطبيق، العنوان الفرعي Subtitle، الوصف القصير، الوصف الكامل Full Description، ما الجديد Release Notes، النص الترويجي، والكلمات المفتاحية Keywords).
- **مقارنة تفصيلية لحدود الحروف (Character Limits):** جدول مقارن دقيق للحقول الإلزامية والاختيارية وحدود الحروف بين أبل (30 حرف للاسم)، جوجل (30 حرف)، وهواوي (64 حرف).
- **الأبعاد والمواصفات البصرية (Visual Assets Specifications):** أبعاد لقطات الشاشة (Screenshots) لكافة أحجام شاشات الآيفون والأندرويد والآيباد، الأيقونات الرسمية، وصور الرسم المميز (Feature Graphic 1024×500).
- **قواعد تجنب الرفض (Rejection Prevention):** إرشادات تفصيلية لما يجب تجنب كتابته (الأسعار، العروض المؤقتة، عبارات المبالغة، والإيموجي في الأسماء).
- **نموذج حساب المراجعة (Review Notes):** صيغة نموذجية بالإنجليزية لتقديم بيانات الحساب التجريبي وبيانات الدخول لفرق مراجعة المتاجر.

> 🔗 **للاطلاع على الدليل الكامل:** تصفح [دليل ونماذج الـ Metadata للمتاجر](file:///Users/mohamedgaber/projects/configuration%20Apps/meta%20data%20upload%203%20store/store-metadata-requirements.html).

---

### 5️⃣ تسجيل الدخول الاجتماعي عبر Google و Apple (Social Authentication)
📂 **المسار:** [`apple and google authentication login`](file:///Users/mohamedgaber/projects/configuration%20Apps/apple%20and%20google%20authentication%20login)

دليل هندسي شامل مع خدمة Dart كاملة للإنتاج لربط تسجيل الدخول بواسطة حسابات جوجل وأبل على نظامي iOS و Android مع دعم الربط التلقائي بـ Firebase أو الـ Backend الخاص بك.

#### ✨ ما يتم تغطيته:
- **Google Sign-In v7 API:** دعم بنية Google Identity Services الحديثة واستخراج `idToken` و `accessToken`.
- **Sign in with Apple Security:** توليد وتشفير الـ `Nonce` السري بخوارزمية `SHA-256` لحماية المصادقة من هجمات Replay Attacks.
- **دعم Android الكامل لـ Apple:** إعداد الـ `Service ID` والـ Intent Filter ونافذة الويب لاستقبال ردود أبل على أجهزة أندرويد.
- **حلول مشكلات البصمات والأخطاء:** استخراج بصمات SHA-1 و SHA-256 لـ Debug و Release و Google Play App Signing، وحل خطأ `ApiException: 10`، ومعالجة خصوصية أبل (عدم إرسال الاسم إلا في أول مرة).
- **كود جاهز للإنتاج:** كلاس [`social_auth_service.dart`](file:///Users/mohamedgaber/projects/configuration%20Apps/apple%20and%20google%20authentication%20login/social_auth_service.dart) جاهز للإسقاط المباشر في أي مشروع فلاتر.

> 🔗 **للاطلاع على الدليل الكامل:** اقرأ [دليل تسجيل الدخول بجوجل وأبل](file:///Users/mohamedgaber/projects/configuration%20Apps/apple%20and%20google%20authentication%20login/GOOGLE_AND_APPLE_AUTH_GUIDE.md) أو تصفح [التوثيق المرئي التفاعلي](file:///Users/mohamedgaber/projects/configuration%20Apps/apple%20and%20google%20authentication%20login/index.html).

---

### 6️⃣ تكامل خرائط جوجل على نظامي iOS و Android (Google Maps Mobile)
📂 **المسار:** [`google map (apple and google )`](file:///Users/mohamedgaber/projects/configuration%20Apps/google%20map%20%28apple%20and%20google%20%29)

دليل عملي متكامل لتضمين وتشغيل خرائط جوجل (Google Maps SDK) في تطبيقات Flutter، مع حلول معتمدة لأصعب مشاكل التمرير والأذونات والشاشات الرمادية.

#### ✨ ما يتم تغطيته:
- **تهيئة Android:** ضبط `AndroidManifest.xml` وصلاحيات `ACCESS_FINE_LOCATION` وتقييد المفاتيح ببصمات SHA-1.
- **تهيئة iOS الأنيقة:** قراءة مفتاح `GMSApiKey` ديناميكياً من `Info.plist` داخل `AppDelegate.swift` وضبط نصوص الأذونات لقبول متجر App Store.
- **تحديد الموقع والملاحة:** جلب إحداثيات المستخدم الحالية وتحريك الكاميرا بسلاسة فائقة عبر `geolocator`.
- **حل تعارض التمرير (Nested ScrollView Fix):** استخدام `EagerGestureRecognizer` لحل مشكلة توقف تحريك الخريطة عندما تكون داخل صفحات تمرير (Scrollable Views).
- **الوضع الليلي (Dark Mode):** تلوين وتخصيص الخريطة بستايل ليلي داكن فاخر عبر JSON مخصص.
- **قالب ويدجت جاهز:** ملف [`google_map_view_template.dart`](file:///Users/mohamedgaber/projects/configuration%20Apps/google%20map%20%28apple%20and%20google%20%29/google_map_view_template.dart) جاهز للاستخدام المباشر في أي صفحة.

> 🔗 **للاطلاع على الدليل الكامل:** اقرأ [دليل خرائط جوجل في Flutter](file:///Users/mohamedgaber/projects/configuration%20Apps/google%20map%20%28apple%20and%20google%20%29/GOOGLE_MAPS_FLUTTER_GUIDE.md) أو تصفح [التوثيق المرئي التفاعلي](file:///Users/mohamedgaber/projects/configuration%20Apps/google%20map%20%28apple%20and%20google%20%29/index.html).

---

## 🔒 دليل الأمان وحماية المفاتيح | Security Best Practices

> [!WARNING]
> **لا تقم أبداً برفع ملفات الشهادات أو المفاتيح الحقيقية إلى Git مباشرة.**

جميع مسارات العمل في هذا المستودع تعتمد على **GitHub Secrets** المشفرة:

### 🍏 مفاتيح نظام أبل (iOS Secrets):
| اسم المفتاح (Secret Name) | الوصف |
|---|---|
| `APP_STORE_CONNECT_PRIVATE_KEY` | مفتاح الـ API بصيغة AuthKey (`.p8`) |
| `APP_STORE_CONNECT_KEY_ID` | معرّف المفتاح من App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | معرّف المنظمة Issuer ID |
| `BUILD_CERTIFICATE_BASE64` | شهادة التوزيع (`.p12`) مشفرة Base64 |
| `BUILD_PROVISION_PROFILE_BASE64` | ملف الـ MobileProvision مشفر Base64 |
| `P12_PASSWORD` | كلمة سر شهادة التوزيع |

### 🤖 مفاتيح نظام أندرويد (Android Secrets):
| اسم المفتاح (Secret Name) | الوصف |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | ملف التوقيع `keystore.jks` مشفراً بنص Base64 |
| `ANDROID_STORE_PASSWORD` | كلمة سر مخزن المفاتيح (`storePassword`) |
| `ANDROID_KEY_ALIAS` | اسم المفتاح (`keyAlias`) |
| `ANDROID_KEY_PASSWORD` | كلمة سر المفتاح الخاص (`keyPassword`) |
| `PLAY_STORE_JSON_KEY` | محتوى ملف Google Cloud Service Account (`.json`) كاملاً |

---

## 🗺️ خريطة التطوير القادمة | Upcoming Additions

- [x] 🤖 **Google Play CI/CD Pipeline:** سير عمل GitHub Actions لرفع حزم Android App Bundle (`.aab`) تلقائياً إلى مسار الاختبار الداخلي في Google Play Console.
- [x] 📋 **Multi-Store Metadata Requirements Guide:** دليل متكامل لنماذج الـ Metadata والمتطلبات البصرية للمتاجر الثلاثة.
- [x] 🔐 **Google & Apple Social Sign-In Master Guide:** دليل وخدمة برمجية موحدة لتسجيل الدخول بجوجل وأبل لنظامي iOS و Android.
- [x] 🗺️ **Google Maps SDK for iOS & Android Guide & Template:** دليل وقالب ويدجت خرائط جوجل مع معالجة الصلاحيات والـ Dark Mode.
- [ ] 📊 **TikTok & Snapchat Events SDK:** أدلة ربط وتتبع الإعلانات على المنصات الترويجية الأخرى في تطبيقات Flutter.
- [ ] 🚀 **Fastlane Integration Template:** نماذج إعداد Fastlane للمشاريع الكبيرة والفرق المتعددة.

---

## 🤝 المساهمة | Contributing

المساهمات مرحب بها دائماً! إذا كان لديك تحسين لأحد ملفات الـ Workflow، أو دليل إعداد لمنصة جديدة:
1. قم بعمل **Fork** للمستودع.
2. أنشئ فرعاً جديداً لميزتك (`git checkout -b feature/NewFeature`).
3. احفظ التعديلات (`git commit -m 'Add awesome feature'`).
4. ارفع الفرع (`git push origin feature/NewFeature`).
5. افتح **Pull Request**.

---

## 👨‍💻 المطور | Author

تم إعداد وتنسيق هذا المستودع بواسطة **Mohamed Gaber**  
- **GitHub:** [@aldob-mohamed96](https://github.com/aldob-mohamed96)
- **Repository:** [configuration-Apps](https://github.com/aldob-mohamed96/configuration-Apps)

---
<p align="center">⭐️ إذا استفدت من هذا المستودع، لا تنسَ ترك Star تشجيعية له على GitHub!</p>
