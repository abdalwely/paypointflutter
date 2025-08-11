import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF1B365D);
  static const Color secondaryColor = Color(0xFF2E7D9A);
  static const Color accentColor = Color(0xFFFF6B35);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  
  // Network Types
  static const List<Map<String, dynamic>> networkTypes = [
    {
      'id': 'yemenmobile',
      'name': 'يمن موبايل',
      'color': Color(0xFF00BCD4),
      'icon': 'assets/icons/yemenmobile.svg'
    },
    {
      'id': 'mtn',
      'name': 'إم تي إن',
      'color': Color(0xFFFFEB3B),
      'icon': 'assets/icons/mtn.svg'
    },
    {
      'id': 'sabafon',
      'name': 'سبأفون',
      'color': Color(0xFF4CAF50),
      'icon': 'assets/icons/sabafon.svg'
    },
    {
      'id': 'why',
      'name': 'واي',
      'color': Color(0xFF9C27B0),
      'icon': 'assets/icons/why.svg'
    },
  ];
  
  // Card Values
  static const List<int> cardValues = [500, 1000, 2000, 5000, 10000];
  
  // Service Types
  static const String serviceNetworkRecharge = 'network_recharge';
  static const String serviceElectricity = 'electricity';
  static const String serviceWater = 'water';
  static const String serviceSchool = 'school';
  
  // App Settings
  static const String appName = 'PayPoint';
  static const String appVersion = '1.0.0';
  // API
  static const String apiKey = 'AIzaSyBP0kX8BCuHu3K7YqJD6oAlngmUNkG9K-o';
  static const Duration splashDuration = Duration(seconds: 3);
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String cardsCollection = 'cards';
  static const String transactionsCollection = 'transactions';
  static const String schoolsCollection = 'schools';
  
  // Shared Preferences Keys
  static const String isFirstTimeKey = 'is_first_time';
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppConstants.textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppConstants.textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppConstants.textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppConstants.textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppConstants.textPrimary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppConstants.textSecondary,
    fontFamily: 'Cairo',
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppConstants.textSecondary,
    fontFamily: 'Cairo',
  );
}
