import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
        backgroundColor: AppTheme.greenPrimary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // FAQ Section
          _buildSectionTitle('Foire Aux Questions'),
          _buildFaqTile(
            'Comment scanner une plante ?',
            '1. Allez dans l\'onglet Scanner\n2. Prenez une photo ou importez une image\n3. Appuyez sur "Scanner avec IA"',
          ),
          _buildFaqTile(
            'Comment interpréter les résultats ?',
            'Le diagnostic indique la maladie détectée avec un pourcentage de confiance. Cliquez sur "Traitement" pour voir les solutions recommandées.',
          ),
          _buildFaqTile(
            'Mes données sont-elles sauvegardées ?',
            'Oui, vos diagnostics sont automatiquement sauvegardés dans votre historique et synchronisés sur votre compte.',
          ),

          const Divider(height: 2, indent: 20, endIndent: 20),

          // Contact Section
          _buildSectionTitle('Nous contacter'),
          _buildContactTile(Icons.email, 'Email', 'support@agria.com', () => _launchEmail()),
          _buildContactTile(Icons.web, 'Site web', 'www.agria.com', () => _launchUrl('https://agria.com')),
          _buildContactTile(Icons.phone, 'Téléphone', '+261 34 123 4567', () => _launchPhone()),

          const Divider(height: 2, indent: 20, endIndent: 20),

          // Resources Section
          _buildSectionTitle('Ressources'),
          _buildActionTile('Guide d\'utilisation', () => _showGuideDialog(context)),
          _buildActionTile('Signaler un bug', () => _showBugReportDialog(context)),

          const SizedBox(height: 30),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.greenPrimary),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.question_answer, color: AppTheme.greenPrimary),
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer, style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String label, String value, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.greenDark),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildActionTile(String title, VoidCallback onTap) {
    return ListTile(
      leading: const Icon(Icons.help_outline, color: AppTheme.greenDark),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@agria.com',
      query: 'subject=Support AgrIA',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      debugPrint('Erreur email: $e');
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Erreur url: $e');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+261341234567');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      debugPrint('Erreur téléphone: $e');
    }
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Guide d\'utilisation'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Créez un compte ou connectez-vous'),
              SizedBox(height: 8),
              Text('2. Prenez une photo de votre plante malade'),
              SizedBox(height: 8),
              Text('3. L\'IA analyse l\'image et identifie la maladie'),
              SizedBox(height: 8),
              Text('4. Consultez les traitements recommandés'),
              SizedBox(height: 8),
              Text('5. Suivez l\'évolution dans votre historique'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Signaler un bug'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Décrivez le problème...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bug signalé, merci !')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.greenPrimary),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}