import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/project_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/cards/project_card.dart';
import '../../projects/project_detail_screen.dart';
import '../../projects/project_form_screen.dart';

// ProjectsTab affiche la liste de tous les projets de l'utilisateur.
// Si aucun projet → état vide avec message et icône.
// Si des projets → liste de ProjectCard cliquables.
class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {

    // ListenableBuilder écoute le ProjectProvider
    // Quand la liste change → le widget se reconstruit automatiquement
    return ListenableBuilder(
      listenable: context.read<ProjectProvider>(),
      builder: (context, _) {
        final projectProvider = context.read<ProjectProvider>();
        final projects = projectProvider.projects;

        // ÉTAT CHARGEMENT : spinner pendant le chargement
        if (projectProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ÉTAT VIDE : aucun projet
        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder_off,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.noProjects,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.noProjectsDesc,
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Bouton pour créer un projet depuis l'état vide
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProjectFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.newProject),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // ÉTAT NORMAL : liste des projets
        return ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectCard(
              project: project,
              taskCount: 0, // On mettra le vrai compteur plus tard
              // Clic sur la carte → aller aux détails du projet
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectDetailScreen(project: project),
                  ),
                );
              },
              // Clic sur "Modifier" dans le menu contextuel
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectFormScreen(project: project),
                  ),
                );
              },
              // Clic sur "Supprimer" dans le menu contextuel
              onDelete: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(AppStrings.deleteProject),
                    content: const Text(AppStrings.confirmDelete),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(AppStrings.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          AppStrings.delete,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await context
                      .read<ProjectProvider>()
                      .deleteProject(project.id);
                }
              },
            );
          },
        );
      },
    );
  }
}