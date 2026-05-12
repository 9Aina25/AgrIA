import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/historique'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _history = json.decode(response.body);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Erreur chargement historique: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteHistory(String entryId) async {
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;
    try {
      final response = await http.delete(
        Uri.parse('${Constants.apiBaseUrl}/historique/$entryId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _loadHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan supprimé'), backgroundColor: AppTheme.greenPrimary),
        );
      }
    } catch (e) {
      debugPrint('Erreur suppression: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des Scans')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: AppTheme.textLight),
                      SizedBox(height: 16),
                      Text('Aucun historique', style: TextStyle(color: AppTheme.textLight)),
                      SizedBox(height: 8),
                      Text('Scannez une plante pour voir vos résultats ici', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final h = _history[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📅 ${h['date'] ?? 'Date inconnue'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                          const SizedBox(height: 8),
                          Text('🌿 ${h['maladie_nom'] ?? h['predictedClass'] ?? 'Maladie inconnue'}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                          const SizedBox(height: 4),
                          if (h['confidence'] != null)
                            Text('Confiance: ${h['confidence']}%', style: const TextStyle(fontSize: 13, color: AppTheme.textMid)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _showDetail(h),
                                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                                  child: const Text('Voir détails'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _deleteHistory(h['_id']),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.redAction),
                                  child: const Text('🗑 Supprimer'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
    );
  }

  void _showDetail(Map<String, dynamic> h) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Détails du scan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Maladie: ${h['maladie_nom'] ?? h['predictedClass']}'),
            if (h['confidence'] != null) Text('Confiance: ${h['confidence']}%'),
            Text('Date: ${h['date'] ?? 'Inconnue'}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }
}