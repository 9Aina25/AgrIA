import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'privacy_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _scansCount = 0;
  int _plantsSaved = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/user/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _scansCount = data['scans'] ?? 0;
          _plantsSaved = data['plants_saved'] ?? 0;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Erreur chargement stats: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final userName = auth.userName ?? 'Utilisateur';
    final userEmail = auth.userEmail ?? 'email@exemple.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppTheme.greenPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profil Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.greenPale,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.greenPrimary, AppTheme.greenDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.greenPrimary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.person, size: 45, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard(_scansCount.toString(), 'Scans', _loading),
                      const SizedBox(width: 20),
                      _buildStatCard(_plantsSaved.toString(), 'Plantes\nSauvées', _loading),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.settings,
                    'Paramètres',
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  _buildThemeToggle(auth),
                  _buildMenuItem(
                    Icons.help,
                    'Aide & Support',
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.privacy_tip,
                    'Confidentialité',
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.info,
                    'À propos',
                    Colors.grey,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, auth),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppTheme.redAction),
                  foregroundColor: AppTheme.redAction,
                  backgroundColor: AppTheme.redLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildStatCard(String number, String label, bool loading) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!loading)
            Text(
              number,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppTheme.greenPrimary,
              ),
            )
          else
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color iconColor, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textLight),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        const Divider(height: 1, color: AppTheme.border),
      ],
    );
  }

  Widget _buildThemeToggle(AuthService auth) {
    final isDark = auth.themeMode == ThemeMode.dark;
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? Colors.amber : Colors.orange,
              size: 22,
            ),
          ),
          title: const Text(
            'Mode Sombre',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
          trailing: Switch(
            value: isDark,
            onChanged: (value) => auth.toggleTheme(value),
            activeColor: AppTheme.greenPrimary,
          ),
          onTap: () => auth.toggleTheme(!isDark),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        const Divider(height: 1, color: AppTheme.border),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.redAction,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}