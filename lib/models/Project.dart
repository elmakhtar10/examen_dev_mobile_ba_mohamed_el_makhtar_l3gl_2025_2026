import 'dart:convert';

class Project {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  bool isCompleted;

  Project({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.createdAt,
    this.isCompleted = false,
  });

  // --- Sérialisation JSON ---

  /// Convertit un objet Project en Map (pour SharedPreferences)
  // --- Sérialisation JSON ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  /// Crée un objet Project à partir d'une Map (depuis SharedPreferences)
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isCompleted: map['isCompleted'] ?? false,
    );
  }


  /// Méthode copyWith (mettre à jour un champ sans tout réécrire)
  Project copyWith({
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Project(
      id: this.id,
      userId: this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}