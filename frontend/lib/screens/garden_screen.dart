import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  int _totalScans = 0;
  int _healthyCount = 0;
  int _sickCount = 0;
  int _score = 0;
  List<dynamic> _topPlants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }
    
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/user/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalScans = data['scans'] ?? 0;
          _healthyCount = data['healthy'] ?? 0;
          _sickCount = data['sick'] ?? 0;
          _score = data['score'] ?? 100;
          _topPlants = data['top_plants'] ?? [];
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final userName = auth.userName?.split(' ').first ?? 'Agriculteur';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Jardin'),
        backgroundColor: AppTheme.greenPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Carte de bienvenue
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.greenPale,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(Icons.agriculture, size: 28, color: AppTheme.greenPrimary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bonjour, $userName !', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const Text('Voici votre résumé', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Carte Score de santé
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text('🌿 Score de santé', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('$_score/100', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.greenPrimary)),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 10,
                              child: LinearProgressIndicator(
                                value: _score / 100,
                                backgroundColor: Colors.grey.shade200,
                                color: AppTheme.greenPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_score >= 80 ? '🌟 Excellent ! Continuez ainsi' : '📈 Continuez à prendre soin de vos plantes',
                                style: TextStyle(color: _score >= 80 ? Colors.green : Colors.orange)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistiques rapides
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('$_totalScans', 'Scans', Icons.camera_alt, Colors.blue)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('$_healthyCount', 'Saines', Icons.health_and_safety, Colors.green)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('$_sickCount', 'Malades', Icons.warning_amber, Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Top plantes
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🏆 Vos plantes les plus scannées', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            if (_topPlants.isEmpty)
                              const Text('Aucune donnée', style: TextStyle(color: Colors.grey))
                            else
                              ..._topPlants.map((plant) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Text(_getPlantEmoji(plant['_id']), style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_getPlantName(plant['_id']), style: const TextStyle(fontSize: 14))),
                                    Text('${plant['count']} scans', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 5),
    );
  }

  String _getPlantEmoji(String className) {
    if (className.contains('Tomato')) return '🍅';
    if (className.contains('Strawberry')) return '🍓';
    if (className.contains('Potato')) return '🥔';
    if (className.contains('Grape')) return '🍇';
    if (className.contains('Apple')) return '🍎';
    return '🌿';
  }

  String _getPlantName(String className) {
    if (className.contains('Tomato')) return 'Tomate';
    if (className.contains('Strawberry')) return 'Fraisier';
    if (className.contains('Potato')) return 'Pomme de terre';
    if (className.contains('Grape')) return 'Raisin';
    if (className.contains('Apple')) return 'Pommier';
    return className.split('___')[0];
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}