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
    // 1. Récupérer la valeur entière de la couleur et la transformer en String hexadécimale
    String codeCouleur = project.color.value.toRadixString(16).toUpperCase();

    // 2. S'assurer que le format est correct (ARGB)
    if (codeCouleur.length == 6) {
      codeCouleur = 'FF$codeCouleur';
    } else if (codeCouleur.length != 8) {
      codeCouleur = 'FF9E9E9E'; // Couleur grise par défaut si erreur
    }

    // 3. Créer l'objet Color final
    final Color couleurProjet = Color(int.parse(codeCouleur, radix: 16));
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,

        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: couleurProjet,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(project.description, maxLines: 1, overflow: TextOverflow.ellipsis),

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