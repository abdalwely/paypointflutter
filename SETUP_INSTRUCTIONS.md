# تعليمات تشغيل مشروع PayPoint Flutter

## 📋 المتطلبات الأساسية

1. **Flutter SDK** - إصدار 3.1.5 أو أحدث
2. **Dart SDK** - يأتي مع Flutter
3. **محرر كود** - Android Studio, VS Code, أو أي محرر تفضله

## 🚀 خطوات التشغيل

### 1. تثبيت Flutter SDK

```bash
# لنظام Windows
# قم بتحميل Flutter من: https://flutter.dev/docs/get-started/install/windows

# لنظام macOS  
# قم بتحميل Flutter من: https://flutter.dev/docs/get-started/install/macos

# لنظام Linux
# قم بتحميل Flutter من: https://flutter.dev/docs/get-started/install/linux
```

### 2. التحقق من Flutter

```bash
flutter doctor
```

### 3. تشغيل المشروع

```bash
# انتقل إلى مجلد المشروع
cd paypoint_flutter

# احصل على المكتبات المطلوبة
flutter pub get

# تشغيل التطبيق على الويب
flutter run -d web-server --web-port=3000

# أو تشغيل على الهاتف/المحاكي
flutter run
```

## 📱 الأجهزة المدعومة

- **Android**: إصدار 21 (Android 5.0) أو أحدث
- **iOS**: إصدار 11.0 أو أحدث  
- **Web**: Chrome, Firefox, Safari, Edge
- **Desktop**: Windows, macOS, Linux

## 🎯 المزايا المضافة

✅ **واجهات جميلة مع بيانات وهمية**
- رصيد وهمي: 1,250.00 ريال
- معاملات وهمية للعرض
- جميع الخدمات متاحة

✅ **تصميم متجاوب**
- يعمل على جميع أحجام الشاشات
- تخطيط تكيفي للهاتف والتابلت

✅ **تجربة مستخدم ممتازة**
- انتقالات سلسة
- رسوم متحركة جميلة
- تفاعل سريع

## 🔧 إعدادات التطوير

### VS Code Extensions المفيدة:
- Flutter
- Dart
- Flutter Intl
- Flutter Widget Snippets

### Android Studio Plugins:
- Flutter Plugin
- Dart Plugin

## 📂 هيكل المشروع

```
lib/
├── core/                 # الملفات الأساسية
│   ├── constants/       # الثوابت
│   ├── theme/          # التصميم والألوان
│   ├── localization/   # الترجمات
│   └── data/           # البيانات الوهمية
├── models/              # نماذج البيانات
├── providers/           # إدارة الحالة
├── screens/             # الشاشات
│   ├── auth/           # شاشات التسجيل
│   ├── home/           # الشاشة الرئيسية
│   ├── services/       # شاشات الخدمات
│   └── profile/        # شاشة الملف الشخصي
├── widgets/            # العناصر المعاد استخدامها
└── main.dart           # نقطة البداية
```

## 🎨 الخدمات المتاحة

1. **شحن كروت الشبكة** - يمن موبايل، MTN، سبأفون، واي
2. **شحن الكهرباء** - دفع فواتير الكهرباء
3. **دفع فاتورة المياه** - تسديد فواتير المياه  
4. **الرسوم المدرسية** - دفع رسوم المدارس

## 🔄 التحديث للـ API الحقيقي

عندما يصبح الـ API جاهزاً:

1. قم بتحديث `lib/providers/mock_data_provider.dart`
2. اربط المتغيرات بالـ API الحقيقي
3. قم بإزالة `useMockDataProvider` 

## 🐛 حل المشاكل الشائعة

### خطأ: "Flutter command not found"
```bash
export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"
```

### خطأ: "Unable to locate Android SDK"
- قم بتثبيت Android Studio
- افتح SDK Manager وحمل Android SDK

### خطأ: "CocoaPods not installed" (macOS فقط)
```bash
sudo gem install cocoapods
```

## 📞 الدعم

إذا واجهت أي مشاكل:
1. تحقق من `flutter doctor`
2. تأكد من تثبيت جميع المتطلبات
3. قم بتشغيل `flutter clean` ثم `flutter pub get`

---

🎉 **مبروك! تطبيق PayPoint جاهز للعمل!**
