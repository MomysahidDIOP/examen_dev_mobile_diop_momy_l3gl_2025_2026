import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/projects_tab.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/profile_tab.dart';

// HomeScreen est l'écran principal de l'application.
// Il contient 4 onglets gérés par un IndexedStack.
// IndexedStack garde tous les onglets en mémoire
// ce qui évite de recharger les données à chaque changement d'onglet.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // L'index de l'onglet actuellement affiché
  // 0 = Dashboard, 1 = Projets, 2 = Tâches, 3 = Profil
  int _currentIndex = 0;

  // Les 4 onglets dans l'ordre
  // On les définit ici pour ne pas les recréer à chaque rebuild
  final List<Widget> _tabs = const [
    DashboardTab(),
    ProjectsTab(),
    TasksTab(),
    ProfileTab(),
  ];

  // Les titres correspondants à chaque onglet
  final List<String> _titles = [
    AppStrings.home,      // "Accueil"
    AppStrings.projects,  // "Projets"
    AppStrings.tasks,     // "Tâches"
    AppStrings.profile,   // "Profil"
  ];

  @override
  void initState() {
    super.initState();
    // Charger les projets de l'utilisateur connecté au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<ProjectProvider>().loadProjects(user.id);
      }
    });
  }

  // Méthode de déconnexion
  Future<void> _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // On récupère l'utilisateur connecté pour l'afficher dans le Drawer
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(

      // ============================================================
      // APPBAR : barre du haut avec le titre de l'onglet actif
      // ============================================================
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      // ============================================================
      // DRAWER : menu latéral qui s'ouvre en glissant depuis la gauche
      // ============================================================
      drawer: Drawer(
        child: Column(
          children: [

            // En-tête du Drawer avec avatar, nom et email
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),

              // Avatar : un cercle avec la première lettre du nom
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  // Si le nom existe, on prend la première lettre en majuscule
                  // Sinon on affiche "?"
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              accountName: Text(user?.name ?? ''),
              accountEmail: Text(user?.email ?? ''),
            ),

            // Items de navigation identiques au BottomNavigationBar
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text(AppStrings.home),
              selected: _currentIndex == 0,
              selectedColor: AppColors.primary,
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context); // Ferme le Drawer
              },
            ),

            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text(AppStrings.projects),
              selected: _currentIndex == 1,
              selectedColor: AppColors.primary,
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.task),
              title: const Text(AppStrings.tasks),
              selected: _currentIndex == 2,
              selectedColor: AppColors.primary,
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(AppStrings.profile),
              selected: _currentIndex == 3,
              selectedColor: AppColors.primary,
              onTap: () {
                setState(() => _currentIndex = 3);
                Navigator.pop(context);
              },
            ),

            // Séparateur visuel
            const Divider(),

            // Bouton de déconnexion en bas du Drawer
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                AppStrings.logout,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),

      // ============================================================
      // BODY : IndexedStack affiche UN seul onglet à la fois
      // mais garde tous les autres en mémoire (pas de rechargement)
      // ============================================================
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),

      // ============================================================
      // BOTTOM NAVIGATION BAR : barre de navigation en bas
      // ============================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Affiche label pour tous les onglets
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: AppStrings.projects,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: AppStrings.tasks,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),

      // ============================================================
      // FLOATING ACTION BUTTON : visible seulement sur Dashboard et Projets
      // Pour créer un nouveau projet
      // ============================================================
      floatingActionButton: Visibility(
        // Visible seulement sur onglet 0 (Dashboard) et 1 (Projets)
        visible: _currentIndex == 0 || _currentIndex == 1,
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () {
            // Navigation vers le formulaire de création de projet
            // On l'implémentera dans la Partie 5
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Créer un projet - Partie 5'),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}