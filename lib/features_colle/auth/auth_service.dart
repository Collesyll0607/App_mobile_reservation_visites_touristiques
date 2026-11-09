import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/utilisateur.dart';

/// Service d'Authentification & Gestion de Session
/// Responsable : Collé SYLL (Pôle 1 - Module Auth)
class AuthService {
  static const String _sessionKey = 'colle_auth_current_user';
  static const String _usersListKey = 'colle_auth_registered_users';

  static Utilisateur? _currentUser;

  /// Comptes pré-configurés pour les tests et la soutenance
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

  /// Connexion avec email et mot de passe
  static Future<Utilisateur?> login(String email, String password) async {
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

  /// Inscription d'un nouvel utilisateur (Touriste ou Guide)
  static Future<Utilisateur> register({
    required String nomComplet,
    required String email,
    required String password,
    required String telephone,
    required String role,
    String? languesParlees,
    double? tarifGuideJournalier,
  }) async {
    final accounts = await _getAllAccounts();

    // Vérifier si l'email existe déjà
    final exists = accounts.any(
      (a) => a['email'].toString().toLowerCase() == email.trim().toLowerCase(),
    );
    if (exists) {
      throw Exception('Un compte existe déjà avec cet email.');
    }

    final newAccount = {
      'id': DateTime.now().millisecondsSinceEpoch % 100000,
      'nomComplet': nomComplet.trim(),
      'email': email.trim(),
      'motDePasse': password.trim(),
      'telephone': telephone.trim(),
      'role': role,
      'languesParlees': languesParlees,
      'tarifGuideJournalier': tarifGuideJournalier,
    };

    accounts.add(newAccount);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersListKey, jsonEncode(accounts));
    await prefs.setString(_sessionKey, jsonEncode(newAccount));

    _currentUser = _mapToUser(newAccount);
    return _currentUser!;
  }

  /// Réinitialisation du mot de passe oublié à partir de l'adresse email
  static Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
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
      id: map['id'] ?? 1,
      nomComplet: map['nomComplet'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'] ?? '',
      role: map['role'] ?? 'TOURISTE',
      languesParlees: map['languesParlees'],
      tarifGuideJournalier: map['tarifGuideJournalier'] != null
          ? (map['tarifGuideJournalier'] as num).toDouble()
          : null,
    );
  }
}
