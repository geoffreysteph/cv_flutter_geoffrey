// lib/home_page.dart
// PAGE 2 : accueil, présente le CV complet.
import 'package:flutter/material.dart';

import 'main_page.dart'; // pour utiliser PhotoRonde

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Petit widget pour créer un bloc de section (titre + contenu)
  Widget _section(String titre, IconData icone, List<String> lignes) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            // Une ligne par élément de la liste
            ...lignes.map(
              (l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('• $l'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ===== EN-TÊTE : photo, nom, titre =====
        const Center(
          child: PhotoRonde(
            // 👉 METTEZ VOTRE PHOTO ICI : assets/images/moi.jpg
            chemin: 'assets/images/moi.jpg.jpg',
            taille: 120,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Matembera Rwanika Geoffrey',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Ingénieur',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // ===== SECTIONS DU CV =====
        _section('Formation', Icons.school, ['Système Informatique']),
        _section('Expériences', Icons.work, [
          'Stage : Hayatcom',
          'Emploi : ISTM',
          'Emploi actuel : UNIGOM',
        ]),
        _section('Compétences techniques', Icons.computer, [
          'Réseau informatique (bon niveau)',
        ]),
        _section('Langues', Icons.language, [
          'Français : excellent',
          'Anglais : bon',
          'Swahili : bon',
        ]),
        _section('Centres d\'intérêt', Icons.favorite, ['Le travail']),
      ],
    );
  }
}
