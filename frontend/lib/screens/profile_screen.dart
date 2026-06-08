import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/theme_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
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
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = auth.userName ?? 'Utilisateur';
    final userEmail = auth.userEmail ?? 'email@exemple.com';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgPale,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppTheme.greenPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.greenPale,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppTheme.greenPrimary,
                    child: const Icon(Icons.person, size: 45, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkText : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 20),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.settings,
                    'Paramètres',
                    Colors.blue,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                  _buildMenuItem(
                    Icons.help,
                    'Aide & Support',
                    Colors.orange,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                  ),
                  _buildMenuItem(
                    Icons.info,
                    'À propos',
                    Colors.grey,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                  const Divider(),
                  _buildThemeSwitch(themeProvider),
                ],
              ),
            ),
            const SizedBox(height: 30),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color iconColor, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkText : AppTheme.textDark,
            ),
          ),
          trailing: Icon(Icons.chevron_right, size: 20, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight),
          onTap: onTap,
        ),
        const Divider(height: 1, color: AppTheme.border),
      ],
    );
  }

  Widget _buildThemeSwitch(ThemeProvider themeProvider) {
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    return SwitchListTile(
      title: const Text('Mode sombre'),
      value: isDark,
      onChanged: (value) => themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
      secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.logout();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redAction),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}