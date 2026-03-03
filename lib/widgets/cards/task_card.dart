import 'package:flutter/material.dart';
import '../../models/Task.dart';


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
    // Déterminer la couleur selon le statut (Exigence Page 8)
    Color couleurStatut;
    switch (task.status) {
      case 'todo':
        couleurStatut = Colors.orange;
        break;
      case 'inProgress':
        couleurStatut = Colors.blue;
        break;
      case 'done':
        couleurStatut = Colors.green;
        break;
      default:
        couleurStatut = Colors.grey;
    }

    // Déterminer la couleur selon la priorité
    Color couleurPriorite = task.priority == 'high'
        ? Colors.red
        : (task.priority == 'medium' ? Colors.orange : Colors.green);

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
            Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            // Badge de statut (Exigence Page 8)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: couleurStatut.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                task.status.toUpperCase(),
                style: TextStyle(
                  color: couleurStatut,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // Indicateur de priorité (Exigence Page 8)
        trailing: Icon(Icons.flag, color: couleurPriorite),
      ),
    );
  }
}