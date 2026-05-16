import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _resetPassword() async {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': widget.token, 'new_password': _passwordController.text}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe mis à jour, connectez-vous'), backgroundColor: Colors.green),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lien invalide ou expiré'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur réseau'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau mot de passe'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(
              labelText: 'Nouveau mot de passe',
              suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
            )),
            const SizedBox(height: 16),
            TextField(controller: _confirmController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirmer')),
            const SizedBox(height: 20),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _resetPassword, child: const Text('Réinitialiser')),
          ],
        ),
      ),
    );
  }
}