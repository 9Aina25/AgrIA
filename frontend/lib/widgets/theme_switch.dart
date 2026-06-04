// widgets/theme_switch.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../utils/theme.dart';

class ThemeSwitch extends StatelessWidget {
  final bool isCompact;
  final bool showLabels;
  
  const ThemeSwitch({super.key, this.isCompact = false, this.showLabels = true});
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = themeProvider.themeMode;
    
    if (isCompact) {
      return IconButton(
        icon: Icon(
          themeMode == ThemeMode.dark 
              ? Icons.light_mode 
              : (themeMode == ThemeMode.light ? Icons.dark_mode : Icons.brightness_auto),
          color: isDark ? AppTheme.darkText : AppTheme.textDark,
        ),
        onPressed: () => themeProvider.toggleTheme(),
        tooltip: 'Changer de thème',
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(context, themeProvider, ThemeMode.light, Icons.light_mode, 'Clair'),
          _buildOption(context, themeProvider, ThemeMode.dark, Icons.dark_mode, 'Sombre'),
          _buildOption(context, themeProvider, ThemeMode.system, Icons.brightness_auto, 'Auto'),
        ],
      ),
    );
  }
  
  Widget _buildOption(BuildContext context, ThemeProvider provider, ThemeMode mode, IconData icon, String label) {
    final isSelected = provider.themeMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => provider.setThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.greenPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? AppTheme.darkTextSecondary : AppTheme.textMid),
            ),
            if (showLabels) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? Colors.white 
                      : (isDark ? AppTheme.darkTextSecondary : AppTheme.textMid),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}