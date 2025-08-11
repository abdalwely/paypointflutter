#!/bin/bash

echo "🚀 مرحباً بك في PayPoint Flutter!"
echo "================================"

# التحقق من Flutter
echo "🔍 التحقق من Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter غير مثبت. يرجى تثبيته أولاً:"
    echo "   https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter موجود!"

# تشغيل flutter doctor
echo ""
echo "🏥 فحص حالة Flutter..."
flutter doctor

# الحصول على المكتبات
echo ""
echo "📦 تحميل المكتبات المطلوبة..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ تم تحميل المكتبات بنجاح!"
else
    echo "❌ فشل في تحميل المكتبات"
    exit 1
fi

# اختيار المنصة
echo ""
echo "🎯 اختر المنصة للتشغيل:"
echo "1) الويب (مستحسن للتطوير)"
echo "2) Android"
echo "3) iOS (macOS فقط)"
echo "4) إلغاء"

read -p "اختر رقم (1-4): " choice

case $choice in
    1)
        echo "🌐 تشغيل على الويب..."
        echo "سيفتح على: http://localhost:3000"
        flutter run -d web-server --web-port=3000
        ;;
    2)
        echo "📱 تشغيل على Android..."
        flutter run -d android
        ;;
    3)
        echo "🍎 تشغيل على iOS..."
        flutter run -d ios
        ;;
    4)
        echo "تم الإلغاء"
        exit 0
        ;;
    *)
        echo "❌ خيار غير صحيح"
        exit 1
        ;;
esac

echo ""
echo "🎉 تم تشغيل PayPoint بنجاح!"
echo "💡 نصائح:"
echo "   - الرصيد التجريبي: 1,250.00 ريال"
echo "   - جميع الخدمات متاحة مع بيانات وهمية"
echo "   - لإعادة التشغيل: ./quick_start.sh"
echo ""
echo "📧 للدعم: تواصل مع فريق التطوير"
