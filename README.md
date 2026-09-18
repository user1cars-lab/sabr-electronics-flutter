<div align="center">
<img src="./assets/project-cover.png" alt="SABR Electronics Flutter" width="100%" />

# SABR Electronics — Flutter

<img src="https://img.shields.io/badge/Flutter-54C5F8?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" /> <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" /> <img src="https://img.shields.io/badge/RTL-Arabic-8B5CF6?style=for-the-badge" alt="Arabic RTL" />

</div>

# صبر إلكترونكس — Flutter

تطبيق جوال محلي لإدارة أجهزة الزبائن في محل **صبر إلكترونكس**، مبني بلغة Dart وFlutter مع واجهة عربية RTL. لا يحتاج إلى خادم أو حساب أو مفتاح API؛ تحفظ البيانات محلياً على الهاتف باستخدام `shared_preferences`.

## المزايا

لوحة تحكم للإحصاءات، إضافة وتعديل الأجهزة، دورة الحالات الثماني، البحث والتصفية، تفاصيل الجهاز، رسالة WhatsApp جاهزة، تقارير مالية وحسب الحالات، مشاركة CSV، ونسخة احتياطية JSON للمشاركة. صُمم التطبيق ليكون أساساً قابلاً للتوسعة لإضافة الكاميرا والإشعارات والقفل بالبصمة عبر plugins أصلية.

## التشغيل

```bash
flutter pub get
flutter run
```

## تحميل نسخة Android عامة

ينشئ GitHub Actions نسخة APK Release تلقائياً عند تشغيل workflow يدوياً أو دفع tag يبدأ بـ `v`. يمكن لأي شخص تحميل أحدث نسخة من صفحة [Releases](https://github.com/user1cars-lab/sabr-electronics-flutter/releases/latest)، ثم تنزيل الملف `sabr-electronics-release.apk` وتثبيته على Android. لا تحتاج النسخة إلى تشغيل Metro أو توصيل الهاتف بالكمبيوتر.

لإنشاء نسخة Android:

```bash
flutter build apk --release
```

لإنشاء نسخة iOS (يتطلب macOS وحساب Apple Developer):

```bash
flutter build ipa --release
```

## الخصوصية

البيانات محلية على الجهاز. حذف التطبيق أو فقدان الهاتف قد يؤدي إلى فقدان البيانات؛ استخدم زر النسخ الاحتياطي بشكل دوري واحتفظ بالملف في مكان آمن.
