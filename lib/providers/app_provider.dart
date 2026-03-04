import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isOnboardingComplete = false; // Variable locale pour la réactivité

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isOnboardingComplete => _isOnboardingComplete;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // 1. Initialise le stockage (SharedPreferences)
    await StorageService.instance.init();

    // 2. Récupère la valeur sauvegardée précédemment
    _isOnboardingComplete = StorageService.instance.isOnboardingComplete;

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // Cette méthode fait le pont entre l'UI (bouton Commencer) et le stockage
  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true; // On change l'état local
    await StorageService.instance.setOnboardingComplete(true); // On sauvegarde
    notifyListeners(); // On prévient toute l'application
  }
}