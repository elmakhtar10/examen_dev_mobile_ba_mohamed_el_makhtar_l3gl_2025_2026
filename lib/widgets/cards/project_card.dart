import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/Project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final Function(Project) onEdit;
  final Function(String) onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // PASTILLE DE COULEUR (Ou icône par défaut)
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: project.isCompleted ? Colors.green.withAlpha(30) : AppColors.primary.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            project.isCompleted ? Icons.check_circle : Icons.folder,
            color: project.isCompleted ? Colors.green : AppColors.primary,
          ),
        ),

        // NOM ET DESCRIPTION
        title: Text(
          project.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.description.isNotEmpty)
              Text(
                project.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            const SizedBox(height: 4),
            const Text(
              "0 tâche",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),

        // MENU CONTEXTUEL (Modifier / Supprimer)
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'edit') {
              onEdit(project);
            } else if (value == 'delete') {
              onDelete(project.id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Modifier"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Supprimer"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}