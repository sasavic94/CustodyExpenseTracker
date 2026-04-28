import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/custody_model.dart';
import '../utils/database_helper.dart';
import 'custody_screen.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CustodyModel> _custodies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _custodies = await DatabaseHelper.instance.getAllCustodies();
    // تحميل المصاريف لكل عهدة
    for (var i = 0; i < _custodies.length; i++) {
      final expenses =
          await DatabaseHelper.instance.getExpensesByCustody(_custodies[i].id!);
      _custodies[i].expenses = expenses;
    }
    setState(() => _isLoading = false);
  }

  double get _totalCustodies =>
      _custodies.fold(0, (sum, c) => sum + c.initialAmount);
  double get _totalExpenses =>
      _custodies.fold(0, (sum, c) => sum + c.totalExpenses);
  double get _currentBalance => _totalCustodies - _totalExpenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'نظام العهدة والمصاريف',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showDeveloperInfo(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بطاقة الملخص
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    // مخطط الإحصائيات
                    _buildStatsChart(),
                    const SizedBox(height: 24),
                    // قائمة العهد
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'العهد النشطة',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CustodyScreen()),
                            ).then((_) => _loadData());
                          },
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('عرض الكل'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._custodies
                        .take(3)
                        .map((custody) => _buildCustodyCard(custody)),
                    if (_custodies.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            Icon(Icons.account_balance_wallet,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد عهد',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _showAddCustodyDialog(),
                              child: const Text('إضافة عهدة جديدة'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustodyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'إجمالي العهد',
                  _formatCurrency(_totalCustodies),
                  Icons.account_balance_wallet,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  'إجمالي المصاريف',
                  _formatCurrency(_totalExpenses),
                  Icons.receipt_long,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  'الرصيد الحالي',
                  _formatCurrency(_currentBalance),
                  Icons.money,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _totalCustodies > 0 ? _totalExpenses / _totalCustodies : 0,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Text(
              'نسبة الصرف: ${((_totalExpenses / _totalCustodies) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildStatsChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تحليل المصاريف',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: _custodies.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد بيانات كافية للعرض',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _totalExpenses,
                      barGroups: _custodies.take(5).map((custody) {
                        return BarChartGroupData(
                          x: custody.id ?? 0,
                          barRods: [
                            BarChartRodData(
                              toY: custody.totalExpenses,
                              color: Colors.green,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < _custodies.length) {
                                return Text(
                                  _custodies[index].title.length > 8
                                      ? '${_custodies[index].title.substring(0, 6)}...'
                                      : _custodies[index].title,
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustodyCard(CustodyModel custody) {
    final percentage = (custody.totalExpenses / custody.initialAmount) * 100;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddExpenseScreen(custody: custody),
              ),
            ).then((_) => _loadData());
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _getCurrencySymbol(custody.currency),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            custody.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'المتبقي: ${_formatCurrency(custody.remainingAmount)} ${custody.currency}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(custody.totalExpenses),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'من ${_formatCurrency(custody.initialAmount)}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'نسبة الصرف: ${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                    Text(
                      '${custody.expenses.length} مصروف',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCustodyDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCurrency = 'ر.س';
    final currencies = ['ر.س', 'د.إ', 'د.ك', 'ر.ق', 'ب.د', 'ر.ع', 'ج.م'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عهدة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'اسم العهدة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'المبلغ الأولي',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCurrency,
                      items: currencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) selectedCurrency = value;
                      },
                      underline: const SizedBox(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                final custody = CustodyModel(
                  title: titleController.text,
                  description: descriptionController.text,
                  initialAmount: double.parse(amountController.text),
                  currentAmount: double.parse(amountController.text),
                  currency: selectedCurrency,
                  createdAt: DateTime.now(),
                );
                await DatabaseHelper.instance.insertCustody(custody);
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.developer_mode, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            const Text('معلومات المطور'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF2E7D32),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'م/ مصطفى شهاب يوسف',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFF2E7D32)),
              title: const Text('رقم الجوال'),
              subtitle: const Text('+201015942681'),
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF2E7D32)),
              title: const Text('البريد الإلكتروني'),
              subtitle: const Text('mostafashehab1228@gmail.com'),
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يمكنك التواصل مع المطور لأي استفسارات أو دعم فني',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'ر.س':
        return '﷼';
      case 'د.إ':
        return 'د.إ';
      case 'د.ك':
        return 'د.ك';
      case 'ر.ق':
        return 'ر.ق';
      case 'ب.د':
        return 'ب.د';
      case 'ر.ع':
        return 'ر.ع';
      case 'ج.م':
        return 'ج.م';
      default:
        return '﷼';
    }
  }
}
