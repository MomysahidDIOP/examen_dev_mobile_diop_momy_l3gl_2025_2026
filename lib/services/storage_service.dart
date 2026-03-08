import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';
import '../models/Project.dart';
import '../models/Task.dart';
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

  // ============================================================
  // SHARED PREFERENCES
  // ============================================================

  // "late" veut dire : cette variable sera initialisée plus tard (pas maintenant)
  // On ne peut pas l'initialiser ici car SharedPreferences.getInstance() est asynchrone
  late SharedPreferences _prefs;
  bool _initialized = false;

  // avant d'utiliser n'importe quelle autre méthode de cette classe
  Future<void> init() async {
    if (_initialized) return; // Si déjà initialisé, on ne refait pas le travail
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ============================================================
  // CLÉS DE STOCKAGE
  // ============================================================
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyUsers = 'users';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyProjects = 'projects';
  static const String _keyTasks = 'tasks';

  // ============================================================
  // ONBOARDING
  // ============================================================

  // "?? false" : si la clé n'existe pas encore, on retourne false par défaut
  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // Sauvegarde si l'onboarding est complété (true) ou non (false)
  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  // ============================================================
  // UTILISATEURS
  // ============================================================

  // Récupère la liste de tous les utilisateurs enregistrés
  // Les données sont stockées en JSON (texte), on les convertit en objets User
  List<User> getUsers() {
    final String? usersJson = _prefs.getString(_keyUsers);
    if (usersJson == null) return []; // Pas encore d'utilisateurs = liste vide
    final List<dynamic> decodedData = json.decode(usersJson);
    return decodedData.map((item) => User.fromMap(item)).toList();
  }

  // Sauvegarde la liste complète des utilisateurs
  // On convertit les objets User en Map (toMap()) puis en JSON (texte)
  Future<void> saveUsers(List<User> users) async {
    final List<Map<String, dynamic>> usersList =
    users.map((user) => user.toMap()).toList();
    final String encodedData = json.encode(usersList);
    await _prefs.setString(_keyUsers, encodedData);
  }

  // Sauvegarde l'utilisateur actuellement connecté
  // Pour le retrouver au prochain démarrage sans redemander la connexion
  Future<void> setCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, json.encode(user.toMap()));
  }

  // Récupère l'utilisateur connecté
  User? getCurrentUser() {
    final String? userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromMap(json.decode(userJson));
  }

  // Supprime la session de l'utilisateur connecté (déconnexion)
  Future<void> logout() async {
    await _prefs.remove(_keyCurrentUser);
  }

  // ============================================================
  //  NOUVEAU  PROJETS
  // ============================================================

  // Récupère la liste de TOUS les projets (tous utilisateurs confondus)
  // ProjectProvider.loadProjects() filtrera ensuite par userId
  List<Project> getProjects() {
    final String? projectsJson = _prefs.getString(_keyProjects);
    if (projectsJson == null) return []; // Pas encore de projets = liste vide
    final List<dynamic> decodedData = json.decode(projectsJson);
    return decodedData.map((item) => Project.fromMap(item)).toList();
  }

  // Sauvegarde la liste complète des projets
  // Même principe que saveUsers() : on convertit en JSON puis on stocke
  Future<void> saveProjects(List<Project> projects) async {
    final String encodedData =
    json.encode(projects.map((p) => p.toMap()).toList());
    await _prefs.setString(_keyProjects, encodedData);
  }

  // ============================================================
  //   NOUVEAU TACHES
  // ============================================================

  // Récupère la liste de TOUTES les taches (tous projets confondus)
  // TaskProvider.loadTasks() filtrera ensuite par projectId
  List<Task> getTasks() {
    final String? tasksJson = _prefs.getString(_keyTasks);
    if (tasksJson == null) return []; // Pas encore de tâches = liste vide
    final List<dynamic> decodedData = json.decode(tasksJson);
    return decodedData.map((item) => Task.fromMap(item)).toList();
  }

  // Sauvegarde la liste complète des tâches
  Future<void> saveTasks(List<Task> tasks) async {
    final String encodedData =
    json.encode(tasks.map((t) => t.toMap()).toList());
    await _prefs.setString(_keyTasks, encodedData);
  }
}