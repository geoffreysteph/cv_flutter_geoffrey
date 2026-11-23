// lib/main_page.dart
// Navigation principale (BottomNavigationBar) entre Accueil, Famille et Contact.
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'family_page.dart';
import 'contact_page.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0; // onglet actuellement sélectionné

  // Les 3 pages accessibles après connexion
  final _pages = const [HomePage(), FamilyPage(), ContactPage()];
  final _titres = const ['Mon CV', 'Ma famille', 'Contact'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titres[_index]),
        actions: [
          // Bouton de déconnexion : retour à la page de login
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ],
      ),
      body: _pages[_index], // affiche la page de l'onglet choisi
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(
            icon: Icon(Icons.family_restroom),
            label: 'Famille',
          ),
          NavigationDestination(
            icon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}

// Widget réutilisable : affiche une photo ronde depuis les assets.
// Si l'image est introuvable, affiche une icône à la place (évite les erreurs).
class PhotoRonde extends StatelessWidget {
  final String chemin;
  final double taille;
  const PhotoRonde({super.key, required this.chemin, this.taille = 60});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        chemin,
        width: taille,
        height: taille,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: taille,
          height: taille,
          color: Colors.indigo.shade100,
          child: Icon(Icons.person, size: taille * 0.6, color: Colors.indigo),
        ),
      ),
    );
  }
}
