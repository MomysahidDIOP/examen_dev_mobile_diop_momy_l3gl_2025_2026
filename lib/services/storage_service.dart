import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';

/**
 * Pattern singleton : cette classe n'aura qu'un seul objet unique
 */
class StorageService {
  //============ Singleton ============
  static StorageService? _instance;

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  StorageService._();

  //================= SharedPreferences ==============
  // Late car l'initialisation est asynchrone
  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  //=============== Clés de stockage ==============
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyUsers = 'users';
  static const String _keyCurrentUser = 'current_user';

  // --- ONBOARDING ---
  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }


  // Récupérer la liste des utilisateurs (indispensable pour le login)
  List<User> getUsers() {
    final String? usersJson = _prefs.getString(_keyUsers);
    if (usersJson == null) return [];
    final List<dynamic> decodedData = json.decode(usersJson);
    return decodedData.map((item) => User.fromMap(item)).toList();
  }

  // Sauvegarder un nouvel utilisateur (indispensable pour le register)
  Future<void> saveUsers(List<User> users) async {
    final List<Map<String, dynamic>> usersList = users.map((user) => user.toMap()).toList();
    final String encodedData = json.encode(usersList);
    await _prefs.setString(_keyUsers, encodedData);
  }

  // Gérer la session de l'utilisateur connecté
  Future<void> setCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, json.encode(user.toMap()));
  }

  User? getCurrentUser() {
    final String? userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromMap(json.decode(userJson));
  }

  Future<void> logout() async {
    await _prefs.remove(_keyCurrentUser);
  }



}