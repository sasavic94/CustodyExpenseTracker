import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/language_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'ar';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language_code') ?? 'ar';
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // قسم اللغة
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'اللغة / Language',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                RadioListTile(
                  title: const Text('العربية'),
                  subtitle: const Text('Arabic'),
                  value: 'ar',
                  groupValue: _selectedLanguage,
                  onChanged: (value) async {
                    setState(() => _selectedLanguage = value as String);
                    await languageProvider.setLanguage('ar');
                  },
                ),
                RadioListTile(
                  title: const Text('English'),
                  subtitle: const Text('الإنجليزية'),
                  value: 'en',
                  groupValue: _selectedLanguage,
                  onChanged: (value) async {
                    setState(() => _selectedLanguage = value as String);
                    await languageProvider.setLanguage('en');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // معلومات المطور
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'معلومات المطور',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('مصطفى شهاب يوسف'),
                  subtitle: const Text('المطور'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('+201015942681'),
                  subtitle: const Text('رقم الجوال'),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {},
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('mostafashehab1228@gmail.com'),
                  subtitle: const Text('البريد الإلكتروني'),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // معلومات التطبيق
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'عن التطبيق',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  title: Text('نظام العهدة والمصاريف'),
                  subtitle: Text('الإصدار 2.0.0'),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'تطبيق متكامل لإدارة العهد والمصاريف مع إمكانية تصدير التقارير',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
