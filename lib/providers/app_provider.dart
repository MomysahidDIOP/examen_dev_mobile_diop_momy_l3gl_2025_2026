import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isOnboardingComplete => StorageService.instance.isOnboardingComplete;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.instance.init();

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await StorageService.instance.setOnboardingComplete(true);
    notifyListeners();
  }
}