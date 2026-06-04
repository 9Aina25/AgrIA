import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'verify_code_screen.dart';   // <- Ajout essentiel

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email requis')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final success = await auth.forgotPassword(email);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur, vérifiez votre email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendCode,
                    child: const Text('Envoyer le code'),
                  ),
          ],
        ),
      ),
    );
  }
}