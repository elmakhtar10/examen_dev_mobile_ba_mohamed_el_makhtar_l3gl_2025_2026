import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/Project.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:uuid/uuid.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  void _showCreateProjectDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final authProvider = context.read<AuthProvider>();
    final projectProvider = context.read<ProjectProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouveau Projet"),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Titre du projet",
            hintText: "Ex: Soutenance L3GL",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && authProvider.currentUser != null) {
                final newProject = Project(
                  id: const Uuid().v4(),
                  userId: authProvider.currentUser!.id,
                  title: titleController.text,
                  description: '',
                  createdAt: DateTime.now(),
                  isCompleted: false,
                );

                projectProvider.createProject(newProject);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Créer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => projectProvider.loadProjects(authProvider.currentUser!.id),
        color: AppColors.primary,
        child: projectProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : projectProvider.projects.isEmpty
            ? _buildEmptyState()
            : _buildProjectList(projectProvider.projects),
      ),
    );
  }

  Widget _buildProjectList(List<Project> projects) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) => _buildProjectCard(projects[index]),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: project.isCompleted ? Colors.green : AppColors.primary,
          child: Icon(
              project.isCompleted ? Icons.check : Icons.work,
              color: Colors.white
          ),
        ),
        title: Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Créé le ${project.createdAt.day}/${project.createdAt.month}"),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("Aucun projet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("Commencez par en ajouter un."),
        ],
      ),
    );
  }
}