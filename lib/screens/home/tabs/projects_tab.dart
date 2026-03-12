import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/app_provider.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  // Fenêtre pour créer un projet
  void _showCreateProjectDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouveau Projet"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Nom du projet",
            hintText: "Ex: Application SunuTask",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                // Ici on appellera la méthode du provider plus tard
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
    final appProvider = context.read<AppProvider>();

    return Scaffold(
      // Bouton "+" flottant en bas à droite
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: appProvider,
        builder: (context, child) {
          // Simulation : liste vide pour l'instant
          final List<dynamic> projects = [];

          return RefreshIndicator(
            onRefresh: () => appProvider.init(),
            color: AppColors.primary,
            child: projects.isEmpty
                ? _buildEmptyState()
                : _buildProjectList(projects),
          );
        },
      ),
    );
  }

  // === LES COMPOSANTS VISUELS ===

  // Widget affiché quand il n'y a pas de projet
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "Aucun projet trouvé",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text("Appuyez sur + pour en créer un."),
          ],
        ),
      ),
    );
  }

  // Liste scrollable des projets
  Widget _buildProjectList(List<dynamic> projects) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) => _buildProjectCard(),
    );
  }

  // Design d'une carte projet
  Widget _buildProjectCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.folder, color: Colors.white),
        ),
        title: const Text("Mon Projet Personnel", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("2 tâches en cours"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}