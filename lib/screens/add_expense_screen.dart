import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../utils/database_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  final CustodyModel custody;
  final ExpenseModel? expense; // للتعديل

  const AddExpenseScreen({super.key, required this.custody, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _invoiceNumberController = TextEditingController(); // رقم الفاتورة

  String _selectedCategory = 'أخرى';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'مشتريات',
    'مطاعم',
    'مواصلات',
    'توريدات',
    'صيانة',
    'رواتب',
    'أخرى'
  ];

  @override
  void initState() {
    super.initState();
    // إذا كان في وضع التعديل، قم بملء الحقول
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
      _invoiceNumberController.text = widget.expense!.invoiceNumber ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = ExpenseModel(
        id: widget.expense?.id,
        custodyId: widget.custody.id!,
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        invoiceNumber: _invoiceNumberController.text.isNotEmpty
            ? _invoiceNumberController.text
            : null,
      );

      if (widget.expense == null) {
        await DatabaseHelper.instance.insertExpense(expense);
      } else {
        await DatabaseHelper.instance.updateExpense(expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expense == null
                ? 'تم إضافة المصروف بنجاح'
                : 'تم تعديل المصروف بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.expense == null ? 'إضافة مصروف' : 'تعديل مصروف'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // معلومات العهدة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('معلومات العهدة',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المبلغ المتبقي:'),
                        Text(
                            '${_formatNumber(widget.custody.remainingAmount)} ${widget.custody.currency}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('إجمالي المصروفات:'),
                        Text(
                            '${_formatNumber(widget.custody.totalExpenses)} ${widget.custody.currency}',
                            style: const TextStyle(color: Colors.red)),
                      ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // نموذج المصروف
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                        labelText: 'عنوان المصروف',
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v!.isEmpty ? 'يرجى إدخال عنوان المصروف' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'الوصف (اختياري)',
                        border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'المبلغ',
                      border: const OutlineInputBorder(),
                      suffixText: widget.custody.currency,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'يرجى إدخال المبلغ';
                      if (double.tryParse(v) == null)
                        return 'الرجاء إدخال رقم صحيح';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _invoiceNumberController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الفاتورة',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt),
                      hintText: 'اختياري',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'التصنيف', border: OutlineInputBorder()),
                    value: _selectedCategory,
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('تاريخ المصروف'),
                    subtitle:
                        Text(DateFormat('yyyy/MM/dd').format(_selectedDate)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveExpense,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32)),
                          child: const Text('حفظ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double amount) =>
      NumberFormat('#,##0.00').format(amount);
}
