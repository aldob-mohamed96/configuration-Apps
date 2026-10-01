# 🚀 Mobile Apps Configuration & CI/CD Automation Hub
### مستودع الإعدادات الاحترافية وأتمتة النشر والربط التسويقي لتطبيقات الموبايل (Flutter / iOS / Android)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Actions" />
  <img src="https://img.shields.io/badge/Meta_For_Developers-0668E1?style=for-the-badge&logo=meta&logoColor=white" alt="Meta" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License" />
</p>

---

## 📖 نظرة عامة | Overview

مستودع شامل ومخصص لمطوري تطبيقات الموبايل وفرق العمل التقنية. يحتوي على أدلة تقنية مفصلة، ملفات إعداد جاهزة للإنتاج (Production-ready Configurations)، وسير عمل مؤتمتة (CI/CD Pipelines) تهدف إلى توفير مئات الساعات في إعداد ونشر وتتبع تطبيقات الهواتف الذكية:

1. **أتمتة النشر الكامل على متجر أبل (App Store & TestFlight CI/CD)** عبر GitHub Actions بدون الحاجة لجهاز ماك محلي عند النشر.
2. **الربط المتكامل لـ Facebook SDK & Meta App Events** لتتبع حملات التثبيت الإعلانية (App Install Ads) والأحداث المخصصة داخل التطبيق.
3. **توجيهات مخصصة لمساعدي الذكاء الاصطناعي (AI Coding Agents)** لتنفيذ العمليات البرمجية بشكل مستقل ودقيق في أي مشروع فلاتر.

---

## 📂 محتويات المستودع | Repository Structure

```text
configuration-Apps/
│
├── 📁 "ci cd apple and google "/
│   └── 📁 ios/
│       └── 📁 workflows/
│           ├── 📄 deploy_ios.yml                      # ملف سير العمل الجاهز للرفع لـ App Store / TestFlight
│           ├── 📘 IOS_CI_CD_APP_STORE_GUIDE.md        # الدليل الشامل والمفصل خطوة بخطوة باللغة العربية
│           ├── 🌐 index.html                          # توثيق تفاعلي مرئي بتصميم عصري
│           └── 🌐 ios_appstore_github_actions_guide.html
│
├── 📁 "facebook install button on ads"/
│   ├── 📘 FACEBOOK_SDK_DEVELOPER_GUIDE.md    # الدليل الشامل لربط Meta SDK في Flutter (Android + iOS)
│   ├── 🤖 FACEBOOK_SDK_AI_PROMPT_GUIDE.md     # برومبت احترافي جاهز للذكاء الاصطناعي لتنفيذ الربط ذاتياً
│   ├── 🌐 FACEBOOK_SDK_GUIDE.html             # صفحة ويب تفاعلية إرشادية وتوثيق مرئي للمطورين
│   └── 🌐 index.html
│
└── 📄 README.md                               # الفهرس والدليل العام للمستودع
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

> 🔗 **للاطلاع على الدليل الكامل:** اقرأ [دليل إعداد CI/CD لنشر تطبيقات Flutter](file:///Users/mohamedgaber/projects/configuration%20Apps/ci%20cd%20apple%20and%20google%20/ios/workflows/IOS_CI_CD_APP_STORE_GUIDE.md).

---

### 2️⃣ ربط Facebook SDK وتتبع إعلانات التثبيت (Meta App Events)
📂 **المسار:** [`facebook install button on ads`](file:///Users/mohamedgaber/projects/configuration%20Apps/facebook%20install%20button%20on%20ads)

دليل هندسي متكامل لربط تطبيق Flutter بمنصة **Meta for Developers** لتفعيل زر التثبيت في الإعلانات الموجهة وحساب تكلفة التثبيت (CPI) وتتبع مسار العميل داخل التطبيق.

#### ✨ ما يتم تغطيته:
- **تتبع التثبيتات التلقائي (App Installs):** إرسال إشعار التثبيت والإقلاع تلقائياً فور فتح التطبيق.
- **إعدادات Android:** ضبط `AndroidManifest.xml` و `res/values/strings.xml` وتوليد بصمات التوقيع (Key Hashes).
- **إعدادات iOS:** تهيئة `Info.plist` وتفعيل حوار أذونات التتبع `App Tracking Transparency (ATT)` لتوافق كامل مع iOS 14.5+.
- **خدمة فلاتر موحدة:** كود Dart احترافي لكلاس `FacebookEventsService` لإرسال الأحداث الأساسية والمخصصة (Registration, Purchase, ViewContent).
- **AI Agent Directive:** ملف [`FACEBOOK_SDK_AI_PROMPT_GUIDE.md`](file:///Users/mohamedgaber/projects/configuration%20Apps/facebook%20install%20button%20on%20ads/FACEBOOK_SDK_AI_PROMPT_GUIDE.md) مصمم خصيصاً لإعطائه لأي أداة ذكاء اصطناعي (Cursor / Claude / Antigravity) لتنفيذ الربط بشكل ذاتي بدون أخطاء.

> 🔗 **للاطلاع على الدليل الكامل:** اقرأ [دليل ربط Facebook SDK للمطورين](file:///Users/mohamedgaber/projects/configuration%20Apps/facebook%20install%20button%20on%20ads/FACEBOOK_SDK_DEVELOPER_GUIDE.md).

---

## 🔒 دليل الأمان وحماية المفاتيح | Security Best Practices

> [!WARNING]
> **لا تقم أبداً برفع ملفات الشهادات أو المفاتيح الحقيقية إلى Git مباشرة.**

جميع مسارات العمل في هذا المستودع تعتمد على **GitHub Secrets** المشفرة:
- **`APP_STORE_CONNECT_PRIVATE_KEY`**: مفتاح الـ API بصيغة AuthKey.
- **`APP_STORE_CONNECT_KEY_ID`** و **`APP_STORE_CONNECT_ISSUER_ID`**.
- **`BUILD_CERTIFICATE_BASE64`**: شهادة التوزيع مشفرة Base64.
- **`BUILD_PROVISION_PROFILE_BASE64`**: ملف الـ Provisioning مشفر Base64.
- **`P12_PASSWORD`**: كلمة سر الشهادة.

---

## 🗺️ خريطة التطوير القادمة | Upcoming Additions

- [ ] 🤖 **Google Play CI/CD Pipeline:** سير عمل GitHub Actions لرفع حزم Android App Bundle (`.aab`) تلقائياً إلى مسار الاختبار الداخلي في Google Play Console.
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
