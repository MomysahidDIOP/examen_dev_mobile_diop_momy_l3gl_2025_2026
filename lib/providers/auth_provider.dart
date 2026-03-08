import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/User.dart';
import '../services/storage_service.dart';

// AuthProvider est la classe qui gere tout ce qui concerne l'authentification.
// Elle extends ChangeNotifier ce qui veut dire qu'elle peut NOTIFIER les widgets
// quand quelque chose change (ex: utilisateur connecté, erreur, chargement...)
class AuthProvider extends ChangeNotifier {

  // ============================================================
  // PROPRIÉTÉS PRIVÉES (état interne de l'authentification)
  // ============================================================

  // L'utilisateur actuellement connecté.
  // Le "?" veut dire qu'il peut être null (personne n'est connecté)
  User? _currentUser;

  // Indique si une opération est en cours (connexion, inscription...)
  // Sert à afficher un indicateur de chargement dans l'interface
  bool _isLoading = false;

  // Stocke le message d'erreur si quelque chose se passe mal
  // Ex: "Identifiants incorrects", "Email déjà utilisé"
  String? _error;

  // ============================================================
  // GETTERS PUBLICS (ce que les widgets peuvent lire)
  // ============================================================

  // Les widgets peuvent lire l'utilisateur connecté mais pas le modifier directement
  User? get currentUser => _currentUser;

  // Retourne true si un utilisateur est connecté, false sinon
  // C'est une façon élégante de vérifier : si _currentUser n'est pas null = connecté
  bool get isAuthenticated => _currentUser != null;

  // Les widgets peuvent savoir si un chargement est en cours
  bool get isLoading => _isLoading;

  // Les widgets peuvent lire le message d'erreur
  String? get error => _error;

  // ============================================================
  // MÉTHODE init() - Appelée au démarrage de l'application

  // Cette méthode est appelée une seule fois quand l'app démarre (dans main.dart)
  // Elle vérifie si un utilisateur était déjà connecté avant de fermer l'app
  // Si oui, elle le recharge depuis SharedPreferences pour éviter de redemander la connexion
  // ============================================================


  Future<void> init() async {
    // On essaie de récupérer l'utilisateur sauvegardé dans SharedPreferences
    _currentUser = StorageService.instance.getCurrentUser();
    // On prévient les widgets que l'état a peut-être changé
    notifyListeners();
  }

  // ============================================================
  // MÉTHODE login() - Connexion d'un utilisateur existant
  // Prend l'email et le mot de passe saisis par l'utilisateur
  // Retourne true si la connexion réussit, false sinon
  // ============================================================


  Future<bool> login(String email, String password) async {

    // ÉTAPE 1 : On démarre le chargement
    // On met _isLoading à true pour afficher le spinner sur le bouton
    // On efface l'erreur précédente s'il y en avait une
    _isLoading = true;
    _error = null;
    notifyListeners(); // On prévient les widgets pour afficher le spinner

    try {
      // ÉTAPE 2 : On récupère tous les utilisateurs depuis SharedPreferences
      final users = StorageService.instance.getUsers();

      // ÉTAPE 3 : On cherche un utilisateur avec cet email ET ce mot de passe
      // firstWhere parcourt la liste et retourne le premier qui correspond
      // Si aucun ne correspond, orElse lance une Exception
      final user = users.firstWhere(
            (u) => u.email == email && u.password == password,
        orElse: () => throw Exception("Identifiants incorrects"),
      );

      // ÉTAPE 4 : Si on arrive ici, l'utilisateur a été trouvé !
      // On le sauvegarde comme utilisateur courant en mémoire
      _currentUser = user;
      // On le sauvegarde aussi dans SharedPreferences pour le retrouver au prochain démarrage
      await StorageService.instance.setCurrentUser(user);

      // On arrête le chargement et on notifie les widgets
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      // ÉTAPE 5 : Si une erreur s'est produite (identifiants incorrects ou autre)
      // On sauvegarde le message d'erreur pour l'afficher dans l'interface
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Connexion échouée
    }
  }

  // ============================================================
  // MÉTHODE register() - Inscription d'un nouvel utilisateur
  // Prend le nom, email et mot de passe du nouvel utilisateur
  // Retourne true si l'inscription réussit, false sinon
  // ============================================================


  Future<bool> register(String name, String email, String password) async {

    // ÉTAPE 1 : On démarre le chargement
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ÉTAPE 2 : On récupère la liste de tous les utilisateurs existants
      final List<User> users = StorageService.instance.getUsers();

      // ÉTAPE 3 : On vérifie qu'aucun utilisateur n'a déjà cet email
      // any() retourne true si AU MOINS UN élément de la liste correspond
      if (users.any((u) => u.email == email)) {
        throw Exception("Cet email est déjà utilisé");
      }

      // ÉTAPE 4 : On crée le nouvel utilisateur
      // Uuid().v4() génère un identifiant unique aléatoire (ex: "a3f2-b4c1-...")
      // C'est important pour que chaque utilisateur ait un ID unique
      final newUser = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
      );

      // ÉTAPE 5 : On ajoute le nouvel utilisateur à la liste
      users.add(newUser);
      // On sauvegarde la liste mise à jour dans SharedPreferences
      await StorageService.instance.saveUsers(users);

      // ÉTAPE 6 : On connecte automatiquement le nouvel utilisateur
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true; // Inscription réussie

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Inscription échouée
    }
  }

  // ============================================================
  // MÉTHODE updateProfile()
  // Permet à l'utilisateur de changer son nom ou son email

  // ============================================================


  Future<void> updateProfile({String? name, String? email}) async {

    // Si personne n'est connecté, on ne fait rien
    if (_currentUser == null) return;

    // ÉTAPE 1 : On crée une COPIE de l'utilisateur avec les nouvelles valeurs qvec copyzhite
    final updated = _currentUser!.copyWith(
      name: name,
      email: email,
    );

    // ÉTAPE 2 : On met à jour dans la liste complète des utilisateurs

    final users = StorageService.instance.getUsers();
    final index = users.indexWhere((u) => u.id == updated.id);
    if (index != -1) {
      users[index] = updated; // On remplace l'ancien par le nouveau
      await StorageService.instance.saveUsers(users);
    }

    // ÉTAPE 3 : On met aussi à jour la session courante dans SharedPreferences
    await StorageService.instance.setCurrentUser(updated);
    // Et en mémoire
    _currentUser = updated;
    notifyListeners(); // On prévient les widgets que le profil a changé
  }

  // ============================================================
  // MÉTHODE logout() - Déconnexion
  // ============================================================

  Future<void> logout() async {
    // On efface l'utilisateur de la mémoire
    _currentUser = null;
    // On efface aussi la session sauvegardée dans SharedPreferences
    // Comme ça, au prochain démarrage, l'app demandera la connexion
    await StorageService.instance.logout();
    // On prévient tous les widgets  plus personne n'est connecté
    notifyListeners();
  }

  // ============================================================
  // MÉTHODE clearError() - Effacer le message d'erreur
  // ============================================================


  void clearError() {
    _error = null;
    notifyListeners();
  }
}