import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/Task.dart';
import '../../providers/task_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'task_form_screen.dart';

// TaskDetailScreen affiche les détails complets d'une tâche.

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  // Méthode pour changer rapidement le statut d'une tâche
  // Sans avoir à ouvrir le formulaire complet
  Future<void> _handleStatusChange(
      BuildContext context,
      TaskStatus newStatus,
      ) async {
    await context.read<TaskProvider>().updateTaskStatus(task.id, newStatus);
    // On revient en arrière car la tache a été modifiée
    if (context.mounted) Navigator.pop(context);
  }

  // Méthode pour supprimer la tache avec confirmation
  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
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
      await context.read<TaskProvider>().deleteTask(task.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    // Couleur et label selon le statut de la tache
    Color couleurStatut;
    String labelStatut;
    switch (task.status) {
      case TaskStatus.todo:
        couleurStatut = AppColors.statusTodo;
        labelStatut = AppStrings.statusTodo;
        break;
      case TaskStatus.inProgress:
        couleurStatut = AppColors.statusInProgress;
        labelStatut = AppStrings.statusInProgress;
        break;
      case TaskStatus.done:
        couleurStatut = AppColors.statusDone;
        labelStatut = AppStrings.statusDone;
        break;
    }

    // Couleur et label selon la priorité
    Color couleurPriorite;
    String labelPriorite;
    IconData iconPriorite;
    switch (task.priority) {
      case TaskPriority.high:
        couleurPriorite = AppColors.priorityHigh;
        labelPriorite = AppStrings.priorityHigh;
        iconPriorite = Icons.arrow_upward;
        break;
      case TaskPriority.medium:
        couleurPriorite = AppColors.priorityMedium;
        labelPriorite = AppStrings.priorityMedium;
        iconPriorite = Icons.remove;
        break;
      case TaskPriority.low:
        couleurPriorite = AppColors.priorityLow;
        labelPriorite = AppStrings.priorityLow;
        iconPriorite = Icons.arrow_downward;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la tâche'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Bouton Modifier
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskFormScreen(
                    projectId: task.projectId,
                    task: task, // Mode modification
                  ),
                ),
              );
            },
          ),
          // Bouton Supprimer
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ============================================================
            // TITRE DE LA TACHE
            // ============================================================
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // ============================================================
            // DESCRIPTION (si elle existe)
            // ============================================================
            if (task.description.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ============================================================
            // STATUT avec changement rapide
            // L'utilisateur peut changer le statut directement ici
            // sans passer par le formulaire complet
            // ============================================================
            const Text(
              'Statut',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Badge de statut actuel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: couleurStatut.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: couleurStatut),
              ),
              child: Text(
                labelStatut,
                style: TextStyle(
                  color: couleurStatut,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Boutons de changement rapide de statut
            // Affiche les autres statuts pour changer rapidement
            const Text(
              'Changer le statut :',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: TaskStatus.values
                  .where((s) => s != task.status) // Exclure le statut actuel
                  .map((status) {
                Color color;
                String label;
                switch (status) {
                  case TaskStatus.todo:
                    color = AppColors.statusTodo;
                    label = AppStrings.statusTodo;
                    break;
                  case TaskStatus.inProgress:
                    color = AppColors.statusInProgress;
                    label = AppStrings.statusInProgress;
                    break;
                  case TaskStatus.done:
                    color = AppColors.statusDone;
                    label = AppStrings.statusDone;
                    break;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () => _handleStatusChange(context, status),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                    ),
                    child: Text(label),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ============================================================
            // PRIORITÉ avec indicateur visuel
            // ============================================================
            const Text(
              'Priorité',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(iconPriorite, color: couleurPriorite, size: 20),
                const SizedBox(width: 8),
                Text(
                  labelPriorite,
                  style: TextStyle(
                    color: couleurPriorite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ============================================================
            // DATE D'ECHEANCE (si elle existe)
            // ============================================================
            if (task.dueDate != null) ...[
              const Text(
                'Date d\'échéance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}