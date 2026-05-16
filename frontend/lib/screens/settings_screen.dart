import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'fr';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'fr';
    });
  }

  Future<void> _changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => _selectedLanguage = lang);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'fr' ? 'Langue changée en français' : 'Language changed to English'),
          backgroundColor: AppTheme.greenPrimary,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isDarkMode = auth.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppTheme.greenPrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Section Apparence
          _buildSectionTitle('Apparence', isDarkMode),
          _buildThemeTile(auth, isDarkMode),

          const Divider(height: 1, indent: 60),

          // Section Notifications
          _buildSectionTitle('Notifications', isDarkMode),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Notifications push',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            isDarkMode: isDarkMode,
          ),

          const Divider(height: 1, indent: 60),

          // Section Langue
          _buildSectionTitle('Langue', isDarkMode),
          _buildLanguageTile('Français', 'fr', _selectedLanguage, () => _changeLanguage('fr'), isDarkMode),
          _buildLanguageTile('English', 'en', _selectedLanguage, () => _changeLanguage('en'), isDarkMode),

          const Divider(height: 1, indent: 60),

          // Section Données
          _buildSectionTitle('Données', isDarkMode),
          _buildActionTile(
            icon: Icons.delete,
            title: 'Supprimer l\'historique',
            color: AppTheme.redAction,
            onTap: () => _showDeleteDialog(context),
            isDarkMode: isDarkMode,
          ),
          _buildActionTile(
            icon: Icons.download,
            title: 'Exporter mes données',
            color: isDarkMode ? Colors.white70 : AppTheme.textDark,
            onTap: () => _showToast('Exportation démarrée'),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 50),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? AppTheme.greenLight : AppTheme.greenPrimary,
        ),
      ),
    );
  }

  Widget _buildThemeTile(AuthService auth, bool isDarkMode) {
    return ListTile(
      leading: Icon(Icons.dark_mode, color: isDarkMode ? Colors.amber : AppTheme.greenDark),
      title: Text(
        'Mode Sombre',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : AppTheme.textDark,
        ),
      ),
      trailing: Switch(
        value: auth.themeMode == ThemeMode.dark,
        onChanged: (value) => auth.toggleTheme(value),
        activeColor: AppTheme.greenPrimary,
      ),
      onTap: () => auth.toggleTheme(auth.themeMode != ThemeMode.dark),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white70 : AppTheme.greenDark),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: isDarkMode ? Colors.white : AppTheme.textDark,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.greenPrimary,
      ),
    );
  }

  Widget _buildLanguageTile(String label, String value, String groupValue, VoidCallback onTap, bool isDarkMode) {
    final isSelected = groupValue == value;
    return ListTile(
      leading: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: (v) => onTap(),
        activeColor: AppTheme.greenPrimary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: isDarkMode ? Colors.white : AppTheme.textDark,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppTheme.greenPrimary, size: 20)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(fontSize: 15, color: color),
      ),
      trailing: Icon(Icons.chevron_right, size: 18, color: isDarkMode ? Colors.white70 : AppTheme.textLight),
      onTap: onTap,
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'historique'),
        content: const Text('Cette action est irréversible. Voulez-vous vraiment supprimer tout votre historique ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Historique supprimé');
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.redAction),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}