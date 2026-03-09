import 'package:flutter/material.dart';
import '../../models/Project.dart';
import '../../core/constants/app_colors.dart'; // ← AJOUTER

class ProjectCard extends StatelessWidget {
  final Project project;
  final int taskCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.taskCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {


    final Color couleurProjet = project.color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,

        //Pastille de couleur du projet
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: couleurProjet,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        //affiche description ET nombre de tâches
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$taskCount tâche${taskCount > 1 ? "s" : ""}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}