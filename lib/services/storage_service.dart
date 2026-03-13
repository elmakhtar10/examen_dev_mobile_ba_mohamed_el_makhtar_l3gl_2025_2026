import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/Project.dart';
import '../models/Task.dart';
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
  static const String _keyProjects = 'projects_list';
  static const String _keyTasks = 'tasks_list';



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

  // --- Gestion des Projets ---

  /// Récupère tous les projets stockés
  List<Project> getProjects() {
    String? jsonString = _prefs.getString(_keyProjects);
    if (jsonString == null) return [];

    List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => Project.fromMap(item)).toList();
  }

  /// Sauvegarde un nouveau projet (ou l'ajoute à la liste existante)
  Future<void> saveProject(Project project) async {
    List<Project> projects = getProjects();

    // On vérifie si le projet existe déjà pour éviter les doublons (update ou add)
    int index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
    } else {
      projects.add(project);
    }

    String jsonString = json.encode(projects.map((p) => p.toMap()).toList());
    await _prefs.setString(_keyProjects, jsonString);
  }

  /// Supprime un projet par son ID
  Future<void> deleteProject(String projectId) async {
    List<Project> projects = getProjects();
    projects.removeWhere((p) => p.id == projectId);

    String jsonString = json.encode(projects.map((p) => p.toMap()).toList());
    await _prefs.setString(_keyProjects, jsonString);
  }

  // --- Gestion des Taches ---

  List<Task> getTasks() {
    String? jsonString = _prefs.getString(_keyTasks);
    if (jsonString == null) return [];

    List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => Task.fromMap(item)).toList();
  }

  Future<void> saveTask(Task task) async {
    List<Task> tasks = getTasks();

    int index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }

    String jsonString = json.encode(tasks.map((t) => t.toMap()).toList());
    await _prefs.setString(_keyTasks, jsonString);
  }

  Future<void> deleteTask(String taskId) async {
    List<Task> tasks = getTasks();
    tasks.removeWhere((t) => t.id == taskId);

    String jsonString = json.encode(tasks.map((t) => t.toMap()).toList());
    await _prefs.setString(_keyTasks, jsonString);
  }

}
