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
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((m) =>
              (m['nom_fr']
                      ?.toString()
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false) ||
              (m['class_name']
                      ?.toString()
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }
    if (_filterGravite != 'toutes') {
      filtered =
          filtered.where((m) => m['gravite_fr'] == _filterGravite).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppTheme.darkSurface : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Bibliothèque des maladies',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        backgroundColor: AppTheme.greenPrimary,
        elevation: 0,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Barre de recherche stylisée
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Rechercher une maladie ou un nom scientifique...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.greenPrimary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filtres de gravité (design moderne)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildModernFilterChip('Toutes', 'toutes', isDark),
                  const SizedBox(width: 8),
                  _buildModernFilterChip('Élevée', 'élevée', isDark,
                      color: AppTheme.redAction),
                  const SizedBox(width: 8),
                  _buildModernFilterChip('Modérée', 'modérée', isDark,
                      color: Colors.orange),
                  const SizedBox(width: 8),
                  _buildModernFilterChip('Faible', 'faible', isDark,
                      color: Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Liste des maladies
          Expanded(
            child: _loading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.greenPrimary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chargement des maladies...',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredMaladies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune maladie trouvée',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Essayez un autre terme de recherche',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredMaladies.length,
                        itemBuilder: (context, index) =>
                            _buildModernDiseaseCard(
                                _filteredMaladies[index], isDark),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildModernFilterChip(String label, String value, bool isDark,
      {Color? color}) {
    final isSelected = _filterGravite == value;
    final selectedColor = color ?? AppTheme.greenPrimary;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterGravite = value),
      backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
      selectedColor: selectedColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: isSelected
              ? selectedColor
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
    );
  }

  Widget _buildModernDiseaseCard(Map<String, dynamic> m, bool isDark) {
    final gravite = m['gravite_fr'] ?? 'modérée';
    Color graviteColor;
    String graviteIcon;
    switch (gravite) {
      case 'élevée':
        graviteColor = AppTheme.redAction;
        graviteIcon = '⚠️';
        break;
      case 'faible':
        graviteColor = Colors.green;
        graviteIcon = '✅';
        break;
      default:
        graviteColor = Colors.orange;
        graviteIcon = '⚡';
    }

    // Construction du chemin d'image
    String className = m['class_name'] ?? '';
    String imageName = className.toLowerCase().replaceAll(' ', '_') + '.jpg';
    String imagePath = 'assets/images/maladies/$imageName';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ExpansionTile(
          backgroundColor:
              isDark ? const Color(0xFF2C2C2C) : Colors.white, // corrigé
          collapsedBackgroundColor:
              isDark ? const Color(0xFF2C2C2C) : Colors.white, // corrigé
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              width: 1,
            ),
          ),
          trailing: const Icon(Icons.expand_more, color: AppTheme.greenPrimary),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.greenPrimary.withOpacity(0.2),
                  AppTheme.greenLight.withOpacity(0.1),
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.greenLight.withOpacity(0.3),
                  child: const Icon(
                    Icons.bug_report,
                    size: 32,
                    color: AppTheme.greenPrimary,
                  ),
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  m['nom_fr'] ?? m['nom'] ?? 'Maladie',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: graviteColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: graviteColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      graviteIcon,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      gravite.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: graviteColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              className,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          children: [
            const SizedBox(height: 8),
            // Description
            _buildInfoSection(
              title: '📋 Description',
              content: Text(
                m['description_fr'] ??
                    m['description'] ??
                    'Aucune description disponible',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            // Symptômes
            if (m['symptomes_fr'] != null &&
                (m['symptomes_fr'] as List).isNotEmpty)
              _buildInfoSection(
                title: '⚠️ Symptômes',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (m['symptomes_fr'] as List)
                      .map<Widget>((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ',
                                    style: TextStyle(
                                        color: graviteColor,
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: isDark
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                isDark: isDark,
              ),
            // Traitements
            if (m['traitements_fr'] != null &&
                (m['traitements_fr'] as List).isNotEmpty)
              _buildInfoSection(
                title: '💊 Traitements recommandés',
                content: Column(
                  children: (m['traitements_fr'] as List)
                      .map((t) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.greenLight.withOpacity(0.15),
                                  AppTheme.greenPrimary.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.greenPrimary.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.spa,
                                        size: 16, color: AppTheme.greenPrimary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        t['titre'] ?? 'Traitement',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  t['description'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                isDark: isDark,
              ),
            // Conseils arrosage
            if (m['conseils_arrosage_fr'] != null &&
                m['conseils_arrosage_fr'].isNotEmpty)
              _buildInfoSection(
                title: '💧 Arrosage',
                content: Text(
                  m['conseils_arrosage_fr'],
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                isDark: isDark,
              ),
            // Conseils fertilisation
            if (m['conseils_fertilisation_fr'] != null &&
                m['conseils_fertilisation_fr'].isNotEmpty)
              _buildInfoSection(
                title: '🌱 Fertilisation',
                content: Text(
                  m['conseils_fertilisation_fr'],
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                isDark: isDark,
              ),
            // Prévention
            if (m['prevention_fr'] != null &&
                (m['prevention_fr'] as List).isNotEmpty)
              _buildInfoSection(
                title: '🛡️ Prévention',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (m['prevention_fr'] as List)
                      .map<Widget>((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.greenPrimary)),
                                Expanded(
                                  child: Text(
                                    p,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: isDark
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      {required String title, required Widget content, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
