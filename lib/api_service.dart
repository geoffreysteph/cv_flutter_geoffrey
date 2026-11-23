// lib/api_service.dart
// Regroupe tous les appels vers l'API REST.
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // pour indiquer le type de l'image
import 'package:image_picker/image_picker.dart'; // type XFile (photo choisie)

import 'membre.dart';

class ApiService {
  // 👉 Adresse de base de l'API (WAMP sur le port 8080).
  // - Chrome / Windows : localhost
  // - Émulateur Android : remplacez "localhost" par "10.0.2.2"
  // - Vrai téléphone   : remplacez "localhost" par l'adresse IP de votre PC
  static const String baseUrl = 'http://localhost:8080/api-test/public';

  // Lit la réponse de l'API : null = succès, sinon le message d'erreur.
  static String? _erreur(http.Response r) {
    final data = jsonDecode(r.body);
    if (data['success'] == true) return null;
    final errors = data['errors'];
    // L'API détaille les champs invalides dans "errors"
    if (errors is Map && errors.isNotEmpty) return errors.values.join('\n');
    return data['message']?.toString() ?? 'Erreur';
  }

  // ---------- CONNEXION ----------
  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _erreur(response);
  }

  // ---------- LISTE DES MEMBRES (GET) ----------
  static Future<List<Membre>> getMembres() async {
    final response = await http.get(Uri.parse('$baseUrl/famille-membres'));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final liste = data['data'] as List;
      return liste
          .map((e) => Membre.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(data['message'] ?? 'Erreur de chargement');
  }

  // ---------- AJOUT / MODIFICATION ----------
  // id == null  -> création  : POST /famille-membres
  // id != null  -> modification :
  //     sans nouvelle photo : PUT  /famille-membres/{id}  (JSON, photo conservée)
  //     avec nouvelle photo : POST /famille-membres/{id}  (form-data)
  // Retourne null si OK, sinon le message d'erreur.
  static Future<String?> saveMembre({
    int? id,
    required Map<String, String> champs,
    XFile? image,
  }) async {
    final modification = id != null;

    // Cas particulier : modification sans changer la photo -> PUT en JSON
    if (modification && image == null) {
      final r = await http.put(
        Uri.parse('$baseUrl/famille-membres/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(champs),
      );
      return _erreur(r);
    }

    // Sinon : envoi en multipart/form-data (champs + éventuelle photo)
    final url = modification
        ? '$baseUrl/famille-membres/$id'
        : '$baseUrl/famille-membres';
    final req = http.MultipartRequest('POST', Uri.parse(url));
    req.fields.addAll(champs);

    if (image != null) {
      // Type de l'image déduit de l'extension du fichier
      final nom = image.name.toLowerCase();
      final type = nom.endsWith('.png')
          ? 'png'
          : nom.endsWith('.gif')
          ? 'gif'
          : nom.endsWith('.webp')
          ? 'webp'
          : 'jpeg';
      req.files.add(
        http.MultipartFile.fromBytes(
          'image',
          await image.readAsBytes(),
          filename: image.name,
          contentType: MediaType('image', type),
        ),
      );
    }

    final r = await http.Response.fromStream(await req.send());
    return _erreur(r);
  }

  // ---------- SUPPRESSION (DELETE) ----------
  static Future<String?> deleteMembre(int id) async {
    final r = await http.delete(Uri.parse('$baseUrl/famille-membres/$id'));
    return _erreur(r);
  }
}
