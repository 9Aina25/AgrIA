import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final details = result['details'];
    final confidence = result['confidence'];
    final predictedClass = result['predictedClass'];

    if (confidence < 60) {
      return _buildUncertainResult(context, confidence);
    }

    return Scaffold(
      backgroundColor: AppTheme.bgPale,
      appBar: AppBar(
        title: const Text('Résultat du diagnostic'),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte principale
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Color(0xFF1aab57)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                children: [
                  const Icon(Icons.health_and_safety, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    details['nom'] ?? predictedClass,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        details['nom_scientifique'] ?? '',
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            details['categorie'] ?? 'Maladie',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.analytics, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Confiance: ${confidence.toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            _buildSectionCard(
              title: "Description",
              icon: Icons.description,
              content: details['description'] ?? 'Aucune description disponible',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Symptômes
            if (details['symptomes'] != null && (details['symptomes'] as List).isNotEmpty)
              _buildListSection(
                title: "Symptômes observés",
                icon: Icons.warning_amber_rounded,
                items: details['symptomes'],
                color: Colors.orange,
              ),
            const SizedBox(height: 16),

            // Traitements
            if (details['traitements'] != null && (details['traitements'] as List).isNotEmpty)
              _buildTreatmentsSection(details['traitements']),
            const SizedBox(height: 16),

            // Conseils pratiques
            if ((details['conseils_arrosage'] != null && details['conseils_arrosage'].toString().isNotEmpty) ||
                (details['conseils_fertilisation'] != null && details['conseils_fertilisation'].toString().isNotEmpty))
              _buildAdviceSection(
                arrosage: details['conseils_arrosage']?.toString(),
                fertilisation: details['conseils_fertilisation']?.toString(),
              ),
            const SizedBox(height: 16),

            // Prévention
            if (details['prevention'] != null && (details['prevention'] as List).isNotEmpty)
              _buildListSection(
                title: "Prévention",
                icon: Icons.shield,
                items: details['prevention'],
                color: Colors.green,
              ),
            const SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Nouveau scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    icon: const Icon(Icons.history),
                    label: const Text('Historique'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/library'),
              icon: const Icon(Icons.menu_book),
              label: const Text('En savoir plus sur les maladies'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required IconData icon,
    required List<dynamic> items,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentsSection(List<dynamic> treatments) {
    return Container(
      width: double.infinity,
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medical_services, color: Colors.purple, size: 22),
                ),
                const SizedBox(width: 12),
                const Text('Traitements recommandés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...treatments.asMap().entries.map((entry) {
              final index = entry.key;
              final t = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4),
                          ],
                        ),
                        child: Center(
                          child: Text(t['icon'] ?? '💊', style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    t['titre'] ?? 'Traitement',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t['description'] ?? '',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceSection({required String? arrosage, required String? fertilisation}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.tips_and_updates, color: Colors.teal, size: 22),
                ),
                const SizedBox(width: 12),
                const Text('Conseils pratiques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (arrosage != null && arrosage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.water_drop, size: 20, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Arrosage', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(arrosage, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (fertilisation != null && fertilisation.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.grass, size: 20, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fertilisation', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(fertilisation, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUncertainResult(BuildContext context, double confidence) {
    return Scaffold(
      backgroundColor: AppTheme.bgPale,
      appBar: AppBar(
        title: const Text('Résultat incertain'),
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
              ),
              const SizedBox(height: 24),
              const Text('Diagnostic incertain', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    Text('Confiance : ${confidence.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: confidence / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Pour améliorer le diagnostic :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildTipItem(Icons.brightness_medium, 'Prenez une photo bien éclairée'),
              _buildTipItem(Icons.crop, 'Cadrez une seule feuille'),
              _buildTipItem(Icons.forest, 'Choisissez une feuille représentative'),
              _buildTipItem(Icons.photo_camera, 'Tenez l\'appareil stable'),
              _buildTipItem(Icons.refresh, 'Essayez avec une autre feuille'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Prendre une nouvelle photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}