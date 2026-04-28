import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../utils/database_helper.dart';
import '../utils/pdf_report.dart';
import 'add_expense_screen.dart';
import 'custody_detail_screen.dart';

class CustodyScreen extends StatefulWidget {
  const CustodyScreen({super.key});

  @override
  State<CustodyScreen> createState() => _CustodyScreenState();
}

class _CustodyScreenState extends State<CustodyScreen> {
  List<CustodyModel> _custodies = [];
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _custodies = await DatabaseHelper.instance.getAllCustodies();
    for (var i = 0; i < _custodies.length; i++) {
      var expenses =
          await DatabaseHelper.instance.getExpensesByCustody(_custodies[i].id!);
      if (_startDate != null && _endDate != null) {
        expenses = expenses
            .where((e) =>
                e.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                e.date.isBefore(_endDate!.add(const Duration(days: 1))))
            .toList();
      }
      _custodies[i].expenses = expenses;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _exportCustodyReport(CustodyModel custody) async {
    final file = await PdfReport.generateCustodyReport(
        custody, custody.expenses, _startDate, _endDate);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('مشاركة التقرير'),
              onTap: () async {
                Navigator.pop(context);
                await PdfReport.shareReport(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('حفظ في الجهاز'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('تم حفظ التقرير في مجلد التنزيلات')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('فتح التقرير'),
              onTap: () async {
                Navigator.pop(context);
                await OpenFile.open(file.path);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    DateTime? startDate = _startDate;
    DateTime? endDate = _endDate;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('تصفية المصروفات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('من تاريخ'),
                subtitle: startDate != null
                    ? Text(DateFormat('yyyy/MM/dd').format(startDate))
                    : const Text('اختر التاريخ'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setStateDialog(() => startDate = date);
                },
              ),
              ListTile(
                title: const Text('إلى تاريخ'),
                subtitle: endDate != null
                    ? Text(DateFormat('yyyy/MM/dd').format(endDate))
                    : const Text('اختر التاريخ'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setStateDialog(() => endDate = date);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => setStateDialog(() {
                startDate = null;
                endDate = null;
              }),
              child: const Text('مسح'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _startDate = startDate;
                  _endDate = endDate;
                });
                Navigator.pop(context);
                _loadData();
              },
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('العهد'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _custodies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('لا توجد عهدة مسجلة',
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showAddCustodyDialog(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32)),
                        child: const Text('إضافة عهدة جديدة'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _custodies.length,
                  itemBuilder: (context, index) =>
                      _buildCustodyCard(_custodies[index]),
                ),
    );
  }

  Widget _buildCustodyCard(CustodyModel custody) {
    final percentage = (custody.totalExpenses / custody.initialAmount) * 100;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 12)
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                          child: Text(_getCurrencySymbol(custody.currency),
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32)))),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(custody.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(
                              custody.description.isNotEmpty
                                  ? custody.description
                                  : 'لا يوجد وصف',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('تعديل')
                            ])),
                        const PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('حذف', style: TextStyle(color: Colors.red))
                            ])),
                      ],
                      onSelected: (value) async {
                        if (value == 'delete') {
                          await DatabaseHelper.instance
                              .deleteCustody(custody.id!);
                          _loadData();
                        } else if (value == 'edit') {
                          _editCustody(custody);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                      minHeight: 8),
                ),
                const SizedBox(height: 12),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('نسبة الصرف: ${percentage.toStringAsFixed(1)}%',
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 12)),
                      Text(
                          'المتبقي: ${_formatNumber(custody.remainingAmount)} ${custody.currency}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 12)),
                    ]),
                const Divider(height: 24),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          'المبلغ الأولي',
                          '${_formatNumber(custody.initialAmount)} ${custody.currency}',
                          Icons.account_balance),
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      _buildStatItem(
                          'إجمالي المصاريف',
                          '${_formatNumber(custody.totalExpenses)} ${custody.currency}',
                          Icons.receipt,
                          textColor: Colors.red),
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      _buildStatItem(
                          'عدد المصاريف',
                          '${custody.expenses.length}',
                          Icons.format_list_numbered),
                    ]),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddExpenseScreen(custody: custody)))
                        .then((_) => _loadData()),
                    icon: const Icon(Icons.add_circle_outline,
                        size: 20, color: Color(0xFF2E7D32)),
                    label: const Text('إضافة مصروف'),
                  ),
                ),
                Container(height: 30, width: 1, color: Colors.grey[300]),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CustodyDetailScreen(custody: custody))),
                    icon: const Icon(Icons.list_alt,
                        size: 20, color: Color(0xFF2E7D32)),
                    label: const Text('التفاصيل'),
                  ),
                ),
                Container(height: 30, width: 1, color: Colors.grey[300]),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _exportCustodyReport(custody),
                    icon: const Icon(Icons.picture_as_pdf,
                        size: 20, color: Color(0xFF2E7D32)),
                    label: const Text('تقرير PDF'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {Color? textColor}) {
    return Column(children: [
      Icon(icon, size: 20, color: Colors.grey[600]),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
      Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
    ]);
  }

  void _editCustody(CustodyModel custody) {
    final titleController = TextEditingController(text: custody.title);
    final descriptionController =
        TextEditingController(text: custody.description);
    final amountController =
        TextEditingController(text: custody.initialAmount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل العهدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'اسم العهدة')),
            const SizedBox(height: 12),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 2),
            const SizedBox(height: 12),
            TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'المبلغ الأولي'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final updated = CustodyModel(
                id: custody.id,
                title: titleController.text,
                description: descriptionController.text,
                initialAmount: double.parse(amountController.text),
                currentAmount: custody.currentAmount,
                currency: custody.currency,
                createdAt: custody.createdAt,
              );
              await DatabaseHelper.instance.updateCustody(updated);
              Navigator.pop(context);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تعديل العهدة بنجاح')));
            },
            child: const Text('حفظ'),
          ),
        ],
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'اسم العهدة')),
            const SizedBox(height: 12),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 2),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: amountController,
                      decoration:
                          const InputDecoration(labelText: 'المبلغ الأولي'),
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
                child: DropdownButton<String>(
                  value: selectedCurrency,
                  items: currencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => selectedCurrency = v!,
                  underline: const SizedBox(),
                ),
              ),
            ]),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
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
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double amount) =>
      NumberFormat('#,##0.00').format(amount);
  String _getCurrencySymbol(String currency) => '﷼';
}
