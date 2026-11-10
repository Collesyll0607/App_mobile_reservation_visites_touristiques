import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/utilisateur.dart';

/// Service d'Authentification & Gestion de Session connecté à MySQL (ms-patrimoine)
/// Responsable : Collé SYLL (Pôle 1 - Module Auth)
class AuthService {
  static const String _sessionKey = 'colle_auth_current_user';
  static const String _usersListKey = 'colle_auth_registered_users';
  static const String _apiAuthBase = 'http://127.0.0.1:8081/api/auth';

  static Utilisateur? _currentUser;

  /// Comptes pré-configurés pour le mode hors-ligne
  static final List<Map<String, dynamic>> _defaultAccounts = [
    {
      'id': 1,
      'nomComplet': 'Collé Syll (Touriste)',
      'email': 'touriste@uasz.sn',
      'motDePasse': '123456',
      'telephone': '+221 77 123 45 67',
      'role': 'TOURISTE',
      'languesParlees': 'Français, Wolof',
      'tarifGuideJournalier': null,
    },
    {
      'id': 101,
      'nomComplet': 'Mamadou Lamine Diedhiou',
      'email': 'guide@uasz.sn',
      'motDePasse': '123456',
      'telephone': '+221 77 412 34 56',
      'role': 'GUIDE',
      'languesParlees': 'Français, Diola, Wolof, Anglais',
      'tarifGuideJournalier': 10000.0,
    },
  ];

  /// Retourne l'utilisateur actuellement connecté
  static Future<Utilisateur?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    _currentUser = _mapToUser(map);
    return _currentUser;
  }

  /// Connexion avec email et mot de passe (Interroge MySQL via ms-patrimoine puis Fallback local)
  static Future<Utilisateur?> login(String email, String password) async {
    // 1. Tentative sur MySQL (API Spring Boot ms-patrimoine)
    try {
      final resp = await http
          .post(
            Uri.parse('$_apiAuthBase/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'motDePasse': password.trim(),
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (resp.statusCode == 200) {
        final map = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
        final user = _mapToUser(map);
        _currentUser = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, jsonEncode(map));
        return user;
      } else if (resp.statusCode == 401) {
        return null;
      }
    } catch (_) {
      // Serveur éteint : on bascule sur le stockage local
    }

    // 2. Fallback sur le stockage local SharedPreferences
    final accounts = await _getAllAccounts();
    for (final acc in accounts) {
      if (acc['email'].toString().toLowerCase() == email.trim().toLowerCase() &&
          acc['motDePasse'].toString() == password.trim()) {
        final user = _mapToUser(acc);
        _currentUser = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, jsonEncode(acc));
        return user;
      }
    }
    return null;
  }

  /// Inscription d'un nouvel utilisateur (Enregistre dans MySQL -> table comptes_mobile)
  static Future<Utilisateur> register({
    required String nomComplet,
    required String email,
    required String password,
    required String telephone,
    required String role,
    String? languesParlees,
    double? tarifGuideJournalier,
  }) async {
    final payload = {
      'nomComplet': nomComplet.trim(),
      'email': email.trim(),
      'motDePasse': password.trim(),
      'telephone': telephone.trim(),
      'role': role,
      'languesParlees': languesParlees,
      'tarifGuideJournalier': tarifGuideJournalier,
    };

    // 1. Enregistrement direct dans MySQL (patrimoinedb -> comptes_mobile) via ms-patrimoine
    try {
      final resp = await http
          .post(
            Uri.parse('$_apiAuthBase/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 3));

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final savedMap =
            jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, jsonEncode(savedMap));
        _currentUser = _mapToUser(savedMap);
        return _currentUser!;
      } else if (resp.statusCode == 409) {
        throw Exception('Un compte existe déjà avec cet email dans MySQL.');
      }
    } catch (e) {
      if (e.toString().contains('existe déjà')) rethrow;
      // Si serveur éteint, on continue vers l'enregistrement local
    }

    // 2. Fallback enregistrement local
    final accounts = await _getAllAccounts();
    final exists = accounts.any(
      (a) => a['email'].toString().toLowerCase() == email.trim().toLowerCase(),
    );
    if (exists) {
      throw Exception('Un compte existe déjà avec cet email.');
    }

    final newAccount = {
      'id': DateTime.now().millisecondsSinceEpoch % 100000,
      ...payload,
    };

    accounts.add(newAccount);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersListKey, jsonEncode(accounts));
    await prefs.setString(_sessionKey, jsonEncode(newAccount));

    _currentUser = _mapToUser(newAccount);
    return _currentUser!;
  }

  /// Réinitialisation du mot de passe oublié (Met à jour dans MySQL et en local)
  static Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    bool updatedInMysql = false;
    try {
      final resp = await http
          .post(
            Uri.parse('$_apiAuthBase/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'nouveauMotDePasse': newPassword.trim(),
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (resp.statusCode == 200) {
        updatedInMysql = true;
      } else if (resp.statusCode == 404) {
        throw Exception('Aucun compte trouvé avec cet email dans MySQL.');
      }
    } catch (e) {
      if (e.toString().contains('Aucun compte')) rethrow;
    }

    if (updatedInMysql) return;

    final accounts = await _getAllAccounts();
    int foundIndex = -1;
    for (int i = 0; i < accounts.length; i++) {
      if (accounts[i]['email'].toString().toLowerCase() ==
          email.trim().toLowerCase()) {
        foundIndex = i;
        break;
      }
    }

    if (foundIndex == -1) {
      throw Exception('Aucun compte trouvé avec cet email.');
    }

    accounts[foundIndex]['motDePasse'] = newPassword.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersListKey, jsonEncode(accounts));
  }

  /// Mise à jour du profil de l'utilisateur connecté
  static Future<Utilisateur> updateProfile({
    required String nomComplet,
    required String telephone,
    String? languesParlees,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) {
      throw Exception('Aucun utilisateur connecté.');
    }
    final currentMap = jsonDecode(raw) as Map<String, dynamic>;
    final id = currentMap['id'];

    try {
      await http
          .put(
            Uri.parse('$_apiAuthBase/profile/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nomComplet': nomComplet.trim(),
              'telephone': telephone.trim(),
              'languesParlees': languesParlees?.trim(),
            }),
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {}

    currentMap['nomComplet'] = nomComplet.trim();
    currentMap['telephone'] = telephone.trim();
    currentMap['languesParlees'] = languesParlees?.trim();

    await prefs.setString(_sessionKey, jsonEncode(currentMap));
    _currentUser = _mapToUser(currentMap);
    return _currentUser!;
  }

  /// Déconnexion
  static Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  static Future<List<Map<String, dynamic>>> _getAllAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersListKey);
    if (raw == null) {
      return List<Map<String, dynamic>>.from(_defaultAccounts);
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Utilisateur _mapToUser(Map<String, dynamic> map) {
    return Utilisateur(
      id: (map['id'] ?? 1) as int,
      nomComplet: (map['nomComplet'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      telephone: (map['telephone'] ?? '').toString(),
      role: (map['role'] ?? 'TOURISTE').toString(),
      languesParlees: map['languesParlees']?.toString(),
      tarifGuideJournalier: map['tarifGuideJournalier'] != null
          ? (map['tarifGuideJournalier'] as num).toDouble()
          : null,
    );
  }
}
