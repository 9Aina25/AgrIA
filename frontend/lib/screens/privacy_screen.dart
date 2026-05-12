import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidentialité'),
        backgroundColor: AppTheme.greenPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Politique de Confidentialité',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Données collectées',
              'Nous collectons uniquement les informations nécessaires au diagnostic : photos de plantes, email, nom. Les photos ne sont pas partagées avec des tiers.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Utilisation des données',
              'Les photos sont analysées par notre IA pour identifier les maladies. L\'historique des diagnostics vous permet de suivre l\'évolution de vos plantes.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Sécurité',
              'Vos données sont stockées de manière sécurisée. Les mots de passe sont cryptés et les connexions sont protégées par SSL.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Vos droits',
              'Vous pouvez à tout moment supprimer votre historique ou exporter vos données. Pour supprimer votre compte, contactez-nous.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Contact',
              'Pour toute question sur vos données : privacy@agria.com',
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Dernière mise à jour : Avril 2025',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.greenPrimary),
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
      ],
    );
  }
}