// lib/family_page.dart
// PAGE 3 : membres de la famille via l'API : liste, ajout, modification, suppression.
import 'package:flutter/material.dart';

import 'api_service.dart';
import 'membre.dart';
import 'membre_form_page.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  late Future<List<Membre>> _membres;

  @override
  void initState() {
    super.initState();
    _membres = ApiService.getMembres();
  }

  // Recharge la liste depuis l'API
  Future<void> _recharger() async {
    setState(() => _membres = ApiService.getMembres());
    await _membres;
  }

  // Ouvre le formulaire (ajout si m == null, sinon modification)
  Future<void> _ouvrirFormulaire([Membre? m]) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MembreFormPage(membre: m)),
    );
    if (ok == true) _recharger(); // le formulaire a enregistré -> on rafraîchit
  }

  // Supprime un membre après confirmation
  Future<void> _supprimer(Membre m) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Supprimer ${m.nom} ${m.prenom} définitivement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    final erreur = await ApiService.deleteMembre(m.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(erreur ?? 'Membre supprimé')));
    if (erreur == null) _recharger();
  }

  // Photo ronde (image du serveur ou icône)
  Widget _photo(Membre m) {
    const taille = 60.0;
    final icone = Container(
      width: taille,
      height: taille,
      color: Colors.indigo.shade100,
      child: const Icon(Icons.person, size: 36, color: Colors.indigo),
    );
    if (m.imageUrl == null) return ClipOval(child: icone);
    return ClipOval(
      child: Image.network(
        m.imageUrl!,
        width: taille,
        height: taille,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => icone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bouton "+" pour ajouter un membre
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ouvrirFormulaire(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Membre>>(
        future: _membres,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('Impossible de charger la famille'),
                  TextButton(
                    onPressed: _recharger,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          final membres = snapshot.data!;
          if (membres.isEmpty) {
            return const Center(child: Text('Aucun membre. Appuyez sur +'));
          }
          return RefreshIndicator(
            onRefresh: _recharger,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: membres.length,
              itemBuilder: (context, i) {
                final m = membres[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: _photo(m),
                    title: Text(
                      '${m.nom} ${m.postnom} ${m.prenom}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${m.parente}\nNé(e) le ${m.dateNaissance} à ${m.lieuNaissance}',
                    ),
                    isThreeLine: true,
                    // Boutons modifier / supprimer
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          onPressed: () => _ouvrirFormulaire(m),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _supprimer(m),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
