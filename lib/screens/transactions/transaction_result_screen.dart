import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/firestore_provider.dart';
import '../home/dashboard_screen.dart';
import 'transactions_screen.dart';
import '../../models/transaction_model.dart';

class TransactionResultScreen extends ConsumerWidget {
  static const String routeName = '/transaction-result';
  
  const TransactionResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final transactionId = args?['transactionId'] as String?;
    final isSuccess = args?['isSuccess'] as bool? ?? false;

    if (transactionId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('نتيجة المعاملة', style: TextStyle(fontFamily: 'Cairo')),
        ),
        body: const Center(
          child: Text(
            'خطأ في تحديد المعاملة',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Result Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isSuccess ? AppConstants.successColor : AppConstants.errorColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isSuccess ? AppConstants.successColor : AppConstants.errorColor)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  isSuccess ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Status Text
              Text(
                isSuccess ? 'تمت العملية بنجاح!' : 'فشلت العملية!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? AppConstants.successColor : AppConstants.errorColor,
                  fontFamily: 'Cairo',
                ),
              ),
              
              const SizedBox(height: 10),
              
              Text(
                isSuccess 
                    ? 'تم تنفيذ المعاملة بنجاح وتم إرسال التفاصيل'
                    : 'حدث خطأ أثناء تنفيذ المعاملة، يرجى المحاولة مرة أخرى',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppConstants.textSecondary,
                  fontFamily: 'Cairo',
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Transaction Details Card
              if (isSuccess)
                FutureBuilder(
                  future: _getTransactionDetails(ref, transactionId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'خطأ في تحميل تفاصيل المعاملة',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      );
                    }
                    
                    final transaction = snapshot.data;
                    if (transaction == null) return const SizedBox.shrink();
                    
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تفاصيل المعاملة',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildDetailRow('رقم المعاملة:', transactionId),
                          _buildDetailRow('نوع العملية:', transaction.getTypeNameAr()),
                          _buildDetailRow('المبلغ:', '${transaction.amount.toStringAsFixed(2)} ريال'),
                          _buildDetailRow('التاريخ:', DateFormat('yyyy/MM/dd HH:mm', 'ar').format(transaction.createdAt)),
                          _buildDetailRow('الحالة:', transaction.getStatusNameAr()),
                          
                          // Show card code for network recharge
                          if (transaction.type == TransactionType.networkRecharge && 
                              transaction.details['cardCode'] != null) ...[
                            const Divider(height: 30),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppConstants.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'رقم الكرت',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.textPrimary,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          transaction.details['cardCode'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppConstants.successColor,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                            text: transaction.details['cardCode'],
                                          ));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('تم نسخ رقم الكرت'),
                                              backgroundColor: AppConstants.successColor,
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.copy,
                                          color: AppConstants.successColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          // Show reference number for other services
                          if (transaction.referenceNumber != null && 
                              transaction.type != TransactionType.networkRecharge) ...[
                            const Divider(height: 30),
                            _buildDetailRow('رقم المرجع:', transaction.referenceNumber!),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              
              const Spacer(),
              
              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          DashboardScreen.routeName,
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'العودة للرئيسية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(TransactionsScreen.routeName);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.primaryColor,
                        side: const BorderSide(color: AppConstants.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'عرض سجل المعاملات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppConstants.textSecondary,
              fontFamily: 'Cairo',
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _getTransactionDetails(WidgetRef ref, String transactionId) async {
    final transactionController = ref.read(transactionControllerProvider);
    return transactionController.value;
  }
}
