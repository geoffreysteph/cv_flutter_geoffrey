// lib/membre.dart
// Modèle : représente un membre de la famille tel que renvoyé par l'API.
import 'api_service.dart';

class Membre {
  final int id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance; // format AAAA-MM-JJ
  final String parente;
  final String?
  image; // chemin relatif, ex : uploads/famille/xxx.jpg (peut être null)

  Membre({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.image,
  });

  // Transforme le JSON de l'API en objet Membre
  factory Membre.fromJson(Map<String, dynamic> json) {
    return Membre(
      id: int.parse(json['id'].toString()),
      nom: json['nom'] ?? '',
      postnom: json['postnom'] ?? '',
      prenom: json['prenom'] ?? '',
      lieuNaissance: json['lieu_naissance'] ?? '',
      dateNaissance: json['date_naissance'] ?? '',
      parente: json['parente'] ?? '',
      image: json['image'],
    );
  }

  // Adresse complète de la photo (null si le membre n'a pas d'image)
  String? get imageUrl =>
      image == null || image!.isEmpty ? null : '${ApiService.baseUrl}/$image';
}
