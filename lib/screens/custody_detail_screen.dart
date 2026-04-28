import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../utils/database_helper.dart';
import 'add_expense_screen.dart';

class CustodyDetailScreen extends StatefulWidget {
  final CustodyModel custody;
  const CustodyDetailScreen({super.key, required this.custody});

  @override
  State<CustodyDetailScreen> createState() => _CustodyDetailScreenState();
}

class _CustodyDetailScreenState extends State<CustodyDetailScreen> {
  late CustodyModel _custody;
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _custody = widget.custody;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _expenses =
        await DatabaseHelper.instance.getExpensesByCustody(_custody.id!);
    setState(() => _isLoading = false);
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _loadData();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم حذف المصروف')));
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = _expenses.fold(0.0, (sum, e) => sum + e.amount);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_custody.title),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)]),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          const Text('المبلغ الأولي',
                              style: TextStyle(color: Colors.white70)),
                          Text(
                              '${_formatNumber(_custody.initialAmount)} ${_custody.currency}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ]),
                        Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.3)),
                        Column(children: [
                          const Text('إجمالي المصاريف',
                              style: TextStyle(color: Colors.white70)),
                          Text(
                              '${_formatNumber(totalExpenses)} ${_custody.currency}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ]),
                        Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.3)),
                        Column(children: [
                          const Text('المبلغ المتبقي',
                              style: TextStyle(color: Colors.white70)),
                          Text(
                              '${_formatNumber(_custody.initialAmount - totalExpenses)} ${_custody.currency}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ]),
                      ]),
                ),
                Expanded(
                  child: _expenses.isEmpty
                      ? Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Icon(Icons.receipt,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('لا توجد مصاريف',
                                  style: TextStyle(color: Colors.grey[600]))
                            ]))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _expenses.length,
                          itemBuilder: (context, index) {
                            final expense = _expenses[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Colors.grey.withValues(alpha: 0.1),
                                        blurRadius: 8)
                                  ]),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddExpenseScreen(
                                                      custody: _custody,
                                                      expense: expense)))
                                      .then((_) => _loadData()),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                                color: Colors.red
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: const Icon(Icons.receipt,
                                                color: Colors.red)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(expense.title,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              if (expense.invoiceNumber != null)
                                                Text(
                                                    'فاتورة رقم: ${expense.invoiceNumber}',
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 11)),
                                              Text(expense.description,
                                                  style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 11),
                                                  maxLines: 1),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                                '${_formatNumber(expense.amount)} ${_custody.currency}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red)),
                                            Text(
                                                DateFormat('yyyy/MM/dd')
                                                    .format(expense.date),
                                                style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 11)),
                                            IconButton(
                                                icon: const Icon(Icons.delete,
                                                    size: 18,
                                                    color: Colors.red),
                                                onPressed: () => _deleteExpense(
                                                    expense.id!)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatNumber(double amount) =>
      NumberFormat('#,##0.00').format(amount);
}
