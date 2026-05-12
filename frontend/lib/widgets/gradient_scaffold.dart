import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final String? title;

  const GradientScaffold({super.key, required this.body, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppBar(title: Text(title!), backgroundColor: Colors.green) : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF203A43)]),
        ),
        child: body,
      ),
    );
  }
}