import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _changePassword() async {
    final current = _currentController.text;
    final newPwd = _newController.text;
    final confirm = _confirmController.text;
    if (current.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs sont requis')),
      );
      return;
    }
    if (newPwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nouveau mot de passe doit contenir au moins 6 caractères')),
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
    final success = await auth.changePassword(current, newPwd);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe modifié avec succès')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe actuel incorrect')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer mot de passe')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _currentController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Mot de passe actuel',
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                    onPressed: _changePassword,
                    child: const Text('Changer le mot de passe'),
                  ),
          ],
        ),
      ),
    );
  }
}