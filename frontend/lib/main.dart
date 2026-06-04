import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/diagnostic_screen.dart';
import 'screens/library_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/garden_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/change_name_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/verify_code_screen.dart';
import 'screens/new_password_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Constants.getCurrentLanguage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'AgrIA',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: auth.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/scan': (context) => const DiagnosticScreen(),
              '/library': (context) => const LibraryScreen(),
              '/history': (context) => const HistoryScreen(),
              '/garden': (context) => const GardenScreen(),
              '/journal': (context) => const JournalScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/change-name': (context) => const ChangeNameScreen(),
              '/change-password': (context) => const ChangePasswordScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/verify-code') {
                final email = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (_) => VerifyCodeScreen(email: email),
                );
              }
              if (settings.name == '/new-password') {
                final args = settings.arguments as Map<String, String>;
                return MaterialPageRoute(
                  builder: (_) => NewPasswordScreen(
                    email: args['email']!,
                    code: args['code']!,
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}