// lib/contact_page.dart
// PAGE 4 : coordonnées cliquables (appel, e-mail, carte, GitHub).
// Nécessite le package url_launcher (voir pubspec.yaml).
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  // Ouvre un lien (tel:, mailto:, https:) dans l'application adaptée
  Future<void> _ouvrir(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    // Si le lien ne peut pas s'ouvrir, on prévient l'utilisateur
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir ce lien')),
      );
    }
  }

  // Une ligne de contact cliquable (icône + titre + valeur)
  Widget _ligne(
    BuildContext context,
    IconData icone,
    String titre,
    String valeur,
    String url,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icone, color: Colors.indigo),
        title: Text(titre),
        subtitle: Text(valeur),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _ouvrir(context, url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Téléphone : lance l'appel
        _ligne(
          context,
          Icons.phone,
          'Téléphone',
          '+243 893 493 810',
          'tel:+243893493810',
        ),
        // E-mail : ouvre l'application de messagerie
        _ligne(
          context,
          Icons.email,
          'E-mail',
          'stephanegeoffrey6@gmail.com',
          'mailto:stephanegeoffrey6@gmail.com',
        ),
        // Adresse : ouvre Google Maps sur Goma
        _ligne(
          context,
          Icons.location_on,
          'Adresse',
          'Goma',
          'https://www.google.com/maps/search/?api=1&query=Goma',
        ),
        // GitHub : ouvre le profil dans le navigateur
        _ligne(
          context,
          Icons.code,
          'GitHub',
          'github.com/geoffreysteph',
          'https://github.com/geoffreysteph',
        ),
      ],
    );
  }
}
