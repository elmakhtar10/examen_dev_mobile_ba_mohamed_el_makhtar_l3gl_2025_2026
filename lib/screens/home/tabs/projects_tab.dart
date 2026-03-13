import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/Project.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';
import 'package:uuid/uuid.dart';

void showCreateProjectDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final projectProv = Provider.of<ProjectProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.newProject),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: AppStrings.projectTitleLabel,
                hintText: AppStrings.projectTitleHint,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: AppStrings.projectDescriptionOptional,
                hintText: AppStrings.projectDescriptionHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && auth.currentUser != null) {
                final newProject = Project(
                  id: const Uuid().v4(),
                  userId: auth.currentUser!.id,
                  title: titleController.text,
                  description: descController.text,
                  createdAt: DateTime.now(),
                  isCompleted: false,
                );

                projectProv.createProject(newProject);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(AppStrings.create, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
  );
}

void showEditProjectDialog(BuildContext context, Project project) {
  final TextEditingController titleController = TextEditingController(text: project.title);
  final TextEditingController descController = TextEditingController(text: project.description);

  final projectProv = Provider.of<ProjectProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(AppStrings.editProject),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: AppStrings.projectTitleLabel,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: AppStrings.projectDescriptionOptional,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isNotEmpty) {
              final updated = project.copyWith(
                title: titleController.text,
                description: descController.text,
              );
              projectProv.updateProject(updated);
              Navigator.pop(dialogContext);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text(AppStrings.save, style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void showDeleteProjectDialog(BuildContext context, Project project) {
  final projectProv = Provider.of<ProjectProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(AppStrings.deleteProject),
      content: Text(
        "${AppStrings.confirmDeleteProjectPrefix} \"${project.title}\" ? ${AppStrings.confirmDeleteProjectSuffix}",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            projectProv.deleteProject(project.id);
            Navigator.pop(dialogContext);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(AppStrings.delete, style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final projects = projectProvider.projects;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: Builder(
        builder: (innerContext) => FloatingActionButton(
          onPressed: () => showCreateProjectDialog(innerContext),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: projects.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ProjectCard(
            project: project,
            onTap: () {},
            onEdit: (p) => showEditProjectDialog(context, p),
            onDelete: (_) => showDeleteProjectDialog(context, project),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            AppStrings.emptyProjectsTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const Text(AppStrings.emptyProjectsSubtitle),
        ],
      ),
    );
  }
}




