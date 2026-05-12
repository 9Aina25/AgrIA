import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  bool _isScanning = false;
  bool _showResult = false;
  Map<String, dynamic>? _diagnosisResult;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _showResult = false;
        _diagnosisResult = null;
      });
    }
  }

  Future<void> _startScan() async {
    if (_imageBytes == null) return;
    
    // Récupérer le token directement depuis le service
    final auth = Provider.of<AuthService>(context, listen: false);
    
    // Forcer le rechargement du token depuis le stockage
    await auth.loadAuthState();
    final token = auth.token;
    
    debugPrint('🔑 Token au moment du scan: ${token != null ? "Présent" : "NULL"}');
    
    if (token == null || token.isEmpty) {
      debugPrint('❌ Token manquant, redirection vers login');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expirée, veuillez vous reconnecter'), backgroundColor: AppTheme.redAction),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      return;
    }
    
    setState(() {
      _isScanning = true;
      _showResult = false;
    });

    try {
      debugPrint('📤 Envoi de la requête à ${Constants.apiBaseUrl}/diagnose');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiBaseUrl}/diagnose'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        _imageBytes!,
        filename: 'image.jpg',
      ));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      debugPrint('📥 Statut: ${response.statusCode}');
      debugPrint('📥 Corps: $responseBody');
      
      if (response.statusCode == 200) {
        final result = json.decode(responseBody);
        setState(() {
          _diagnosisResult = result;
          _showResult = true;
          _isScanning = false;
        });
        debugPrint('✅ Diagnostic réussi: ${result['predictedClass']}');
      } else if (response.statusCode == 401) {
        debugPrint('❌ Token invalide ou expiré');
        await auth.logout();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expirée, veuillez vous reconnecter'), backgroundColor: AppTheme.redAction),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } else {
        throw Exception('Erreur: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.redAction),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le reste du build reste identique...
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 350,
              decoration: BoxDecoration(
                color: const Color(0xFF1a2e1a),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Center(
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity, height: 350)
                        : const Text('🌿', style: TextStyle(fontSize: 80, color: Colors.white30)),
                  ),
                  if (_isScanning)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.greenPrimary, width: 2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppTheme.greenPrimary),
                            SizedBox(height: 10),
                            Text('Analyse en cours...', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Pointez vers la plante', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _isScanning || _imageBytes == null ? null : _startScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greenPrimary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('🌿 Scanner avec IA'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.greenPrimary,
                      side: const BorderSide(color: AppTheme.greenPrimary),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('📁 Importer une image'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_showResult && _diagnosisResult != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Résultat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (_diagnosisResult?['details']?['gravite'] == 'élevée') ? AppTheme.redLight : AppTheme.greenLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _diagnosisResult?['details']?['gravite'] == 'élevée' ? 'Urgent' : 'Modéré',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _diagnosisResult?['details']?['gravite'] == 'élevée' ? AppTheme.redAction : AppTheme.greenDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.greenPale, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Maladie identifiée', style: TextStyle(fontSize: 13, color: AppTheme.textLight)),
                          Text(_diagnosisResult?['details']?['nom'] ?? _diagnosisResult?['predictedClass'] ?? 'Inconnu', 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('Confiance: ${_diagnosisResult?['confidence']}%', 
                            style: const TextStyle(fontSize: 13, color: AppTheme.greenPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}