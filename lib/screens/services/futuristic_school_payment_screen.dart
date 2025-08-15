import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../transactions/transaction_result_screen.dart';

class FuturisticSchoolPaymentScreen extends ConsumerStatefulWidget {
  static const String routeName = '/futuristic-school-payment';

  const FuturisticSchoolPaymentScreen({super.key});

  @override
  ConsumerState<FuturisticSchoolPaymentScreen> createState() => 
      _FuturisticSchoolPaymentScreenState();
}

class _FuturisticSchoolPaymentScreenState 
    extends ConsumerState<FuturisticSchoolPaymentScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;
  late AnimationController _bookController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _bookAnimation;

  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  
  String _selectedSchool = 'school1';
  String _selectedType = 'tuition';
  String _selectedAmount = '';

  final List<String> _quickAmounts = [
    '5000', '10000', '15000', '20000', '25000', '30000'
  ];

  final List<Map<String, dynamic>> _schools = [
    {
      'id': 'school1',
      'name': 'مدرسة الأندلس الحديثة',
      'type': 'خاصة',
      'icon': Icons.school,
      'color': Color(0xFF45B7D1),
    },
    {
      'id': 'school2',
      'name': 'مدرسة الفرات النموذجية',
      'type': 'أهلية',
      'icon': Icons.account_balance,
      'color': Color(0xFF28A745),
    },
    {
      'id': 'school3',
      'name': 'مدرسة النور الدولية',
      'type': 'دولية',
      'icon': Icons.language,
      'color': Color(0xFF9B59B6),
    },
    {
      'id': 'school4',
      'name': 'مدرسة الزهراء',
      'type': 'حكومية',
      'icon': Icons.business,
      'color': Color(0xFFFF6B35),
    },
  ];

  final List<Map<String, dynamic>> _paymentTypes = [
    {
      'id': 'tuition',
      'name': 'رسوم دراسية',
      'description': 'رسوم الفصل الدراسي',
      'icon': Icons.menu_book,
      'color': Color(0xFF45B7D1),
    },
    {
      'id': 'transport',
      'name': 'رسوم نقل',
      'description': 'أجرة المواصلات',
      'icon': Icons.directions_bus,
      'color': Color(0xFFFF6B35),
    },
    {
      'id': 'activities',
      'name': 'رسوم أنشطة',
      'description': 'الأنشطة اللامنهجية',
      'icon': Icons.sports_soccer,
      'color': Color(0xFF28A745),
    },
    {
      'id': 'uniform',
      'name': 'رسوم زي مدرسي',
      'description': 'الزي الموحد',
      'icon': Icons.checkroom,
      'color': Color(0xFF9B59B6),
    },
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.logScreenEntry('FuturisticSchoolPayment');
    _setupAnimations();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bookController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _bookAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bookController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _sparkleController.repeat(reverse: true);
    _bookController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    _bookController.dispose();
    _studentIdController.dispose();
    _studentNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleQuickAmount(String amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount;
    });
  }

  void _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('يرجى إدخال مبلغ صحيح');
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      _showError('يرجى تسجيل الدخول أولاً');
      return;
    }

    if (user.balance < amount) {
      _showError('الرصيد غير كافي. رصيدك الحالي: ${user.balance.toStringAsFixed(0)} ريال');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // محاكاة عملية دفع رسوم المدرسة
      await Future.delayed(const Duration(seconds: 3));
      
      // خصم المبلغ من الرصيد
      final success = await ref
          .read(authControllerProvider.notifier)
          .deductFromBalance(amount);

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(
          TransactionResultScreen.routeName,
          arguments: {
            'success': true,
            'title': 'تم دفع رسوم المدرسة بنجاح',
            'amount': amount,
            'type': 'school_payment',
            'details': {
              'student_id': _studentIdController.text,
              'student_name': _studentNameController.text,
              'school': _getSchoolName(_selectedSchool),
              'payment_type': _getPaymentTypeName(_selectedType),
            },
          },
        );
      } else {
        _showError('حدث خطأ في عملية الدفع');
      }
    } catch (e) {
      _showError('حدث خطأ: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getSchoolName(String schoolId) {
    final school = _schools.firstWhere(
      (s) => s['id'] == schoolId,
      orElse: () => {'name': 'غير محدد'},
    );
    return school['name'] as String;
  }

  String _getPaymentTypeName(String typeId) {
    final type = _paymentTypes.firstWhere(
      (t) => t['id'] == typeId,
      orElse: () => {'name': 'غير محدد'},
    );
    return type['name'] as String;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserAsyncProvider);
    final isRTL = ref.watch(isRTLProvider);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: currentUserAsync.when(
        data: (user) => _buildMainContent(context, user, isRTL, isTablet),
        loading: () => _buildLoadingScreen(),
        error: (error, _) => _buildErrorScreen(error.toString()),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, user, bool isRTL, bool isTablet) {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Stack(
              children: [
                _buildAnimatedBackground(),
                _buildFloatingBooks(),
                _buildKnowledgeParticles(),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(context, isTablet),
                        _buildCurrentBalance(user, isTablet),
                        _buildPaymentForm(isTablet),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF1A1A3E),
            const Color(0xFF2D1B69),
            const Color(0xFF3E1B60),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: EducationBackgroundPainter(_rotationAnimation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildFloatingBooks() {
    return AnimatedBuilder(
      animation: _bookAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: FloatingBooksPainter(_bookAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildKnowledgeParticles() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: KnowledgeParticlesPainter(_sparkleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: isTablet ? 50 : 44,
              height: isTablet ? 50 : 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF45B7D1).withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: const Color(0xFF45B7D1),
                size: isTablet ? 24 : 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دفع رسوم المدارس',
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'تعليم أفضل لمستقبل أفضل',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.white70,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _bookAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: math.sin(_bookAnimation.value * 2 * math.pi) * 0.1,
                child: Container(
                  width: isTablet ? 50 : 44,
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF45B7D1), Color(0xFF9B59B6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF45B7D1).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school,
                    color: Colors.black,
                    size: isTablet ? 28 : 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBalance(user, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF45B7D1).withOpacity(0.2),
                    const Color(0xFF9B59B6).withOpacity(0.1),
                    const Color(0xFF28A745).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF45B7D1).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF45B7D1).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: const Color(0xFF45B7D1),
                        size: isTablet ? 24 : 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'رصيدك المتاح',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.white70,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${user?.balance?.toStringAsFixed(0) ?? '0'} ريال',
                    style: TextStyle(
                      fontSize: isTablet ? 36 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF45B7D1),
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          color: const Color(0xFF45B7D1).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentForm(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 32 : 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            // School selection
            Text(
              'اختر المدرسة',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            _buildSchoolSelection(isTablet),
            
            const SizedBox(height: 24),
            
            // Student information
            _buildStudentInfo(isTablet),
            
            const SizedBox(height: 24),
            
            // Payment type
            Text(
              'نوع الرسوم',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentTypeSelection(isTablet),
            
            const SizedBox(height: 24),
            
            // Amount selection
            Text(
              'المبلغ المطلوب',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickAmounts(isTablet),
            
            const SizedBox(height: 16),
            _buildAmountInput(isTablet),
            
            const SizedBox(height: 32),
            
            // Payment button
            _buildPaymentButton(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolSelection(bool isTablet) {
    return Column(
      children: _schools.map((school) {
        final isSelected = _selectedSchool == school['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSchool = school['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        (school['color'] as Color).withOpacity(0.2),
                        (school['color'] as Color).withOpacity(0.1),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? school['color'] as Color
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (school['color'] as Color).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 50 : 44,
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    color: (school['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    school['icon'] as IconData,
                    color: school['color'] as Color,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school['name'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        'مدرسة ${school['type']}',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.white70,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: school['color'] as Color,
                    size: isTablet ? 28 : 24,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudentInfo(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'بيانات الطالب',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 16),
        
        // Student ID
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF45B7D1).withOpacity(0.3),
            ),
            color: Colors.white.withOpacity(0.1),
          ),
          child: TextFormField(
            controller: _studentIdController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 18 : 16,
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              hintText: 'رقم الطالب',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'Cairo',
              ),
              prefixIcon: Icon(
                Icons.badge,
                color: const Color(0xFF45B7D1),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال رقم الطالب';
              }
              return null;
            },
          ),
        ),
        
        // Student Name
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF45B7D1).withOpacity(0.3),
            ),
            color: Colors.white.withOpacity(0.1),
          ),
          child: TextFormField(
            controller: _studentNameController,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 18 : 16,
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              hintText: 'اسم الطالب',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'Cairo',
              ),
              prefixIcon: Icon(
                Icons.person,
                color: const Color(0xFF45B7D1),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال اسم الطالب';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeSelection(bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: _paymentTypes.length,
      itemBuilder: (context, index) {
        final type = _paymentTypes[index];
        final isSelected = _selectedType == type['id'];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = type['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        (type['color'] as Color).withOpacity(0.3),
                        (type['color'] as Color).withOpacity(0.1),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? type['color'] as Color
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (type['color'] as Color).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: type['color'] as Color,
                  size: isTablet ? 28 : 24,
                ),
                const SizedBox(height: 8),
                Text(
                  type['name'] as String,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAmounts(bool isTablet) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _quickAmounts.map((amount) {
        final isSelected = _selectedAmount == amount;
        return GestureDetector(
          onTap: () => _handleQuickAmount(amount),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 12 : 10,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF45B7D1), Color(0xFF9B59B6)],
                    )
                  : null,
              color: isSelected ? null : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected 
                    ? Colors.transparent 
                    : const Color(0xFF45B7D1).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF45B7D1).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '$amount ريال',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isSelected ? Colors.black : const Color(0xFF45B7D1),
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountInput(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF45B7D1).withOpacity(0.3),
        ),
        color: Colors.white.withOpacity(0.1),
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 18 : 16,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: 'أو أدخل مبلغ مخصص',
          hintStyle: TextStyle(
            color: Colors.white54,
            fontFamily: 'Cairo',
          ),
          prefixIcon: Icon(
            Icons.monetization_on,
            color: const Color(0xFF45B7D1),
          ),
          suffixText: 'ريال',
          suffixStyle: TextStyle(
            color: Colors.white70,
            fontFamily: 'Cairo',
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال المبلغ';
          }
          final amount = double.tryParse(value);
          if (amount == null) {
            return 'يرجى إدخال رقم صحيح';
          }
          if (amount < 1000) {
            return 'الحد الأدنى 1,000 ريال';
          }
          if (amount > 100000) {
            return 'الحد الأقصى 100,000 ريال';
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            _selectedAmount = value.isEmpty ? '' : value;
          });
        },
      ),
    );
  }

  Widget _buildPaymentButton(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _bookAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (math.sin(_bookAnimation.value * 2 * math.pi) * 0.02),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF45B7D1), Color(0xFF9B59B6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF45B7D1).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: isTablet ? 28 : 24,
                        width: isTablet ? 28 : 24,
                        child: const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.black,
                            size: isTablet ? 24 : 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'دفع الرسوم',
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A3E),
            Color(0xFF2D1B69),
            Color(0xFF3E1B60),
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF45B7D1)),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A3E),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل البيانات',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painters for education effects
class EducationBackgroundPainter extends CustomPainter {
  final double animationValue;

  EducationBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF45B7D1).withOpacity(0.1);

    // Draw education grid patterns
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        final x = (size.width / 10) * i + (animationValue * 20);
        final y = (size.height / 10) * j + (animationValue * 15);
        
        canvas.drawRect(
          Rect.fromLTWH(x, y, 30, 20),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(EducationBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class FloatingBooksPainter extends CustomPainter {
  final double animationValue;

  FloatingBooksPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF9B59B6).withOpacity(0.2);

    // Draw floating book shapes
    for (int i = 0; i < 8; i++) {
      final x = (size.width * math.Random(i).nextDouble()) + 
               (math.sin(animationValue * 2 * math.pi + i) * 30);
      final y = (size.height * math.Random(i + 20).nextDouble()) + 
               (math.cos(animationValue * 2 * math.pi + i) * 25);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 20, 15),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FloatingBooksPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class KnowledgeParticlesPainter extends CustomPainter {
  final double animationValue;

  KnowledgeParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF28A745).withOpacity(0.4);

    // Draw knowledge sparkles
    for (int i = 0; i < 20; i++) {
      final x = (size.width * math.Random(i).nextDouble()) + 
               (math.sin(animationValue * 3 * math.pi + i) * 15);
      final y = (size.height * math.Random(i + 40).nextDouble()) + 
               (math.cos(animationValue * 3 * math.pi + i) * 10);

      canvas.drawCircle(
        Offset(x, y),
        1 + (math.sin(animationValue * 4 * math.pi + i) * 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(KnowledgeParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
