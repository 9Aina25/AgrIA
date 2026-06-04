import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'new_password_screen.dart';   // <- Ajout essentiel

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code à 6 chiffres')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final valid = await auth.verifyResetCode(widget.email, code);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (valid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordScreen(email: widget.email, code: code),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code invalide ou expiré')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code à 6 chiffres'),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verify,
                    child: const Text('Vérifier'),
                  ),
          ],
        ),
      ),
    );
  }
}