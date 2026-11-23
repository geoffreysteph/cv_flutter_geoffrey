// lib/membre_form_page.dart
// Formulaire pour AJOUTER un membre (membre == null) ou le MODIFIER (membre fourni).
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';
import 'membre.dart';

class MembreFormPage extends StatefulWidget {
  final Membre? membre; // null = ajout, sinon = modification
  const MembreFormPage({super.key, this.membre});

  @override
  State<MembreFormPage> createState() => _MembreFormPageState();
}

class _MembreFormPageState extends State<MembreFormPage> {
  final _formKey = GlobalKey<FormState>();
  // Un contrôleur par champ ; pré-remplis si on modifie un membre existant
  late final _nom = TextEditingController(text: widget.membre?.nom);
  late final _postnom = TextEditingController(text: widget.membre?.postnom);
  late final _prenom = TextEditingController(text: widget.membre?.prenom);
  late final _lieu = TextEditingController(text: widget.membre?.lieuNaissance);
  late final _date = TextEditingController(text: widget.membre?.dateNaissance);
  late final _parente = TextEditingController(text: widget.membre?.parente);

  XFile? _image; // nouvelle photo choisie (envoyée à l'API)
  Uint8List? _apercu; // octets de la photo, pour l'aperçu
  bool _chargement = false;

  bool get _modification => widget.membre != null;

  // Ouvre la galerie pour choisir une photo
  Future<void> _choisirPhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;
    final octets = await img.readAsBytes();
    setState(() {
      _image = img;
      _apercu = octets;
    });
  }

  // Calendrier pour choisir la date (format AAAA-MM-JJ attendu par l'API)
  Future<void> _choisirDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_date.text) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // l'API refuse les dates futures
    );
    if (d != null) {
      _date.text =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _chargement = true);

    try {
      final erreur = await ApiService.saveMembre(
        id: widget.membre?.id,
        champs: {
          'nom': _nom.text.trim(),
          'postnom': _postnom.text.trim(),
          'prenom': _prenom.text.trim(),
          'lieu_naissance': _lieu.text.trim(),
          'date_naissance': _date.text.trim(),
          'parente': _parente.text.trim(),
        },
        image: _image,
      );
      if (!mounted) return;
      if (erreur == null) {
        Navigator.pop(context, true); // true = la liste doit être rechargée
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(erreur)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de joindre le serveur')),
        );
      }
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  // Champ texte obligatoire réutilisable
  Widget _champ(
    TextEditingController c,
    String label, {
    bool lectureSeule = false,
    VoidCallback? onTap,
    IconData? icone,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        readOnly: lectureSeule,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: icone == null ? null : Icon(icone),
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Aperçu : nouvelle photo > photo actuelle du serveur > icône
    Widget photo;
    if (_apercu != null) {
      photo = Image.memory(
        _apercu!,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      );
    } else if (widget.membre?.imageUrl != null) {
      photo = Image.network(
        widget.membre!.imageUrl!,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60),
      );
    } else {
      photo = const SizedBox(
        width: 110,
        height: 110,
        child: Icon(Icons.person, size: 60),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_modification ? 'Modifier un membre' : 'Ajouter un membre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ClipOval(child: photo),
              TextButton.icon(
                onPressed: _choisirPhoto,
                icon: const Icon(Icons.photo),
                label: const Text('Choisir une photo'),
              ),
              const SizedBox(height: 8),
              _champ(_nom, 'Nom'),
              _champ(_postnom, 'Postnom'),
              _champ(_prenom, 'Prénom'),
              _champ(_lieu, 'Lieu de naissance'),
              _champ(
                _date,
                'Date de naissance',
                lectureSeule: true,
                onTap: _choisirDate,
                icone: Icons.calendar_today,
              ),
              _champ(_parente, 'Lien de parenté (Père, Mère, Frère...)'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _chargement ? null : _enregistrer,
                  child: _chargement
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_modification ? 'Enregistrer' : 'Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
