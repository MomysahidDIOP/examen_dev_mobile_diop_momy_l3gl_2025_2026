import 'package:flutter/material.dart';
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

  void logout() {
    _currentUser = null;
    StorageService.instance.logout();
    notifyListeners();
  }
}