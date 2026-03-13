import 'package:flutter/material.dart';

import '../models/Task.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  Task? _selectedTask;
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  Task? get selectedTask => _selectedTask;
  int get taskCount => _tasks.length;
  bool get isLoading => _isLoading;

  final StorageService _storage = StorageService.instance;

  Future<void> loadTasks(String userId) async {
    _isLoading = true;
    notifyListeners();

    List<Task> allTasks = _storage.getTasks();
    _tasks = allTasks.where((t) => t.userId == userId).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createTask(Task task) async {
    await _storage.saveTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _storage.saveTask(task);
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _storage.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    if (_selectedTask?.id == taskId) _selectedTask = null;
    notifyListeners();
  }

  void selectTask(Task? task) {
    _selectedTask = task;
    notifyListeners();
  }
}
