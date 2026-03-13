import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../models/Task.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/cards/project_card.dart';
import '../../projects/project_detail_screen.dart';

// DashboardTab est le tableau de bord.
// Il affiche un résumé de l'activité de l'utilisateur :
//   - Message de bienvenue selon l'heure
//   - Statistiques (projets, tâches par statut)
//   - Liste des projets récents
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  // Retourne le message de bienvenue selon l'heure actuelle
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    // ListenableBuilder écoute ProjectProvider ET TaskProvider
    // Si l'un des deux change → l'UI se reconstruit
    return ListenableBuilder(
      listenable: Listenable.merge([
        context.read<ProjectProvider>(),
        context.read<TaskProvider>(),
      ]),
      builder: (context, _) {
        final projectProvider = context.read<ProjectProvider>();
        final taskProvider = context.read<TaskProvider>();
        final projects = projectProvider.projects;
        final taskCounts = taskProvider.taskCountByStatus;

        // RefreshIndicator permet de rafraîchir en tirant vers le bas
        return RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              await projectProvider.loadProjects(user.id);

            }
          },
          child: SingleChildScrollView(
            // physics nécessaire pour que RefreshIndicator fonctionne
            // même quand le contenu ne dépasse pas l'écran
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ============================================================
                // MESSAGE DE BIENVENUE
                // ============================================================
                Text(
                  '${_getGreeting()}, ${user?.name ?? ''} !',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Voici un résumé de vos projets',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // ============================================================
                // CARTES DE STATISTIQUES
                // ============================================================
                Row(
                  children: [
                    // Nombre de projets
                    Expanded(
                      child: _buildStatCard(
                        title: AppStrings.projects,
                        value: projects.length.toString(),
                        icon: Icons.folder,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tâches à faire
                    Expanded(
                      child: _buildStatCard(
                        title: AppStrings.statusTodo,
                        value: (taskCounts[TaskStatus.todo] ?? 0).toString(),
                        icon: Icons.radio_button_unchecked,
                        color: AppColors.statusTodo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Tâches en cours
                    Expanded(
                      child: _buildStatCard(
                        title: AppStrings.statusInProgress,
                        value: (taskCounts[TaskStatus.inProgress] ?? 0).toString(),
                        icon: Icons.timelapse,
                        color: AppColors.statusInProgress,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tâches terminées
                    Expanded(
                      child: _buildStatCard(
                        title: AppStrings.statusDone,
                        value: (taskCounts[TaskStatus.done] ?? 0).toString(),
                        icon: Icons.check_circle,
                        color: AppColors.statusDone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ============================================================
                // PROJETS RÉCENTS
                // ============================================================
                const Text(
                  'Projets récents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // État vide
                Visibility(
                  visible: projects.isEmpty,
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        AppStrings.noProjectsDesc,
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: projects.isNotEmpty,
                  child: Column(
                    children: projects.take(3).map((project) {
                      // CALCUL DYNAMIQUE DU NOMBRE DE TÂCHES
                      final int realTaskCount = taskProvider.tasks
                          .where((t) => t.projectId == project.id)
                          .length;

                      return ProjectCard(
                        project: project,
                        taskCount: realTaskCount, // On passe la vraie valeur calculée
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(project: project),
                            ),
                          );
                        },
                        onEdit: () {},
                        onDelete: () {},
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget helper pour construire une carte de statistique
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}