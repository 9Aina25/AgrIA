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
        Navigator.pushReplacementNamed(context, '/history');
        break;
      case 4:
        _showMoreMenu(context);
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (builder) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.grass, color: AppTheme.greenPrimary),
                title: const Text('Mon Jardin'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/garden');
                },
              ),
              // Quiz SUPPRIMÉ
              ListTile(
                leading: const Icon(Icons.assignment, color: AppTheme.greenPrimary),
                title: const Text('Mon Journal'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/journal');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person, color: AppTheme.greenPrimary),
                title: const Text('Profil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.greenPrimary,
      unselectedItemColor: AppTheme.textLight,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), activeIcon: Icon(Icons.camera_alt), label: 'Scanner'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Bibliothèque'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Historique'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), activeIcon: Icon(Icons.more_horiz), label: 'Plus'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}