import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/task_provider.dart';
import '../../../models/Task.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/cards/task_card.dart';
import '../../tasks/task_detail_screen.dart';

// TasksTab affiche toutes les tâches de l'utilisateur avec filtres
class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.read<TaskProvider>(),
      builder: (context, _) {
        final taskProvider = context.read<TaskProvider>();
        final tasks = taskProvider.tasks;

        return Column(
          children: [

            // ============================================================
            // BARRE DE FILTRES par statut
            // ============================================================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Filtre "Tous"
                  _buildFilterChip(
                    label: 'Tous',
                    isSelected: taskProvider.tasks.length == tasks.length,
                    onTap: () => taskProvider.clearFilters(),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  // Filtre par statut
                  _buildFilterChip(
                    label: AppStrings.statusTodo,
                    isSelected: false,
                    onTap: () => taskProvider.setStatusFilter(TaskStatus.todo),
                    color: AppColors.statusTodo,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: AppStrings.statusInProgress,
                    isSelected: false,
                    onTap: () => taskProvider.setStatusFilter(TaskStatus.inProgress),
                    color: AppColors.statusInProgress,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: AppStrings.statusDone,
                    isSelected: false,
                    onTap: () => taskProvider.setStatusFilter(TaskStatus.done),
                    color: AppColors.statusDone,
                  ),
                ],
              ),
            ),

            // ============================================================
            // LISTE DES TÂCHES
            // ============================================================
            Expanded(
              child: tasks.isEmpty
              // État vide
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.task_alt,
                        size: 80, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      AppStrings.noTasks,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppStrings.noTasksDesc,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
              // Liste des tâches
                  : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(
                    task: tasks[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TaskDetailScreen(task: tasks[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget helper pour construire un chip de filtre
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}