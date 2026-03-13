import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';
import 'package:sunu_task/screens/home/tabs/dashboard_tab.dart';
import 'package:sunu_task/screens/home/tabs/profile_tab.dart';
import 'package:sunu_task/screens/home/tabs/projects_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Liste des titres pour l'AppBar selon l'onglet
  final List<String> _titles = [
    'Tableau de Bord',
    'Mes Projets',
    'Mes Tâches',
    'Mon Profil',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final projectProvider = context.read<ProjectProvider>();
      if (auth.currentUser != null) {
        await projectProvider.loadProjects(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // 1. NAVIGATION DRAWER
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name[0].toUpperCase() ?? "U",
                  style: TextStyle(fontSize: 24, color: AppColors.primary),
                ),
              ),
              accountName: Text(user?.name ?? "Utilisateur"),
              accountEmail: Text(user?.email ?? "email@sunutask.sn"),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
            _buildDrawerItem(Icons.folder, 'Projets', 1),
            _buildDrawerItem(Icons.list, 'Tâches', 2),
            _buildDrawerItem(Icons.person, 'Profil', 3),
            Spacer(),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),

      // CORPS AVEC INDEXEDSTACK (Préserve l'état)
      body: IndexedStack(
        index: _currentIndex,
        children:  [
          DashboardTab(),
          ProjectsTab(),
          Center(child: Text('Contenu Tâches')),
          ProfileTab(),
        ],
      ),

      // FLOATING ACTION BUTTON (Visible seulement sur dashboard et projets)
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
              onPressed: () {
                if (_currentIndex == 1) {
                  showCreateProjectDialog(context);
                  return;
                }
                // TODO: action spécifique Dashboard si besoin
              },
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items:  [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: AppStrings.dashboard),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: AppStrings.projects),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: AppStrings.tasks),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profile),
        ],
      ),
    );
  }

  // Widget utilitaire pour les items du Drawer
  Widget _buildDrawerItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon, color: _currentIndex == index ? AppColors.primary : null),
      title: Text(label),
      selected: _currentIndex == index,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context); // Ferme le drawer
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }
}
