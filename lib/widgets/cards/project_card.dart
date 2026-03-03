import 'package:flutter/material.dart';
import '../../models/Project.dart';

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
    // On transforme le String hexadécimal (#FF0000) en couleur Flutter
    // Utilise project.color (le String) au lieu de juste color
    // Utilise project.color (le String) au lieu de juste color
    final String colorHex = project.color.toString().replaceFirst('#', '0xff');
    final Color projectColor = Color(int.parse(colorHex));
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        // 1. Pastille de couleur (Exigence Page 8)
        leading: Container(
          width: 5,
          height: 40,
          decoration: BoxDecoration(
            color: projectColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(project.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        // 2. Menu contextuel (Exigence Page 8)
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}