import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

Future<void> _register() async {
  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text;
  final confirm = _confirmController.text;

  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    _showError('Veuillez remplir tous les champs');
    return;
  }
  if (password != confirm) {
    _showError('Les mots de passe ne correspondent pas');
    return;
  }
  if (password.length < 6) {
    _showError('Le mot de passe doit contenir au moins 6 caractères');
    return;
  }

  setState(() => _isLoading = true);
  final auth = Provider.of<AuthService>(context, listen: false);
  final response = await auth.registerWithResponse(email, password, name); // nouvelle méthode
  setState(() => _isLoading = false);

  if (!mounted) return;

  if (response.success) {
    _showValidationDialog();
  } else {
    _showError(response.message); // affiche le vrai message d’erreur
  }
}

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.redAction),
    );
  }

  void _showValidationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('✅ Vérifiez vos emails'),
        content: const Text(
          'Un lien de validation vous a été envoyé.\n\n'
          'Cliquez dessus pour activer votre compte avant de vous connecter.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.greenPrimary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.greenPrimary.withValues(alpha: 0.4),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.agriculture, size: 44, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Créer un compte',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez des milliers de plantophiles',
                  style: TextStyle(fontSize: 14, color: AppTheme.textLight),
                ),
                const SizedBox(height: 36),

                // Formulaire
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    hintText: 'Alex R.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'vous@exemple.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: 'Min. 6 caractères',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textLight,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textLight,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton d'inscription
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text('Créer mon compte'),
                      ),
                const SizedBox(height: 16),

                // Lien vers connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Déjà un compte ?',
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: AppTheme.greenPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}