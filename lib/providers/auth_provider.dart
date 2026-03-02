import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/User.dart';
import '../services/storage_service.dart';


class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;


  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // on  recuperer les utilisateurs
      final users = StorageService.instance.getUsers();

      // on Chercher l'utilisateur
      final user = users.firstWhere(
            (u) => u.email == email && u.password == password,
        orElse: () => throw Exception("Identifiants incorrects"),
      );

      _currentUser = user;
      await StorageService.instance.setCurrentUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      final List<User> users = StorageService.instance.getUsers();

      if (users.any((u) => u.email == email)) {
        throw Exception("Cet email est déjà utilisé");
      }

      final newUser = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
      );


      users.add(newUser);


      await StorageService.instance.saveUsers(users);

      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    StorageService.instance.logout();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}