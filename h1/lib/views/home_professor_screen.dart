import 'package:flutter/material.dart';

class HomePageProfessor extends StatelessWidget {
  const HomePageProfessor ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: const Center(
        child: Text('Bienvenue sur la page d\'accueil ! Prof'),
      ),
    );
  }
}
