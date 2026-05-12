import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Provider.of<AuthService>(context, listen: false).loadAuthState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          Provider.of<AuthService>(context, listen: false).isAuthenticated ? '/home' : '/login',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe8f5ee), Color(0xFFf7fcf9), Color(0xFFd4f5e3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.greenPrimary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppTheme.greenPrimary.withValues(alpha: 0.4), blurRadius: 32, offset: const Offset(0, 8))],
                ),
                child: const Center(
                  child: Icon(Icons.agriculture, size: 44, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'AgrIA',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Diagnostiquez vos plantes avec l\'IA',
                style: TextStyle(fontSize: 14, color: AppTheme.textLight),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: AppTheme.greenPrimary),
            ],
          ),
        ),
      ),
    );
  }
}