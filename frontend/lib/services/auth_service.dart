import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isAuthenticated = false;
  String? _token;
  String? _userEmail;
  String? _userName;
  ThemeMode _themeMode = ThemeMode.light;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> loadAuthState() async {
    try {
      _token = await _storage.read(key: 'token');
      _userEmail = await _storage.read(key: 'email');
      _userName = await _storage.read(key: 'name');
      _isAuthenticated = _token != null && _token!.isNotEmpty;
      
      debugPrint('🔐 Auth state loaded: isAuthenticated=$_isAuthenticated');
      if (_token != null) {
        debugPrint('🔑 Token found: ${_token!.substring(0, math.min(30, _token!.length))}...');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading auth state: $e');
      _isAuthenticated = false;
      _token = null;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    try {
      debugPrint('📝 Registering user: $email');
      
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'full_name': fullName.trim()
        }),
      );
      
      debugPrint('📥 Register response: ${response.statusCode}');
      debugPrint('📥 Register body: ${response.body}');
      
      if (response.statusCode == 201) {
        debugPrint('✅ User registered successfully');
        return true;
      } else {
        debugPrint('❌ Register failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Register exception: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      debugPrint('🔐 Logging in: $email');
      
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password
        }),
      );
      
      debugPrint('📥 Login response status: ${response.statusCode}');
      debugPrint('📥 Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        _token = data['access_token'];
        _userEmail = data['user']['email'];
        _userName = data['user']['full_name'];
        
        // Sauvegarder dans le stockage sécurisé
        await _storage.write(key: 'token', value: _token);
        await _storage.write(key: 'email', value: _userEmail);
        await _storage.write(key: 'name', value: _userName);
        
        // Vérifier que le token a bien été sauvegardé
        final savedToken = await _storage.read(key: 'token');
        debugPrint('💾 Token saved: ${savedToken != null}');
        
        _isAuthenticated = true;
        notifyListeners();
        
        debugPrint('✅ Login successful for: $_userEmail');
        return true;
      } else {
        debugPrint('❌ Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Login exception: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      debugPrint('🚪 Logging out user: $_userEmail');
      
      await _storage.deleteAll();
      
      _token = null;
      _userEmail = null;
      _userName = null;
      _isAuthenticated = false;
      
      notifyListeners();
      
      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
    }
  }

  Future<String?> getValidToken() async {
    if (_token != null && _token!.isNotEmpty) {
      return _token;
    }
    
    // Essayer de récupérer depuis le stockage
    final storedToken = await _storage.read(key: 'token');
    if (storedToken != null && storedToken.isNotEmpty) {
      _token = storedToken;
      _isAuthenticated = true;
      notifyListeners();
      return storedToken;
    }
    
    return null;
  }
}