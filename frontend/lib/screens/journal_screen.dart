import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) {
      setState(() {
        _loading = false;
        _error = 'Non authentifié';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/journal'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _entries = data.cast<Map<String, dynamic>>();
          _loading = false;
          _error = '';
        });
      } else if (response.statusCode == 404) {
        // Endpoint pas encore créé
        setState(() {
          _entries = [];
          _loading = false;
          _error = '';
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Erreur de chargement';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '';
        _entries = [];  // Afficher liste vide au lieu d'une erreur
      });
    }
  }

  Future<void> _addEntry() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouvelle note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Contenu'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = Provider.of<AuthService>(context, listen: false).token;
              if (token == null) return;

              try {
                final response = await http.post(
                  Uri.parse('${Constants.apiBaseUrl}/journal'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'title': titleController.text,
                    'content': contentController.text,
                    'date': DateTime.now().toIso8601String(),
                  }),
                );
                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.pop(context);
                  _loadEntries();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note ajoutée'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erreur lors de l\'ajout'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Journal'),
        backgroundColor: AppTheme.greenPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addEntry,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment, size: 64, color: AppTheme.textLight),
                      SizedBox(height: 16),
                      Text('Aucune note', style: TextStyle(color: AppTheme.textLight)),
                      SizedBox(height: 8),
                      Text('Appuyez sur + pour ajouter une note', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['title'] ?? 'Sans titre',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry['content'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry['date']?.substring(0, 10) ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 5),
    );
  }
}