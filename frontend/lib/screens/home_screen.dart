import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/language_selector.dart';
import 'diagnostic_screen.dart';
import 'history_screen.dart';
import 'diseases_library_screen.dart';
import 'garden_screen.dart';
import 'journal_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final userName = auth.userName?.split(' ').first ?? 'Invité';

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgrIA'),
        backgroundColor: AppTheme.greenPrimary,
        actions: [
          const LanguageSelector(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Carte de bienvenue
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.greenPale,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(Icons.agriculture, size: 28, color: AppTheme.greenPrimary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bonjour, $userName !', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('Que souhaitez-vous faire aujourd\'hui ?', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 1 - Diagnostic rapide
            const Text('🔬 Diagnostic', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildMenuCard(
                  icon: Icons.camera_alt,
                  title: 'Scanner',
                  subtitle: 'Photo d\'une plante',
                  color: AppTheme.greenPrimary,
                  onTap: () => Navigator.pushNamed(context, '/scan'),
                ),
                _buildMenuCard(
                  icon: Icons.history,
                  title: 'Historique',
                  subtitle: 'Vos analyses',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, '/history'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 2 - Apprentissage (Bibliothèque seulement, plus Quiz)
            const Text('📚 Apprendre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildMenuCard(
                  icon: Icons.menu_book,
                  title: 'Bibliothèque',
                  subtitle: 'Maladies référencées',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/library'),
                ),
                // Quiz supprimé - remplacé par une carte vide ou retiré
                // Si vous voulez garder 2 cartes, ajoutez une autre fonctionnalité
              ],
            ),
            const SizedBox(height: 20),

            // Section 3 - Suivi
            const Text('📊 Suivi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildMenuCard(
                  icon: Icons.grass,
                  title: 'Mon Jardin',
                  subtitle: 'Statistiques',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/garden'),
                ),
                _buildMenuCard(
                  icon: Icons.assignment,
                  title: 'Journal',
                  subtitle: 'Notes et observations',
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, '/journal'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 4 - Compte
            const Text('👤 Compte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildMenuCard(
              icon: Icons.person,
              title: 'Profil',
              subtitle: 'Paramètres et stats',
              color: Colors.blueGrey,
              onTap: () => Navigator.pushNamed(context, '/profile'),
              fullWidth: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    if (fullWidth) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}