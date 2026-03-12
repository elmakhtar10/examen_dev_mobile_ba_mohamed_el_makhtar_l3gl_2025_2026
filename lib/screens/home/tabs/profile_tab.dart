import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  // Fonction pour transformer une date en "12 Mars 2026"
  String _formatDate(DateTime? date) {
    if (date == null) return "Date inconnue";

    // Liste des mois en français
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // 1. HEADER : AVATAR
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: Text(
              user?.name.isNotEmpty == true ? user!.name.substring(0, 1).toUpperCase() : "U",
              style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          // NOM ET EMAIL
          Text(
            user?.name ?? "Utilisateur",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? "email@exemple.com",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 12),

          // DATE D'INSCRIPTION
          Chip(
            label: Text(
              "Inscrit depuis le ${_formatDate(user?.createdAt ?? DateTime.now())}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppColors.primary.withAlpha(30),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),

          const SizedBox(height: 30),

          // 4. STATISTIQUES RÉELLES
          Row(
            children: [
              _buildStatItem("Projets", "${projectProvider.projectCount}", Icons.folder_shared),
              _buildStatItem("Tâches", "0", Icons.check_circle_outline),
            ],
          ),

          const SizedBox(height: 40),

          // BOUTON DÉCONNEXION
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}