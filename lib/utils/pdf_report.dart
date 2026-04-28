import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense_model.dart';

class PdfReport {
  static Future<File> generateCustodyReport(
    CustodyModel custody,
    List<ExpenseModel> expenses,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final pdf = pw.Document();

    final currency = custody.currency;
    final totalAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final remainingAmount = custody.initialAmount - totalAmount;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'تقرير العهدة والمصاريف',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Custody & Expenses Report',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),
              ],
            ),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('معلومات العهدة',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  pw.Expanded(child: pw.Text('اسم العهدة: ${custody.title}')),
                  pw.Expanded(child: pw.Text('العملة: $currency')),
                ]),
                pw.SizedBox(height: 5),
                pw.Row(children: [
                  pw.Expanded(
                      child: pw.Text(
                          'المبلغ الأولي: ${_formatNumber(custody.initialAmount)} $currency')),
                  pw.Expanded(
                      child: pw.Text(
                          'المبلغ المتبقي: ${_formatNumber(remainingAmount)} $currency')),
                ]),
                pw.SizedBox(height: 5),
                pw.Row(children: [
                  pw.Expanded(
                      child: pw.Text(
                          'إجمالي المصروفات: ${_formatNumber(totalAmount)} $currency')),
                  pw.Expanded(
                      child: pw.Text('عدد المصروفات: ${expenses.length}')),
                ]),
                if (startDate != null && endDate != null)
                  pw.Text(
                      'الفترة: ${DateFormat('yyyy/MM/dd').format(startDate)} - ${DateFormat('yyyy/MM/dd').format(endDate)}'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('تفاصيل المصروفات',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildHeaderCell('التاريخ'),
                  _buildHeaderCell('رقم الفاتورة'),
                  _buildHeaderCell('الوصف'),
                  _buildHeaderCell('التصنيف'),
                  _buildHeaderCell('المبلغ'),
                ],
              ),
              ...expenses.map((exp) => pw.TableRow(children: [
                    _buildCell(DateFormat('yyyy/MM/dd').format(exp.date)),
                    _buildCell(exp.invoiceNumber ?? '-'),
                    _buildCell(exp.title),
                    _buildCell(exp.category),
                    _buildCell('${_formatNumber(exp.amount)} $currency',
                        bold: true),
                  ])),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('مطور التطبيق: مصطفى شهاب يوسف'),
                pw.Text('للتواصل: +201015942681'),
                pw.Text('البريد الإلكتروني: mostafashehab1228@gmail.com'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              'تم إنشاء هذا التقرير بواسطة نظام العهدة والمصاريف',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
              'الصفحة ${context.pageNumber} من ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 10)),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName =
        'custody_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _buildCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(text,
          style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
    );
  }

  static String _formatNumber(double number) {
    return NumberFormat('#,##0.00').format(number);
  }

  static Future<void> shareReport(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'تقرير العهدة والمصاريف');
  }
}
