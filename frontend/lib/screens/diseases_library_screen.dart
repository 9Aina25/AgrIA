import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class DiseasesLibraryScreen extends StatefulWidget {
  const DiseasesLibraryScreen({super.key});

  @override
  State<DiseasesLibraryScreen> createState() => _DiseasesLibraryScreenState();
}

class _DiseasesLibraryScreenState extends State<DiseasesLibraryScreen> {
  List<dynamic> _maladies = [];
  bool _loading = true;
  String _searchQuery = '';
  String _filterGravite = 'toutes';
  String _language = 'fr';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'fr';
    });
    _loadMaladies();
  }

  Future<void> _loadMaladies() async {
    final api = Provider.of<ApiService>(context, listen: false);
    final data = await api.fetchMaladies();
    setState(() {
      _maladies = data.where((m) => m['class_name'] != 'Non_plant').toList();
      _loading = false;
    });
  }

  List<dynamic> get _filteredMaladies {
    var filtered = _maladies;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        final nom = _language == 'fr' ? m['nom_fr'] : m['nom'];
        return nom?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
               m['class_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true;
      }).toList();
    }
    
    if (_filterGravite != 'toutes') {
      final graviteField = _language == 'fr' ? 'gravite_fr' : 'gravite';
      filtered = filtered.where((m) => 
        m[graviteField] == _filterGravite
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque des maladies'),
        backgroundColor: AppTheme.greenPrimary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: _language == 'fr' ? 'Rechercher une maladie...' : 'Search for disease...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(_language == 'fr' ? 'Filtrer : ' : 'Filter: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                _buildFilterChip(_language == 'fr' ? 'Toutes' : 'All', 'toutes'),
                const SizedBox(width: 8),
                _buildFilterChip(_language == 'fr' ? 'Élevée' : 'High', 'élevée'),
                const SizedBox(width: 8),
                _buildFilterChip(_language == 'fr' ? 'Modérée' : 'Moderate', 'modérée'),
                const SizedBox(width: 8),
                _buildFilterChip(_language == 'fr' ? 'Faible' : 'Low', 'faible'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMaladies.isEmpty
                    ? Center(child: Text(_language == 'fr' ? 'Aucune maladie trouvée' : 'No disease found'))
                    : ListView.builder(
                        itemCount: _filteredMaladies.length,
                        itemBuilder: (context, index) {
                          final m = _filteredMaladies[index];
                          return _buildDiseaseCard(m);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _filterGravite == value,
      onSelected: (selected) => setState(() => _filterGravite = value),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.greenLight,
      checkmarkColor: AppTheme.greenPrimary,
    );
  }

  Widget _buildDiseaseCard(Map<String, dynamic> m) {
    final nom = _language == 'fr' ? (m['nom_fr'] ?? m['nom']) : m['nom'];
    final description = _language == 'fr' 
        ? (m['description_fr'] ?? m['description'] ?? '')
        : (m['description'] ?? '');
    final symptomes = _language == 'fr'
        ? (m['symptomes_fr'] ?? m['symptomes'] as List? ?? [])
        : (m['symptomes'] as List? ?? []);
    final traitements = _language == 'fr'
        ? (m['traitements_fr'] ?? m['traitements'] as List? ?? [])
        : (m['traitements'] as List? ?? []);
    final prevention = _language == 'fr'
        ? (m['prevention_fr'] ?? m['prevention'] as List? ?? [])
        : (m['prevention'] as List? ?? []);
    final conseilsArrosage = _language == 'fr'
        ? (m['conseils_arrosage_fr'] ?? m['conseils_arrosage'] ?? '')
        : (m['conseils_arrosage'] ?? '');
    final gravite = _language == 'fr' ? (m['gravite_fr'] ?? 'modérée') : (m['gravite'] ?? 'moderate');
    
    Color graviteColor;
    if (gravite == 'élevée' || gravite == 'high') graviteColor = AppTheme.redAction;
    else if (gravite == 'faible' || gravite == 'low') graviteColor = Colors.green;
    else graviteColor = Colors.orange;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),  // ← CORRIGÉ (birth6 → borderRadius)
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: graviteColor.withAlpha(50),
          child: Icon(
            gravite == 'élevée' || gravite == 'high' ? Icons.warning : 
            (gravite == 'faible' || gravite == 'low' ? Icons.check_circle : Icons.info),
            color: graviteColor,
          ),
        ),
        title: Text(
          nom ?? 'Maladie',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(m['class_name'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) ...[
                  const Text('📋 Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(description, style: const TextStyle(fontSize: 13, height: 1.4)),
                  const SizedBox(height: 16),
                ],
                if (symptomes.isNotEmpty) ...[
                  const Text('⚠️ Symptômes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  ...symptomes.map((s) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text('• $s', style: const TextStyle(fontSize: 13)),
                  )),
                  const SizedBox(height: 16),
                ],
                if (traitements.isNotEmpty) ...[
                  const Text('💊 Traitements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  ...traitements.map((t) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.greenPale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['titre'] ?? 'Traitement', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(t['description'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                ],
                if (conseilsArrosage.isNotEmpty) ...[
                  const Text('💧 Conseils d\'arrosage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(conseilsArrosage, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                ],
                if (prevention.isNotEmpty) ...[
                  const Text('🛡️ Prévention', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  ...prevention.map((p) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text('• $p', style: const TextStyle(fontSize: 13)),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}