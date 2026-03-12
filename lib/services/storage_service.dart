import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/User.dart';

/**
 * Pattern Singleton:
 * Pour avoir une seule instance
 */
class StorageService {
  //===== Singleton ==========
  /// Instance Unique (privee)
  static StorageService? _instance;

  /// Getter pour acceder a l'instance
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Constructeur prive
  StorageService._();

  //===== SharedPreferences ==========
  /**
   * SharedPreferences utilise des opérations asynchrones
   * car il lit/ecrtit sur le disque
   *
   * Le mot-cle await attend que l'operation se termine
   * La fonction doit etre marque async et retourner un Future
   * Les variables doivent être marqué par late
   */
  late SharedPreferences _prefs;

  /// Indicateur d'initialisation
  bool _initialized = false;

  Future<void> init() async {
    if(_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Cles de Stockage =========
  static const String _keyOnboardingConmplete = 'onboarding_complete';
  static const String _keyUsers = 'users_list';
  static const String _keyCurrentUser = 'current_user';



  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingConmplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingConmplete, value);
  }

  List<User> getUsers() {

    String? jsonString = _prefs.getString(_keyUsers);

    if (jsonString == null) {
      return [];
    }

    List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((item) => User.fromMap(item)).toList();
  }

  Future<void> saveAuthenticatedUser(User user) async {
    String jsonString = json.encode(user.toMap());
    await _prefs.setString(_keyCurrentUser, jsonString);
  }

  User? getAuthenticatedUser() {
    String? userJson = _prefs.getString(_keyCurrentUser);

    if (userJson == null) {
      return null;
    }

    return User.fromMap(json.decode(userJson));

  }

  Future<void> saveUser(User user) async {

    List<User> users = getUsers();

    users.add(user);

    String jsonString = json.encode(users.map((u) => u.toMap()).toList());

    await _prefs.setString(_keyUsers, jsonString);
  }

  // Supprime l'utilisateur connecter
  Future<void> clearAuthenticatedUser() async {
    await _prefs.remove(_keyCurrentUser);
  }

}