import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/scan');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/library');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/garden');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      selectedItemColor: AppTheme.greenPrimary,
      unselectedItemColor: isDark ? AppTheme.darkTextSecondary : AppTheme.textLight,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'Scanner'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Bibliothèque'),
        BottomNavigationBarItem(icon: Icon(Icons.forest_outlined), label: 'Mon Jardin'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }
}