import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _currentLang = 'fr';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLang = prefs.getString('language') ?? 'fr';
    });
  }

  Future<void> _changeLanguage(String lang) async {
    await Constants.setLanguage(lang);
    setState(() => _currentLang = lang);
    
    // Recharger complètement l'application
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.white),
      onSelected: _changeLanguage,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'fr',
          child: Row(
            children: [
              Icon(Icons.flag, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text('Français'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              Icon(Icons.flag, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('English'),
            ],
          ),
        ),
      ],
    );
  }
}