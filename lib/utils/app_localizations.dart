import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    // هنا يمكن تحميل ملفات JSON للغات
    _localizedStrings = locale.languageCode == 'ar' ? _arStrings : _enStrings;
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  static const Map<String, String> _arStrings = {
    'app_name': 'نظام العهدة والمصاريف',
    'custody': 'العهدة',
    'expenses': 'المصاريف',
    'total_custodies': 'إجمالي العهد',
    'total_expenses': 'إجمالي المصاريف',
    'current_balance': 'الرصيد الحالي',
    'add_custody': 'إضافة عهدة',
    'add_expense': 'إضافة مصروف',
    'edit': 'تعديل',
    'delete': 'حذف',
    'invoice_number': 'رقم الفاتورة',
    'report': 'تقرير',
    'filter': 'تصفية',
    'search': 'بحث',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'settings': 'الإعدادات',
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'English',
  };

  static const Map<String, String> _enStrings = {
    'app_name': 'Custody & Expenses System',
    'custody': 'Custody',
    'expenses': 'Expenses',
    'total_custodies': 'Total Custodies',
    'total_expenses': 'Total Expenses',
    'current_balance': 'Current Balance',
    'add_custody': 'Add Custody',
    'add_expense': 'Add Expense',
    'edit': 'Edit',
    'delete': 'Delete',
    'invoice_number': 'Invoice Number',
    'report': 'Report',
    'filter': 'Filter',
    'search': 'Search',
    'save': 'Save',
    'cancel': 'Cancel',
    'settings': 'Settings',
    'language': 'Language',
    'arabic': 'Arabic',
    'english': 'English',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
