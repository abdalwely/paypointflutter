import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/admin_service.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.surfaceColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    print('✅ SharedPreferences initialized');
    
    // Initialize Admin Service and create default admin
    final adminService = AdminService();
    await adminService.createDefaultAdmin();
    
    // Set app configuration
    await _setAppConfiguration();
    
    print('🚀 Starting PayPoint App...');
    
    runApp(
      const ProviderScope(
        child: PayPointApp(),
      ),
    );
  } catch (e) {
    print('❌ Error during app initialization: $e');
    
    // Run app with error handling
    runApp(
      MaterialApp(
        title: 'PayPoint - خطأ',
        home: ErrorScreen(error: e.toString()),
      ),
    );
  }
}

Future<void> _setAppConfiguration() async {
  try {
    // Enable edge-to-edge display
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
    
    // Set app-wide text scale factor
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    print('✅ App configuration set');
  } catch (e) {
    print('⚠️ Warning: Could not set app configuration: $e');
  }
}

// Error Screen for initialization failures
class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.errorColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 80,
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'خطأ في تشغيل التطبيق',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'عذراً، حدث خطأ أثناء تشغيل التطبيق. يرجى إعادة تشغيل التطبيق.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تفاصيل الخطأ:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.errorColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إعادة التشغيل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// App Info and Debugging
class AppInfo {
  static const String name = 'PayPoint';
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const String description = 'تطبيق PayPoint متعدد الخدمات للدفع الإلكتروني';
  
  static void printAppInfo() {
    print('📱 App Name: $name');
    print('🔢 Version: $version');
    print('🏗️ Build: $buildNumber');
    print('📝 Description: $description');
  }
  
  static Map<String, dynamic> getAppInfo() {
    return {
      'name': name,
      'version': version,
      'buildNumber': buildNumber,
      'description': description,
      'isDebug': kDebugMode,
      'platform': Theme.of(navigatorKey.currentContext!).platform.name,
      'locale': Localizations.localeOf(navigatorKey.currentContext!).toString(),
    };
  }
}

// Global navigator key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global error handling
void setupErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack Trace: ${details.stack}');
  };
  
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    print('Platform Error: $error');
    print('Stack Trace: $stack');
    return true;
  };
}

// Performance monitoring
class PerformanceMonitor {
  static DateTime? _appStartTime;
  static DateTime? _splashEndTime;
  static DateTime? _firstFrameTime;
  
  static void markAppStart() {
    _appStartTime = DateTime.now();
    print('⏱️ App start time marked');
  }
  
  static void markSplashEnd() {
    _splashEndTime = DateTime.now();
    if (_appStartTime != null) {
      final duration = _splashEndTime!.difference(_appStartTime!);
      print('⏱️ Splash duration: ${duration.inMilliseconds}ms');
    }
  }
  
  static void markFirstFrame() {
    _firstFrameTime = DateTime.now();
    if (_appStartTime != null) {
      final duration = _firstFrameTime!.difference(_appStartTime!);
      print('⏱️ Time to first frame: ${duration.inMilliseconds}ms');
    }
  }
  
  static Map<String, int> getPerformanceMetrics() {
    final now = DateTime.now();
    return {
      'app_start_to_now': _appStartTime != null 
          ? now.difference(_appStartTime!).inMilliseconds 
          : 0,
      'splash_duration': _appStartTime != null && _splashEndTime != null
          ? _splashEndTime!.difference(_appStartTime!).inMilliseconds
          : 0,
      'time_to_first_frame': _appStartTime != null && _firstFrameTime != null
          ? _firstFrameTime!.difference(_appStartTime!).inMilliseconds
          : 0,
    };
  }
}
