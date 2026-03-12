import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {

  // Simulation de rafraîchissement des données
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  // Message de bienvenue selon l'heure
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Bonjour";
    if (hour < 18) return "Bon après-midi";
    return "Bonsoir";
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // MESSAGE DE BIENVENUE
          Text(
            "${_getGreeting()}, l'ami !",
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
          const SizedBox(height: 24),

          // CARTES DE STATISTIQUES (Grille)
          GridView.count(
            shrinkWrap: true, // Important pour marcher dans une ListView
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard("Projets", "12", Icons.folder, Colors.blue),
              _buildStatCard("À faire", "5", Icons.assignment, Colors.orange),
              _buildStatCard("En cours", "3", Icons.pending, Colors.purple),
              _buildStatCard("Terminés", "24", Icons.check_circle, Colors.green),
            ],
          ),

          const SizedBox(height: 24),

          // 3. PROJETS RÉCENTS
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Projets récents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: null, child: Text("Voir tout")),
            ],
          ),

          // Simulation d'une liste
          _buildRecentProjectItem("Refonte Site Web", "Il y a 2h"),
          _buildRecentProjectItem("App Mobile SunuTask", "Hier"),
          _buildRecentProjectItem("Base de données L3GL", "Il y a 3 jours"),
        ],
      ),
    );
  }

  // Widget utilitaire pour les cartes de stats
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

  // Widget utilitaire pour les projets récents
  Widget _buildRecentProjectItem(String name, String time) {
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
      subtitle: Text(time),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}