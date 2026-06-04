import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ChangeNameScreen extends StatefulWidget {
  const ChangeNameScreen({super.key});

  @override
  State<ChangeNameScreen> createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthService>(context, listen: false);
    _nameController.text = auth.userName ?? '';
  }

  Future<void> _changeName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nom requis')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final success = await auth.changeName(newName);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nom modifié avec succès')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur, réessayez plus tard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer mon nom')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nouveau nom'),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _changeName,
                    child: const Text('Enregistrer'),
                  ),
          ],
        ),
      ),
    );
  }
}