@echo off
chcp 65001 >nul
cls

echo 🚀 مرحباً بك في PayPoint Flutter!
echo ================================
echo.

:: التحقق من Flutter
echo 🔍 التحقق من Flutter...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter غير مثبت. يرجى تثبيته أولاً:
    echo    https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Flutter موجود!
echo.

:: تشغيل flutter doctor
echo 🏥 فحص حالة Flutter...
flutter doctor
echo.

:: الحصول على المكتبات
echo 📦 تحميل المكتبات المطلوبة...
flutter pub get

if errorlevel 1 (
    echo ❌ فشل في تحميل المكتبات
    pause
    exit /b 1
)

echo ✅ تم تحميل المكتبات بنجاح!
echo.

:: اختيار المنصة
echo 🎯 اختر المنصة للتشغيل:
echo 1^) الويب ^(مستحسن للتطوير^)
echo 2^) Android
echo 3^) إلغاء
echo.

set /p choice="اختر رقم (1-3): "

if "%choice%"=="1" (
    echo 🌐 تشغيل على الويب...
    echo سيفتح على: http://localhost:3000
    flutter run -d web-server --web-port=3000
) else if "%choice%"=="2" (
    echo 📱 تشغيل على Android...
    flutter run -d android
) else if "%choice%"=="3" (
    echo تم الإلغاء
    pause
    exit /b 0
) else (
    echo ❌ خيار غير صحيح
    pause
    exit /b 1
)

echo.
echo 🎉 تم تشغيل PayPoint بنجاح!
echo 💡 نصائح:
echo    - الرصيد التجريبي: 1,250.00 ريال
echo    - جميع الخدمات متاحة مع بيانات وهمية
echo    - لإعادة التشغيل: quick_start.bat
echo.
echo 📧 للدعم: تواصل مع فريق التطوير
pause
