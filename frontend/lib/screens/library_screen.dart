import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<dynamic> _maladies = [];
  bool _loading = true;
  String _searchQuery = '';
  String _filterGravite = 'toutes';

  @override
  void initState() {
    super.initState();
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
    
    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) =>
        m['nom_fr']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
        m['class_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true
      ).toList();
    }
    
    // Filtre par gravité
    if (_filterGravite != 'toutes') {
      filtered = filtered.where((m) => 
        m['gravite_fr'] == _filterGravite
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
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher une maladie...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filtres par gravité
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Filtrer : ', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                _buildFilterChip('Toutes', 'toutes'),
                const SizedBox(width: 8),
                _buildFilterChip('Élevée', 'élevée'),
                const SizedBox(width: 8),
                _buildFilterChip('Modérée', 'modérée'),
                const SizedBox(width: 8),
                _buildFilterChip('Faible', 'faible'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Liste
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMaladies.isEmpty
                    ? const Center(child: Text('Aucune maladie trouvée'))
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
    final gravite = m['gravite_fr'] ?? 'modérée';
    Color graviteColor;
    switch (gravite) {
      case 'élevée': graviteColor = AppTheme.redAction; break;
      case 'faible': graviteColor = Colors.green; break;
      default: graviteColor = Colors.orange;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: graviteColor.withAlpha(50),
          child: Icon(
            gravite == 'élevée' ? Icons.warning : (gravite == 'faible' ? Icons.check_circle : Icons.info),
            color: graviteColor,
          ),
        ),
        title: Text(
          m['nom_fr'] ?? m['nom'] ?? 'Maladie',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m['class_name'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: graviteColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Gravité : $gravite',
                style: TextStyle(fontSize: 11, color: graviteColor, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                const Text('📋 Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(m['description_fr'] ?? m['description'] ?? '', style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 16),
                
                // Symptômes
                if (m['symptomes_fr'] != null && (m['symptomes_fr'] as List).isNotEmpty) ...[
                  const Text('⚠️ Symptômes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  ...(m['symptomes_fr'] as List).map((s) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text('• $s', style: const TextStyle(fontSize: 13)),
                  )),
                  const SizedBox(height: 16),
                ],
                
                // Traitements
                if (m['traitements_fr'] != null && (m['traitements_fr'] as List).isNotEmpty) ...[
                  const Text('💊 Traitements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  ...(m['traitements_fr'] as List).map((t) => Container(
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
                
                // Conseils
                if (m['conseils_arrosage_fr'] != null && m['conseils_arrosage_fr'].isNotEmpty) ...[
                  const Text('💧 Conseils d\'arrosage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(m['conseils_arrosage_fr'], style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                ],
                
                if (m['conseils_fertilisation_fr'] != null && m['conseils_fertilisation_fr'].isNotEmpty) ...[
                  const Text('🌱 Conseils de fertilisation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(m['conseils_fertilisation_fr'], style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                ],
                
                // Prévention
                if (m['prevention_fr'] != null && (m['prevention_fr'] as List).isNotEmpty) ...[
                  const Text('🛡️ Prévention', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  ...(m['prevention_fr'] as List).map((p) => Padding(
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