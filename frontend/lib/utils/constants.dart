import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  // Pour Android (appareil physique) : utilisez l'IP de votre PC
  // Pour trouver votre IP : ipconfig (cherchez IPv4)
  // static const String apiBaseUrl = 'http://192.168.0.20:8000/api';
  // static const String apiBaseUrl = 'http://localhost:8000/api';
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';

  
  static const String defaultLanguage = 'fr';
  
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? defaultLanguage;
  }
  
  static Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }
}