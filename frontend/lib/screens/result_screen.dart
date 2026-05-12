import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final details = result['details'];
    final confidence = result['confidence'];
    final predictedClass = result['predictedClass'];

    // 🔴 SEUIL DE CONFIANCE : si < 70%, afficher un message d'incertitude
    if (confidence < 70.0) {
      return _buildUncertainResult(context, confidence);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat'),
        backgroundColor: AppTheme.greenPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de la maladie
            Text(
              details['nom'] ?? predictedClass,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            // Confiance
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.greenLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Confiance : ${confidence.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.greenDark),
              ),
            ),
            const SizedBox(height: 16),
            // Description
            const Text('📋 Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              details['description'] ?? 'Aucune description disponible',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            // Symptômes
            if (details['symptomes'] != null && (details['symptomes'] as List).isNotEmpty) ...[
              const Text('⚠️ Symptômes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              ...(details['symptomes'] as List).map((s) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text('• $s', style: const TextStyle(fontSize: 14)),
              )),
              const SizedBox(height: 16),
            ],
            // Traitements
            if (details['traitements'] != null && (details['traitements'] as List).isNotEmpty) ...[
              const Text('💊 Traitements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              ...(details['traitements'] as List).map((t) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.greenPale,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['titre'] ?? 'Traitement', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(t['description'] ?? '', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Nouveau scan'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.greenPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    icon: const Icon(Icons.history),
                    label: const Text('Historique'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUncertainResult(BuildContext context, double confidence) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat incertain'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              '⚠️ Diagnostic incertain',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Confiance : ${confidence.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pour un meilleur diagnostic :',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text('• Prenez une photo bien éclairée'),
            const Text('• Cadrez une seule feuille'),
            const Text('• Évitez les ombres sur la feuille'),
            const Text('• Fond uni de préférence'),
            const Text('• Prenez la photo de plus près'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('📸 Recommencer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}