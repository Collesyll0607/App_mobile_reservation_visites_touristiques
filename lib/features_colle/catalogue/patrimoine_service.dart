import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../../core/models/patrimoine.dart';

/// Résultat d'appel au service Patrimoine (avec indication de la source)
class PatrimoineFetchResult {
  final List<Patrimoine> sites;
  final bool fromApiRest;
  final String? errorMessage;

  const PatrimoineFetchResult({
    required this.sites,
    required this.fromApiRest,
    this.errorMessage,
  });
}

/// Service HTTP de récupération du Catalogue des Sites Touristiques
/// Responsable : Collé SYLL (Pôle 1 - Module Catalogue & API REST)
class PatrimoineService {
  static const List<String> _candidateUrls = [
    'http://127.0.0.1:8081/api/patrimoines',
    'http://10.0.2.2:8081/api/patrimoines',
  ];

  /// Récupère les sites depuis le microservice Spring Boot (ms-patrimoine)
  /// et fournit une erreur explicite + cache local en cas d'indisponibilité réseau.
  static Future<PatrimoineFetchResult> fetchPatrimoines() async {
    String lastReason = 'Serveur backend ms-patrimoine injoignable (port 8081).';

    for (final url in _candidateUrls) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is List && decoded.isNotEmpty) {
            final parsed = decoded
                .map((item) =>
                    Patrimoine.fromJson(item as Map<String, dynamic>))
                .toList();
            return PatrimoineFetchResult(
              sites: parsed,
              fromApiRest: true,
              errorMessage: null,
            );
          }
          lastReason = 'Catalogue backend vide sur $url.';
        } else {
          lastReason =
              'Réponse HTTP ${response.statusCode} du serveur ms-patrimoine.';
        }
      } catch (e) {
        lastReason = 'Connexion impossible au serveur ($e).';
      }
    }

    // Mode dégradé (Fallback local) avec message d'erreur explicite
    return PatrimoineFetchResult(
      sites: ApiConfig.sitesCasamance,
      fromApiRest: false,
      errorMessage: lastReason,
    );
  }
}
