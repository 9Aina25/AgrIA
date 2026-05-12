import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<Map<String, dynamic>> _entries = [
    {
      "id": "1",
      "plant": "🍅 Tomate cerise",
      "plantName": "Tomate",
      "date": "2025-05-03",
      "note": "Apparition de taches brunes sur les feuilles inférieures. Traitement appliqué : bouillie bordelaise.",
      "status": "sick",
      "action": "Bouillie bordelaise - 2 applications",
      "hasPhoto": true,
    },
    {
      "id": "2",
      "plant": "🍓 Fraisier",
      "plantName": "Fraisier",
      "date": "2025-04-28",
      "note": "Les feuilles sont vertes et vigoureuses. Très belle récolte cette semaine.",
      "status": "healthy",
      "action": "Arrosage normal + paillage",
      "hasPhoto": false,
    },
    {
      "id": "3",
      "plant": "🥔 Pomme de terre",
      "plantName": "Pomme de terre",
      "date": "2025-04-25",
      "note": "Buttage effectué. Les plants sont en bonne santé.",
      "status": "healthy",
      "action": "Buttage + arrosage",
      "hasPhoto": false,
    },
  ];

  final TextEditingController _plantController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();

  void _deleteEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note supprimée'), backgroundColor: Colors.red),
    );
  }

  void _showAddEntryDialog() {
    _plantController.clear();
    _noteController.clear();
    _actionController.clear();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          String selectedStatus = 'healthy';
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Nouvelle note', textAlign: TextAlign.center),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _plantController,
                    decoration: const InputDecoration(labelText: 'Nom de la plante', hintText: 'Ex: Tomate, Fraisier...'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(labelText: 'Note', hintText: 'Ce que vous observez...'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _actionController,
                    decoration: const InputDecoration(labelText: 'Action effectuée', hintText: 'Traitement, arrosage...'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Statut : ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'healthy', label: Text('✅ Sain'), icon: Icon(Icons.check_circle, size: 16)),
                            ButtonSegment(value: 'sick', label: Text('⚠️ Malade'), icon: Icon(Icons.warning_amber, size: 16)),
                          ],
                          selected: {selectedStatus},
                          onSelectionChanged: (set) => setDialogState(() => selectedStatus = set.first),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return selectedStatus == 'healthy' ? Colors.green.shade100 : Colors.orange.shade100;
                              }
                              return Colors.white;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () {
                  if (_plantController.text.isNotEmpty && _noteController.text.isNotEmpty) {
                    setState(() {
                      _entries.insert(0, {
                        "id": DateTime.now().toString(),
                        "plant": getPlantIcon(_plantController.text),
                        "plantName": _plantController.text,
                        "date": DateTime.now().toString().substring(0, 10),
                        "note": _noteController.text,
                        "status": selectedStatus,
                        "action": _actionController.text.isNotEmpty ? _actionController.text : "Non spécifié",
                        "hasPhoto": false,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note ajoutée'), backgroundColor: AppTheme.greenPrimary),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.greenPrimary),
                child: const Text('Ajouter'),
              ),
            ],
          );
        },
      ),
    );
  }

  String getPlantIcon(String plantName) {
    if (plantName.toLowerCase().contains('tomate')) return '🍅';
    if (plantName.toLowerCase().contains('fraise')) return '🍓';
    if (plantName.toLowerCase().contains('pomme de terre')) return '🥔';
    if (plantName.toLowerCase().contains('poivron')) return '🫑';
    if (plantName.toLowerCase().contains('laitue')) return '🥬';
    return '🌿';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Journal'),
        backgroundColor: AppTheme.greenPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Conseil'),
                  content: const Text('Utilisez ce journal pour suivre l\'évolution de vos plantes et les traitements appliqués. Idéal pour garder une trace !'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                ),
              );
            },
          ),
        ],
      ),
      body: _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Aucune note', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _showAddEntryDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.greenPrimary),
                    child: const Text('Ajouter ma première note'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(entry["plant"], style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry["plantName"],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: entry["status"] == "healthy" ? Colors.green.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                entry["status"] == "healthy" ? "✅ Sain" : "⚠️ Malade",
                                style: TextStyle(
                                  color: entry["status"] == "healthy" ? Colors.green.shade700 : Colors.orange.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 6),
                            Text(entry["date"], style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(entry["note"], style: const TextStyle(fontSize: 14, height: 1.4)),
                        if (entry["action"].isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.greenPale,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.checklist, size: 18, color: AppTheme.greenPrimary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Action effectuée', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(entry["action"], style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _deleteEntry(index),
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Supprimer'),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        backgroundColor: AppTheme.greenPrimary,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}