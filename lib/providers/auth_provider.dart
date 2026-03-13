import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_strings.dart';
import '../models/User.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  // Propriétés privées

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters publics
  User? get currentUser => _currentUser;

  bool get isAuthenticated =>
      _currentUser != null; // true si _currentUser !=null
  bool get isLoading => _isLoading;

  String? get error => _error;

  // Charge l'utilisateur depuis le stockage au démarrage
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await StorageService.instance.getAuthenticatedUser();

    _isLoading = false;
    notifyListeners();
  }

  /// Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<User> users = StorageService.instance.getUsers();

      User? foundUser;
      for (var u in users) {
        if (u.email == email && u.password == password) {
          foundUser = u;
          break;
        }
      }

      if (foundUser != null) {
        _currentUser = foundUser;
        await StorageService.instance.saveAuthenticatedUser(foundUser);
        _isLoading = false;
        notifyListeners();
        return true; // Connexion réussie
      } else {
        _error = AppStrings.invalidInput;
        _isLoading = false;
        notifyListeners();
        return false; // Échec
      }
    } catch (e) {
      _error = AppStrings.errorOccurred;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<User> users = StorageService.instance.getUsers();
      bool exists = users.any((u) => u.email == email);

      if (exists) {
        _error = "Cet email est déjà utilisé par un autre compte";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      var uuid = const Uuid();
      User newUser = User(
        id: uuid.v4(),
        name: name,
        email: email,
        password: password,
        avatar: "",
        createdAt: DateTime.now(),
      );

      // 3. Sauvegarder via StorageService (dans la liste globale)
      await StorageService.instance.saveUser(newUser);

      // 4. Définir comme utilisateur courant (Session)
      await StorageService.instance.saveAuthenticatedUser(newUser);
      _currentUser = newUser;

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = "Erreur lors de la création du compte";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deconnexion
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.instance.clearAuthenticatedUser();

    _currentUser = null;

    _isLoading = false;
    notifyListeners();
  }

}