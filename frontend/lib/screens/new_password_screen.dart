import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String code;
  const NewPasswordScreen({super.key, required this.email, required this.code});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _reset() async {
    final newPwd = _newController.text;
    final confirm = _confirmController.text;
    if (newPwd.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs sont requis')),
      );
      return;
    }
    if (newPwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('6 caractères minimum')),
      );
      return;
    }
    if (newPwd != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final success = await auth.resetPassword(widget.email, widget.code, newPwd);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Succès'),
          content: const Text('Mot de passe réinitialisé. Connectez-vous.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur, code expiré ou invalide')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau mot de passe')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _newController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirmer',
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _reset,
                    child: const Text('Réinitialiser'),
                  ),
          ],
        ),
      ),
    );
  }
}