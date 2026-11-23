// lib/login_page.dart
// PAGE 1 : connexion RÉELLE via l'API (POST /accounts/login).
import 'package:flutter/material.dart';

import 'api_service.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController(); // e-mail du compte
  final _mdpController = TextEditingController();
  bool _masque = true; // true = mot de passe caché
  bool _chargement = false; // true pendant l'appel à l'API

  Future<void> _seConnecter() async {
    // Vérifie que les champs ne sont pas vides
    if (!_formKey.currentState!.validate()) return;

    setState(() => _chargement = true); // affiche le cercle de chargement

    try {
      // Appel à l'API : null = succès, sinon message d'erreur
      final erreur = await ApiService.login(
        _idController.text.trim(),
        _mdpController.text,
      );

      if (!mounted) return; // sécurité si la page a été fermée entre-temps

      if (erreur == null) {
        // Succès : on remplace la page de login par l'application
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(erreur)));
      }
    } catch (e) {
      // Erreur réseau : API éteinte, mauvaise adresse, etc.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de joindre le serveur')),
        );
      }
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _mdpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text(
                  'Connexion',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Champ identifiant (l'API attend une adresse e-mail)
                TextFormField(
                  controller: _idController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Identifiant (e-mail)',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Entrez votre identifiant'
                      : null,
                ),
                const SizedBox(height: 16),

                // Champ mot de passe (texte masqué)
                TextFormField(
                  controller: _mdpController,
                  obscureText: _masque,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.key),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _masque ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _masque = !_masque),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Entrez votre mot de passe'
                      : null,
                ),
                const SizedBox(height: 24),

                // Bouton : désactivé pendant le chargement
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _chargement ? null : _seConnecter,
                    child: _chargement
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Se connecter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
