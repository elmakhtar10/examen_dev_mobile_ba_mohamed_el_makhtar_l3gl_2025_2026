import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/app_provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.greetingMorning;
    if (hour < 18) return AppStrings.greetingAfternoon;
    return AppStrings.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    // On ecoute les trois providers necessaires
    final appProvider = context.watch<AppProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final authProvider = context.read<AuthProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await appProvider.init();
        if (authProvider.currentUser != null) {
          await projectProvider.loadProjects(authProvider.currentUser!.id);
          await taskProvider.loadTasks(authProvider.currentUser!.id);
        }
      },
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(authProvider.currentUser?.name ?? AppStrings.friendFallback),

          const SizedBox(height: 24),

          // Section Statistiques avec les vraies donnees
          appProvider.isLoading || projectProvider.isLoading || taskProvider.isLoading
              ? const Center(child: LinearProgressIndicator())
              : _buildStatsGrid(projectProvider, taskProvider),

          const SizedBox(height: 24),

          _buildRecentProjectsHeader(),

          // Affichage des 3 derniers projets reels s'ils existent
          if (projectProvider.projects.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(AppStrings.noRecentProjects, textAlign: TextAlign.center),
            )
          else
            ...projectProvider.projects.reversed.take(3).map((project) {
              return _buildRecentProjectItem(project.title, AppStrings.project);
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
          "${_getGreeting()}, $name ${AppStrings.greetingSuffix}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppStrings.dashboardSubtitle,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(ProjectProvider projectProvider, TaskProvider taskProvider) {
    // Calcul des statistiques reelles
    int totalProjects = projectProvider.projectCount;
    int completedProjects = projectProvider.projects.where((p) => p.isCompleted).length;
    int inProgress = totalProjects - completedProjects;
    int completedTasks = taskProvider.tasks.where((t) => t.isCompleted).length;
    int todoTasks = taskProvider.taskCount - completedTasks;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(AppStrings.statProjects, "$totalProjects", Icons.folder, Colors.blue),
        _buildStatCard(AppStrings.statTodo, "$todoTasks", Icons.assignment, Colors.orange),
        _buildStatCard(AppStrings.statInProgress, "$inProgress", Icons.pending, Colors.purple),
        _buildStatCard(AppStrings.statDone, "$completedTasks", Icons.check_circle, Colors.green),
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
          AppStrings.recentProjects,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: null, child: Text(AppStrings.seeAll)),
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
