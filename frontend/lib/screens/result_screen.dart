import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/pdf_export_service.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final Uint8List imageBytes;
  const ResultScreen({super.key, required this.result, required this.imageBytes});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isExporting = false;

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final data = widget.result;
    try {
      // Sauvegarde temporaire de l'image
      final tempDir = Directory.systemTemp;
      final imageFile = File('${tempDir.path}/temp_image.jpg');
      await imageFile.writeAsBytes(widget.imageBytes);

      final file = await PdfExportService.generateDiagnosisPdf(
        userName: auth.userName ?? 'Utilisateur',
        plantName: data['plant_name'] ?? 'Plante inconnue',
        diseaseName: data['diagnostic'] ?? 'Maladie non identifiée',
        confidence: (data['confidence'] ?? 0).toDouble(),
        symptoms: List<String>.from(data['symptomes'] ?? []),
        treatments: Map<String, List<String>>.from(data['traitements'] ?? {}),
        date: DateTime.now(),
      );
      if (!mounted) return;
      await PdfExportService.sharePdf(file);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF exporté avec succès'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = widget.result;
    final diseaseName = data['diagnostic'] ?? 'Maladie inconnue';
    final confidence = (data['confidence'] ?? 0).toDouble();
    final symptoms = List<String>.from(data['symptomes'] ?? []);
    final treatments = Map<String, List<String>>.from(data['traitements'] ?? {});

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgPale,
      appBar: AppBar(
        title: const Text('Résultat du diagnostic'),
        backgroundColor: AppTheme.greenPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: MemoryImage(widget.imageBytes),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Diagnostic
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔬 Diagnostic',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diseaseName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.greenPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Confiance : '),
                      Text(
                        '${confidence.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '📋 Symptômes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...symptoms.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $s'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '💊 Traitements recommandés',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (treatments.containsKey('preventif'))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Préventif :', style: TextStyle(fontWeight: FontWeight.w600)),
                        ...treatments['preventif']!.map((t) => Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 4),
                              child: Text('• $t'),
                            )),
                      ],
                    ),
                  if (treatments.containsKey('curatif')) ...[
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Curatif :', style: TextStyle(fontWeight: FontWeight.w600)),
                        ...treatments['curatif']!.map((t) => Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 4),
                              child: Text('• $t'),
                            )),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportPdf,
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_isExporting ? 'Exportation...' : 'Exporter en PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}