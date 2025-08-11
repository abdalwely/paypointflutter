import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';
import '../transactions/transaction_result_screen.dart';

class NetworkRechargeScreen extends ConsumerStatefulWidget {
  static const String routeName = '/network-recharge';
  
  const NetworkRechargeScreen({super.key});

  @override
  ConsumerState<NetworkRechargeScreen> createState() => _NetworkRechargeScreenState();
}

class _NetworkRechargeScreenState extends ConsumerState<NetworkRechargeScreen> {
  String? selectedNetwork;
  int? selectedValue;
  bool isLoading = false;

  void _handlePurchase() async {
    if (selectedNetwork == null || selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار الشبكة وفئة الكرت'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في بيانات المستخدم'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final transaction = TransactionModel(
        id: '',
        userId: currentUser.uid,
        type: TransactionType.networkRecharge,
        amount: selectedValue!.toDouble(),
        details: {
          'network': selectedNetwork,
          'value': selectedValue,
          'networkName': AppConstants.networkTypes
              .firstWhere((n) => n['id'] == selectedNetwork)['name'],
        },
        createdAt: DateTime.now(),
      );

      final transactionId = await ref
          .read(transactionControllerProvider.notifier)
          .createTransaction(transaction);

      if (transactionId != null && mounted) {
        Navigator.of(context).pushReplacementNamed(
          TransactionResultScreen.routeName,
          arguments: {
            'transactionId': transactionId,
            'isSuccess': true,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المعاملة: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'شحن كروت الشبكة',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Network Selection
            const Text(
              'اختر الشبكة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: AppConstants.networkTypes.length,
              itemBuilder: (context, index) {
                final network = AppConstants.networkTypes[index];
                final isSelected = selectedNetwork == network['id'];
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedNetwork = network['id'];
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? network['color'].withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? network['color'] : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: network['color'].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: network['color'],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.sim_card,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          network['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? network['color'] : AppConstants.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Value Selection
            const Text(
              'اختر فئة الكرت',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: AppConstants.cardValues.length,
              itemBuilder: (context, index) {
                final value = AppConstants.cardValues[index];
                final isSelected = selectedValue == value;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppConstants.primaryColor : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$value',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppConstants.primaryColor : AppConstants.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          'ريال',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? AppConstants.primaryColor : AppConstants.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Summary Card
            if (selectedNetwork != null && selectedValue != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملخص العملية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الشبكة:',
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          AppConstants.networkTypes
                              .firstWhere((n) => n['id'] == selectedNetwork)['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الفئة:',
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          '$selectedValue ريال',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المجموع:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          '$selectedValue ريال',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Purchase Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedNetwork != null && selectedValue != null && !isLoading)
                    ? _handlePurchase
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'شراء الكرت',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
