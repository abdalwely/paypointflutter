import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/app_config.dart';
import '../../widgets/animated_widgets.dart';
import '../home/enhanced_dashboard_screen.dart';

class TransactionResultScreen extends ConsumerStatefulWidget {
  static const String routeName = '/transaction-result';
  
  const TransactionResultScreen({super.key});

  @override
  ConsumerState<TransactionResultScreen> createState() => _TransactionResultScreenState();
}

class _TransactionResultScreenState extends ConsumerState<TransactionResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _successController;
  late AnimationController _cardController;
  late Animation<double> _successAnimation;
  late Animation<Offset> _cardSlideAnimation;
  
  Map<String, dynamic>? transactionData;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    // Start animations
    _successController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (transactionData == null) {
      transactionData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    }
  }

  @override
  void dispose() {
    _successController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ $label'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareResult() {
    if (transactionData != null) {
      final provider = _getProviderNameAr(transactionData!['provider']);
      final value = transactionData!['value'];
      final code = transactionData!['cardCode'];
      final serial = transactionData!['cardSerial'];
      
      final text = '''🎉 تم شراء كرت $provider بقيمة $value ريال بنجاح!

💳 كود الكرت: $code
${serial != null ? '🔢 الرقم المسلسل: $serial' : ''}

📱 PayPoint - خدمات الدفع الإلكتروني''';
      
      // Here you would implement actual sharing
      _copyToClipboard(text, 'معلومات الكرت');
    }
  }

  String _getProviderNameAr(String? provider) {
    if (provider == null) return '';
    final network = AppConfig.supportedNetworks
        .firstWhere((n) => n['id'] == provider, orElse: () => {'name': provider});
    return network['name'] ?? provider;
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = transactionData?['isSuccess'] ?? false;
    
    return Scaffold(
      backgroundColor: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'نتيجة المعاملة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                      EnhancedDashboardScreen.routeName,
                      (route) => false,
                    ),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Success/Error Animation
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Success/Error Icon
                    AnimatedBuilder(
                      animation: _successAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _successAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isSuccess 
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : AppTheme.errorColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSuccess ? Icons.check_circle : Icons.error,
                              size: 50,
                              color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Status Text
                    Text(
                      isSuccess ? 'تمت العملية بنجاح!' : 'فشلت العملية!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Message
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        transactionData?['message'] ?? 
                        (isSuccess ? 'تم شراء الكرت بنجاح' : 'حدث خطأ في العملية'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Card Details (if success and has card info)
                    if (isSuccess && transactionData?['cardCode'] != null)
                      SlideTransition(
                        position: _cardSlideAnimation,
                        child: _buildCardDetails(),
                      ),
                    
                    // Transaction Details
                    Expanded(
                      child: SlideTransition(
                        position: _cardSlideAnimation,
                        child: _buildTransactionDetails(),
                      ),
                    ),
                    
                    // Action Buttons
                    _buildActionButtons(isSuccess),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetails() {
    final cardCode = transactionData!['cardCode'];
    final cardSerial = transactionData!['cardSerial'];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'معلومات الكرت',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Card Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'كود الكرت',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cardCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(cardCode, 'كود الكرت'),
                  icon: const Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          // Serial Number (if available)
          if (cardSerial != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الرقم المسلسل',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cardSerial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(cardSerial, 'الرقم المسلسل'),
                    icon: const Icon(
                      Icons.copy,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل المعاملة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (transactionData?['provider'] != null) ...[
            _buildDetailRow(
              'المزود',
              _getProviderNameAr(transactionData!['provider']),
            ),
            const SizedBox(height: 12),
          ],
          
          if (transactionData?['value'] != null) ...[
            _buildDetailRow(
              'القيمة',
              '${transactionData!['value']} ريال',
            ),
            const SizedBox(height: 12),
          ],
          
          if (transactionData?['transactionId'] != null) ...[
            _buildDetailRow(
              'رقم المعاملة',
              transactionData!['transactionId'],
            ),
            const SizedBox(height: 12),
          ],
          
          _buildDetailRow(
            'التاريخ والوقت',
            _formatDateTime(DateTime.now()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isSuccess) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (isSuccess && transactionData?['cardCode'] != null) ...[
            // Share Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareResult,
                icon: const Icon(Icons.share, size: 18),
                label: const Text(
                  'مشاركة معلومات الكرت',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Back to Dashboard Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                EnhancedDashboardScreen.routeName,
                (route) => false,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess 
                    ? AppTheme.successColor 
                    : AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'العودة للرئيسية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final formatter = 'yyyy/MM/dd - HH:mm';
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
