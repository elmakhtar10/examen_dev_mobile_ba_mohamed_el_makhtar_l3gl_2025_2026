import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/app_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Bonjour";
    if (hour < 18) return "Bon après-midi";
    return "Bonsoir";
  }

  @override
  Widget build(BuildContext context) {
    // On écoute les trois providers nécessaires
    final appProvider = context.watch<AppProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final authProvider = context.read<AuthProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await appProvider.init();
        if (authProvider.currentUser != null) {
          await projectProvider.loadProjects(authProvider.currentUser!.id);
        }
      },
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(authProvider.currentUser?.name ?? "l'ami"),

          const SizedBox(height: 24),

          // Section Statistiques avec les VRAIES données
          appProvider.isLoading || projectProvider.isLoading
              ? const Center(child: LinearProgressIndicator())
              : _buildStatsGrid(projectProvider),

          const SizedBox(height: 24),

          _buildRecentProjectsHeader(),

          // Affichage des 3 derniers projets réels s'ils existent
          if (projectProvider.projects.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Aucun projet récent", textAlign: TextAlign.center),
            )
          else
            ...projectProvider.projects.reversed.take(3).map((project) {
              return _buildRecentProjectItem(project.title, "Projet");
            }),
        ],
      ),
    );
  }

  // --- COMPOSANTS DE L'INTERFACE ---

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_getGreeting()}, $name !",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Voici un aperçu de vos activités.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(ProjectProvider provider) {
    // Calcul des statistiques réelles
    int totalProjects = provider.projectCount;
    int completedProjects = provider.projects.where((p) => p.isCompleted).length;
    int inProgress = totalProjects - completedProjects;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("Projets", "$totalProjects", Icons.folder, Colors.blue),
        _buildStatCard("À faire", "0", Icons.assignment, Colors.orange), // Sera lié aux tâches
        _buildStatCard("En cours", "$inProgress", Icons.pending, Colors.purple),
        _buildStatCard("Terminés", "$completedProjects", Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProjectsHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Projets récents",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: null, child: Text("Voir tout")),
      ],
    );
  }

  Widget _buildRecentProjectItem(String name, String type) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.folder, color: AppColors.primary),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(type),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}