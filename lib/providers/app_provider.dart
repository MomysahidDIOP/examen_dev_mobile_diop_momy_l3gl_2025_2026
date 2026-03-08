import 'package:flutter/material.dart';
import '../services/storage_service.dart';

// AppProvider est la classe qui gère l'état GLOBAL de l'application.
//on  gere deux choses :
//   1. Est-ce que l'app a fini de s'initialiser ?
//   2. Est-ce que l'utilisateur a déjà vu l'onboarding ?

class AppProvider extends ChangeNotifier {

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isOnboardingComplete = false;


  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isOnboardingComplete => _isOnboardingComplete;

  // ============================================================
  // MÉTHODE init() - Le point de départ de toute l'application
  // ============================================================
  // Son role :C préparer l'application et charger les données sauvegardées.
  Future<void> init() async {

    // ETAPE 1 : On démarre le chargement
    _isLoading = true;
    notifyListeners();

    // ETAPE 2 : On initialise SharedPreferences
    await StorageService.instance.init();

    // ETAPE 3 : On lit d si l'onboarding a déjà été fait

    _isOnboardingComplete = StorageService.instance.isOnboardingComplete;

    // ETAPE 4 : L'initialisation est terminée
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // MÉTHODE completeOnboarding() - L'utilisateur a fini l'onboarding
  // ============================================================

  // Cette méthode on va l' appeler quand l'utilisateur clique sur "Commencer"
  // à la fin de l'OnboardingScreen.
  Future<void> completeOnboarding() async {

    _isOnboardingComplete = true;

    await StorageService.instance.setOnboardingComplete(true);
    notifyListeners();
  }

  // ============================================================
  // MÉTHODE resetOnboarding() - on  Remet l'onboarding à zéro
  // ============================================================

  // Cette méthode c'est l'inverse completeOnboarding().
  // Elle remet _isOnboardingComplete à false.

  Future<void> resetOnboarding() async {

    _isOnboardingComplete = false;
    await StorageService.instance.setOnboardingComplete(false);
    notifyListeners();
  }
}