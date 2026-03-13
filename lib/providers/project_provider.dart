import 'package:flutter/material.dart';

import '../models/Project.dart';
import '../services/storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;

  final StorageService _storage = StorageService.instance;

  // Charge les projets depuis le stockage local
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    // On récupère tout et on filtre par l'ID de l'utilisateur connecté
    List<Project> allProjects = _storage.getProjects();
    _projects = allProjects.where((p) => p.userId == userId).toList();

    _isLoading = false;
    notifyListeners();

  }

  Future<void> createProject(Project project) async {
    await _storage.saveProject(project);
    _projects.add(project); // Mise à jour locale pour la réactivité
    notifyListeners();
  }

  Future<void> updateProject(Project project) async {
    await _storage.saveProject(project); // saveProject gère déjà l'update si l'ID existe
    int index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    await _storage.deleteProject(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    if (_selectedProject?.id == projectId) _selectedProject = null;
    notifyListeners();
  }

  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }
}