import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../models/card_model.dart';
import '../../providers/firestore_provider.dart';

class CardsManagementScreen extends ConsumerStatefulWidget {
  static const String routeName = '/admin/cards';
  
  const CardsManagementScreen({super.key});

  @override
  ConsumerState<CardsManagementScreen> createState() => _CardsManagementScreenState();
}

class _CardsManagementScreenState extends ConsumerState<CardsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة الكروت',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Cairo'),
          tabs: const [
            Tab(text: 'إضافة كروت'),
            Tab(text: 'عرض الكروت'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AddCardsTab(),
          _ViewCardsTab(),
        ],
      ),
    );
  }
}

class _AddCardsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddCardsTab> createState() => _AddCardsTabState();
}

class _AddCardsTabState extends ConsumerState<_AddCardsTab> {
  final _formKey = GlobalKey<FormState>();
  final _cardsController = TextEditingController();
  String? selectedNetwork;
  int? selectedValue;
  bool isLoading = false;

  @override
  void dispose() {
    _cardsController.dispose();
    super.dispose();
  }

  void _handleAddCards() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedNetwork == null || selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار الشبكة والفئة'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final cardsText = _cardsController.text.trim();
      final lines = cardsText.split('\n');
      final cards = <CardModel>[];

      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        
        final parts = line.trim().split(',');
        if (parts.length != 2) {
          throw Exception('تنسيق خاطئ في السطر: $line\nيجب أن يكون التنسيق: كود_الكرت,الرقم_التسلسلي');
        }

        final code = parts[0].trim();
        final serial = parts[1].trim();

        cards.add(CardModel(
          id: '',
          network: selectedNetwork!,
          value: selectedValue!,
          code: code,
          serial: serial,
          createdAt: DateTime.now(),
        ));
      }

      if (cards.isEmpty) {
        throw Exception('لا توجد كروت صالحة للإضافة');
      }

      final service = ref.read(firestoreServiceProvider);
      await service.addCards(cards);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة ${cards.length} كرت بنجاح'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        
        _cardsController.clear();
        setState(() {
          selectedNetwork = null;
          selectedValue = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تعليمات إضافة الكروت:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• ضع كل كرت في سطر منفصل\n• استخدم الفاصلة للفصل بين كود الكرت والرقم التسلسلي\n• مثال: 1234567890,ABC123',
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Network Selection
            const Text(
              'الشبكة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 8),
            
            DropdownButtonFormField<String>(
              value: selectedNetwork,
              decoration: InputDecoration(
                hintText: 'اختر الشبكة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: AppConstants.networkTypes.map((network) {
                return DropdownMenuItem<String>(
                  value: network['id'],
                  child: Text(
                    network['name'],
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedNetwork = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'يرجى اختيار الشبكة';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Value Selection
            const Text(
              'فئة الكرت',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 8),
            
            DropdownButtonFormField<int>(
              value: selectedValue,
              decoration: InputDecoration(
                hintText: 'اختر الفئة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: AppConstants.cardValues.map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    '$value ريال',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'يرجى اختيار الفئة';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Cards Input
            const Text(
              'بيانات الكروت',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _cardsController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'مثال:\n1234567890,ABC123\n0987654321,DEF456',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال بيانات الكروت';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleAddCards,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        'إضافة الكروت',
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
      ),
    );
  }
}

class _ViewCardsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardStatsAsync = ref.watch(cardStatisticsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات الكروت',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
          
          const SizedBox(height: 16),
          
          cardStatsAsync.when(
            data: (stats) => Column(
              children: [
                // Overall Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'إجمالي الكروت',
                        value: stats['total'].toString(),
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'متاحة',
                        value: stats['available'].toString(),
                        color: AppConstants.successColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'مباعة',
                        value: stats['sold'].toString(),
                        color: AppConstants.warningColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'نسبة المبيعات',
                        value: '${((stats['sold'] / stats['total']) * 100).toStringAsFixed(1)}%',
                        color: AppConstants.accentColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // By Network
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'حسب الشبكة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                ...((stats['byNetwork'] as Map<String, dynamic>).entries.map((entry) {
                  final networkData = AppConstants.networkTypes
                      .firstWhere((n) => n['id'] == entry.key, orElse: () => {
                    'name': entry.key,
                    'color': AppConstants.textSecondary,
                  });
                  
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          networkData['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: networkData['color'],
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
                
                const SizedBox(height: 24),
                
                // By Value
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'حسب الفئة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                ...((stats['byValue'] as Map<String, dynamic>).entries.map((entry) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${entry.key} ريال',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
              child: Text(
                'خطأ في تحميل الإحصائيات',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondary,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
