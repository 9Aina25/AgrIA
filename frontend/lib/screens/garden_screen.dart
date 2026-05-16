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
                    // Carte de bienvenue avec illustration
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Color(0xFF1aab57)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(Icons.forest, size: 32, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bonjour, $userName !',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Voici l\'état de votre jardin',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Score de santé
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.health_and_safety, color: Colors.green, size: 28),
                                const SizedBox(width: 8),
                                const Text(
                                  'Score de santé',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _score >= 80 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _score >= 80 ? 'Excellent' : 'À améliorer',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _score >= 80 ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$_score/100',
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _score / 100,
                                backgroundColor: Colors.grey.shade200,
                                color: Colors.green,
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistiques
                    Row(
                      children: [
                        _buildStatCard(Icons.camera_alt, 'Scans', _totalScans, Colors.blue),
                        const SizedBox(width: 12),
                        _buildStatCard(Icons.check_circle, 'Saines', _healthyCount, Colors.green),
                        const SizedBox(width: 12),
                        _buildStatCard(Icons.warning_amber_rounded, 'Malades', _sickCount, Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Top plantes
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Vos plantes les plus scannées',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_topPlants.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('Aucune donnée', style: TextStyle(color: Colors.grey)),
                                ),
                              )
                            else
                              ..._topPlants.asMap().entries.map((entry) {
                                final index = entry.key;
                                final plant = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: index == 0 ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: index == 0 ? Colors.amber : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(_getPlantIcon(plant['_id']), size: 24, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _getPlantName(plant['_id']),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Text(
                                        '${plant['count']} scans',
                                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3), 
    );
  }

  Widget _buildStatCard(IconData icon, String label, int value, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlantIcon(String className) {
    if (className.contains('Tomato')) return Icons.blur_circular;
    if (className.contains('Strawberry')) return Icons.star;
    if (className.contains('Potato')) return Icons.circle;
    if (className.contains('Grape')) return Icons.circle_outlined;
    if (className.contains('Apple')) return Icons.favorite;
    return Icons.eco;
  }

  String _getPlantName(String className) {
    if (className.contains('Tomato')) return 'Tomate';
    if (className.contains('Strawberry')) return 'Fraisier';
    if (className.contains('Potato')) return 'Pomme de terre';
    if (className.contains('Grape')) return 'Raisin';
    if (className.contains('Apple')) return 'Pommier';
    return className.split('___')[0];
  }
}