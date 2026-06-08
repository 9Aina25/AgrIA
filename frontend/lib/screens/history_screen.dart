import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgPale,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: AppTheme.greenPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun diagnostic pour le moment',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade400 : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}