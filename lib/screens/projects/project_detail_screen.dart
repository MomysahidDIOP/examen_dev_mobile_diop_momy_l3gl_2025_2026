import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/Project.dart';
import '../../models/Task.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/cards/task_card.dart';
import '../tasks/task_form_screen.dart';
import 'project_form_screen.dart';

// ProjectDetailScreen affiche les détails d'un projet ET la liste de ses tâches.
// On y accède en cliquant sur une ProjectCard dans ProjectsTab.
class ProjectDetailScreen extends StatefulWidget {
  // Le projet à afficher (passé en paramètre depuis ProjectsTab)
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {

  @override
  void initState() {
    super.initState();
    // Charger les tâches de ce projet au démarrage de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(widget.project.id);
    });
  }

  // Méthode pour supprimer le projet avec confirmation
  Future<void> _handleDeleteProject() async {
    // Afficher un AlertDialog pour confirmer la suppression
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteProject),
        content: Text(
          'Supprimer "${widget.project.name}" ? '
              'Toutes ses tâches seront aussi supprimées.',
        ),
        actions: [
          // Bouton Annuler
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          // Bouton Supprimer (en rouge)
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

    // Si l'utilisateur a confirmé
    if (confirmed == true && mounted) {
      final taskProvider = context.read<TaskProvider>();
      final projectProvider = context.read<ProjectProvider>();

      // Supprimer toutes les tâches du projet d'abord
      final tasks = taskProvider.tasks;
      for (final task in tasks) {
        await taskProvider.deleteTask(task.id);
      }

      // Ensuite supprimer le projet
      await projectProvider.deleteProject(widget.project.id);

      // Retourner à l'écran précédent
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // On écoute le TaskProvider pour mettre à jour l'UI quand les tâches changent
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;
    final taskCounts = taskProvider.taskCountByStatus;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        // Couleur de l'AppBar = couleur du projet
        backgroundColor: widget.project.color,
        foregroundColor: Colors.white,
        actions: [
          // Bouton Modifier dans l'AppBar
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // On passe le projet existant → mode modification
                  builder: (_) => ProjectFormScreen(project: widget.project),
                ),
              );
            },
          ),
          // Bouton Supprimer dans l'AppBar
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _handleDeleteProject,
          ),
        ],
      ),

      body: Column(
        children: [

          // ============================================================
          // EN-TÊTE COLORÉ avec le nom et la description du projet
          // ============================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: widget.project.color.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Description du projet
                if (widget.project.description.isNotEmpty)
                  Text(
                    widget.project.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),

                const SizedBox(height: 12),

                // ============================================================
                // STATISTIQUES : chips montrant le nombre de tâches par statut
                // ============================================================
                Wrap(
                  spacing: 8,
                  children: [
                    // Chip "À faire"
                    _buildStatChip(
                      label: AppStrings.statusTodo,
                      count: taskCounts[TaskStatus.todo] ?? 0,
                      color: AppColors.statusTodo,
                    ),
                    // Chip "En cours"
                    _buildStatChip(
                      label: AppStrings.statusInProgress,
                      count: taskCounts[TaskStatus.inProgress] ?? 0,
                      color: AppColors.statusInProgress,
                    ),
                    // Chip "Terminé"
                    _buildStatChip(
                      label: AppStrings.statusDone,
                      count: taskCounts[TaskStatus.done] ?? 0,
                      color: AppColors.statusDone,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Date de création du projet
                Text(
                  'Créé le ${widget.project.createdAt.day}/'
                      '${widget.project.createdAt.month}/'
                      '${widget.project.createdAt.year}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // LISTE DES TÂCHES du projet
          // ============================================================
          Expanded(
            child: taskProvider.isLoading
            // Afficher un spinner pendant le chargement
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
            // État vide : aucune tâche
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.noTasks,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.noTasksDesc,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
            // Liste des tâches avec TaskCard
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: tasks[index],
                  onTap: () {
                    // Navigation vers TaskDetailScreen (Partie 5.4)
                    // On l'implémente après
                  },
                );
              },
            ),
          ),
        ],
      ),

      // FAB pour ajouter une nouvelle tâche
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.project.color,
        onPressed: () {
          // Navigation vers le formulaire de création de tâche
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(
                projectId: widget.project.id,
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget helper pour construire un chip de statistique
  Widget _buildStatChip({
    required String label,
    required int count,
    required Color color,
  }) {
    return Chip(
      label: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}