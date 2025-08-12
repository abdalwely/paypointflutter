import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/data/mock_data.dart';
import '../core/config/app_config.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

/// Provider لحالة المستخدم الحالي (بدون بيانات وهمية)
final currentUserStateProvider = StateProvider<UserModel?>((ref) => null);

/// Provider للمستخدم المسجل دخوله حالياً
final enhancedCurrentUserProvider = Provider<UserModel?>((ref) {
  final currentUser = ref.watch(currentUserStateProvider);
  
  // إذا كان هناك مستخدم مسجل دخوله، استخدمه
  if (currentUser != null) {
    return currentUser;
  }
  
  // إذا لم يكن هناك مست��دم، إرجاع null (لن يظهر بيانات وهمية)
  return null;
});

/// Provider للرصيد الحالي
final enhancedBalanceProvider = Provider<double>((ref) {
  final user = ref.watch(enhancedCurrentUserProvider);
  return user?.balance ?? 0.0;
});

/// Provider لاسم المستخدم الحالي
final enhancedUserNameProvider = Provider<String>((ref) {
  final user = ref.watch(enhancedCurrentUserProvider);
  return user?.name ?? 'مستخدم';
});

/// Provider لحالة الأدمن
final enhancedIsAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(enhancedCurrentUserProvider);
  return user?.isAdmin ?? false;
});

/// Provider للمعاملات الخاصة بالمستخدم الحالي
final userTransactionsProvider = StateProvider<List<TransactionModel>>((ref) => []);

/// Provider للمعاملات الأخيرة
final enhancedTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(userTransactionsProvider);
  return transactions;
});

/// Provider للمعاملات الأخيرة (آخر 3 معاملات)
final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(userTransactionsProvider);
  return transactions.take(3).toList();
});

/// Provider ��حفظ المستخدم في حالة تسجيل الدخول
class UserSession {
  static void login(WidgetRef ref, {
    required String email,
    required String name,
    bool isAdmin = false,
    double balance = 0.0,
  }) {
    final user = UserModel(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: isAdmin ? AppConfig.defaultAdminPhone : '+967700000000',
      isAdmin: isAdmin,
      balance: balance,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    
    ref.read(currentUserStateProvider.notifier).state = user;
    
    // إذا كان أدمن، إضافة بعض المعاملات التجريبية
    if (isAdmin) {
      ref.read(userTransactionsProvider.notifier).state = _generateSampleTransactions();
    }
  }
  
  static void logout(WidgetRef ref) {
    ref.read(currentUserStateProvider.notifier).state = null;
    ref.read(userTransactionsProvider.notifier).state = [];
  }
  
  static void updateBalance(WidgetRef ref, double newBalance) {
    final currentUser = ref.read(currentUserStateProvider);
    if (currentUser != null) {
      final updatedUser = UserModel(
        uid: currentUser.uid,
        name: currentUser.name,
        email: currentUser.email,
        phone: currentUser.phone,
        isAdmin: currentUser.isAdmin,
        balance: newBalance,
        createdAt: currentUser.createdAt,
        lastLoginAt: DateTime.now(),
      );
      ref.read(currentUserStateProvider.notifier).state = updatedUser;
    }
  }
  
  static void addTransaction(WidgetRef ref, TransactionModel transaction) {
    final currentTransactions = ref.read(userTransactionsProvider);
    ref.read(userTransactionsProvider.notifier).state = [transaction, ...currentTransactions];
  }
}

/// إنشاء معاملات تجريبية للأدمن
List<TransactionModel> _generateSampleTransactions() {
  return [
    TransactionModel(
      id: 'T001',
      userId: 'admin',
      type: TransactionType.networkRecharge,
      amount: 1000.0,
      status: TransactionStatus.completed,
      description: 'شحن كرت يمن موبايل - 1000 ريال',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      metadata: {
        'network': 'yemenmobile',
        'customerNumber': '777123456',
        'cardValue': 1000,
      },
    ),
    TransactionModel(
      id: 'T002',
      userId: 'admin',
      type: TransactionType.electricityPayment,
      amount: 5000.0,
      status: TransactionStatus.completed,
      description: 'دفع فاتورة كهرباء',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      metadata: {
        'billNumber': 'ELE123456',
        'customerName': 'أحمد محمد',
      },
    ),
    TransactionModel(
      id: 'T003',
      userId: 'admin',
      type: TransactionType.waterPayment,
      amount: 2500.0,
      status: TransactionStatus.completed,
      description: 'دفع فاتورة مياه',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      metadata: {
        'billNumber': 'WAT789012',
        'customerName': 'فاطمة أحمد',
      },
    ),
  ];
}

/// مزودي البيانات التجريبية (للحالات الطارئة فقط)
final mockUserProvider = Provider<UserModel>((ref) => MockData.mockUser);
final mockAdminUserProvider = Provider<UserModel>((ref) => MockData.mockAdminUser);
final mockTransactionsProvider = Provider<List<TransactionModel>>((ref) => MockData.mockTransactions);
final mockRecentTransactionsProvider = Provider<List<TransactionModel>>((ref) => MockData.recentTransactions);
final mockStatisticsProvider = Provider<Map<String, dynamic>>((ref) => MockData.mockStatistics);
final mockNotificationsProvider = Provider<List<Map<String, dynamic>>>((ref) => MockData.mockNotifications);
final mockNetworkCardsProvider = Provider<List<Map<String, dynamic>>>((ref) => MockData.mockNetworkCards);
final mockSchoolsProvider = Provider<List<Map<String, dynamic>>>((ref) => MockData.mockSchools);

/// Provider للتحكم في استخدام البيانات التجريبية
final useMockDataProvider = StateProvider<bool>((ref) => false);
