import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ApiService extends ChangeNotifier {
  Future<Map<String, dynamic>> diagnose(Uint8List imageBytes, String token, String filename) async {
    try {
      debugPrint('📤 Envoi diagnostic...');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiBaseUrl}/diagnose'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
      ));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      debugPrint('📥 Statut: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else if (response.statusCode == 401) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Erreur diagnose: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchMaladies() async {
    try {
      final response = await http.get(Uri.parse('${Constants.apiBaseUrl}/maladies'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Erreur fetchMaladies: $e');
      return [];
    }
  }
}