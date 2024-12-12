import 'package:flutter/material.dart';

class HomePageAdministration extends StatelessWidget {
  const HomePageAdministration ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: const Center(
        child: Text('Bienvenue sur la page d\'accueil ! Admin'),
      ),
    );
  }
}
