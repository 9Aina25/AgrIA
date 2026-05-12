import 'package:flutter/material.dart';

class DiseaseCard extends StatelessWidget {
  final Map<String, dynamic> disease;
  final VoidCallback onTap;

  const DiseaseCard({super.key, required this.disease, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.agriculture),
        title: Text(disease['nom']),
        subtitle: Text(disease['nom_scientifique'] ?? ''),
        trailing: Chip(label: Text(disease['gravite'] ?? 'modérée')),
        onTap: onTap,
      ),
    );
  }
}