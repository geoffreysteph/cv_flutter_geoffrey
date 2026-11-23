// lib/main.dart
// Point d'entrée de l'application : lance l'app et affiche la page de connexion.
import 'package:flutter/material.dart';

import 'login_page.dart';

void main() {
  // runApp démarre l'application avec le widget racine CvApp
  runApp(const CvApp());
}

class CvApp extends StatelessWidget {
  const CvApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp configure le thème global et la première page (home)
    return MaterialApp(
      title: 'CV Geoffrey',
      debugShowCheckedModeBanner: false, // enlève le bandeau "debug"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginPage(), // l'app s'ouvre sur la page de connexion
    );
  }
}
