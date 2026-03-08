import 'package:flutter/material.dart';
import '../../models/Task.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {


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

    //  enums au lieu de Strings
    Color couleurPriorite;
    switch (task.priority) {
      case TaskPriority.high:
        couleurPriorite = AppColors.priorityHigh;
        break;
      case TaskPriority.medium:
        couleurPriorite = AppColors.priorityMedium;
        break;
      case TaskPriority.low:
        couleurPriorite = AppColors.priorityLow;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Badge de statut avec la couleur AppColors
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: couleurStatut.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                labelStatut,
                style: TextStyle(
                  color: couleurStatut,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Date d'échéance si elle existe
            if (task.dueDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Échéance : ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),

        // Indicateur de priorité avec AppColors
        trailing: Icon(Icons.flag, color: couleurPriorite),
      ),
    );
  }
}