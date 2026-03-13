import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  bool _isOnboardingComplete = false;
  bool _isInitialized = false;
  bool _isLoading = false;

  // Getters publics
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  // Initialisation au démarrage

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // On s'assure que StorageService est prêt
    await StorageService.instance.init();

    // Récupération de l'état
    _isOnboardingComplete = StorageService.instance.isOnboardingComplete;

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // Marquer l'onboarding comme terminé

  Future<void> completeOnboarding() async {
    await StorageService.instance.setOnboardingComplete(true);
    _isOnboardingComplete = true;
    notifyListeners();
  }

  // Réinitialiser pour les tests

  Future<void> resetOnboarding() async {
    await StorageService.instance.setOnboardingComplete(false);
    _isOnboardingComplete = false;
    notifyListeners();
  }
}