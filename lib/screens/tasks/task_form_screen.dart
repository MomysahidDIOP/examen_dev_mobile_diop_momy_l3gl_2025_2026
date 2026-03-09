import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/Task.dart';
import '../../providers/task_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

// TaskFormScreen sert à la FOIS pour créer ET modifier une tâche.
// Même logique que ProjectFormScreen :
//   Si task == null  : c'est une CRÉATION
//   Si task != null  : c'est une MODIFICATION (champs pré-remplis)
class TaskFormScreen extends StatefulWidget {
  final String projectId;  // L'ID du projet auquel appartient la tâche
  final Task? task;        // null = création, non-null = modification

  const TaskFormScreen({
    super.key,
    required this.projectId,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {

  // Controllers pour le titre et la description
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Statut sélectionné (par défaut : À faire)
  TaskStatus _selectedStatus = TaskStatus.todo;

  // Priorité sélectionnée (par défaut : Moyenne)
  TaskPriority _selectedPriority = TaskPriority.medium;

  // Date d'échéance (optionnelle)
  DateTime? _selectedDueDate;

  // Vrai si on est en mode modification
  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    // Si modification, on pré-remplit tous les champs
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedStatus = widget.task!.status;
      _selectedPriority = widget.task!.priority;
      _selectedDueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Ouvre le calendrier pour choisir une date d'échéance
  Future<void> _pickDueDate() async {
    // showDatePicker affiche un calendrier natif Flutter
    final picked = await showDatePicker(
      context: context,
      // Date de départ : aujourd'hui
      initialDate: _selectedDueDate ?? DateTime.now(),
      // Date minimum : aujourd'hui (on ne peut pas choisir le passé)
      firstDate: DateTime.now(),
      // Date maximum : dans 2 ans
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    // Si l'utilisateur a choisi une date (pas annulé)
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  // Méthode de sauvegarde (création ou modification)
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = context.read<TaskProvider>();

    if (_isEditing) {
      // MODE MODIFICATION : copie avec les nouvelles valeurs
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
      await taskProvider.updateTask(updatedTask);
    } else {
      // MODE CRÉATION : nouvelle tâche
      final newTask = Task(
        id: const Uuid().v4(),
        projectId: widget.projectId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
      );
      await taskProvider.createTask(newTask);
    }

    if (mounted) Navigator.pop(context);
  }

  // Suppression d'une tâche (uniquement en mode modification)
  Future<void> _handleDelete() async {
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

    if (confirmed == true && mounted) {
      await context.read<TaskProvider>().deleteTask(widget.task!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TaskProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editTask : AppStrings.newTask),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        // Bouton supprimer visible UNIQUEMENT en mode modification
        actions: [
          Visibility(
            visible: _isEditing,
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _handleDelete,
            ),
          ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ============================================================
              // CHAMP TITRE (obligatoire)
              // ============================================================
              CustomTextField(
                controller: _titleController,
                label: AppStrings.taskTitle,
                hint: 'Ex: Créer la base de données',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ============================================================
              // CHAMP DESCRIPTION (multiligne, optionnel)
              // ============================================================
              CustomTextField(
                controller: _descriptionController,
                label: AppStrings.taskDescription,
                hint: 'Décrivez la tâche...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // ============================================================
              // SÉLECTEUR DE STATUT
              // 3 conteneurs animés : À faire / En cours / Terminée
              // ============================================================
              const Text(
                'Statut',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: TaskStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;

                  // Label et couleur selon le statut
                  String label;
                  Color color;
                  switch (status) {
                    case TaskStatus.todo:
                      label = AppStrings.statusTodo;
                      color = AppColors.statusTodo;
                      break;
                    case TaskStatus.inProgress:
                      label = AppStrings.statusInProgress;
                      color = AppColors.statusInProgress;
                      break;
                    case TaskStatus.done:
                      label = AppStrings.statusDone;
                      color = AppColors.statusDone;
                      break;
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedStatus = status),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          // Fond coloré si sélectionné, transparent sinon
                          color: isSelected
                              ? color.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? color : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ============================================================
              // SÉLECTEUR DE PRIORITÉ
              // 3 conteneurs animés : Haute / Moyenne / Basse
              // ============================================================
              const Text(
                'Priorité',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;

                  String label;
                  Color color;
                  IconData icon;
                  switch (priority) {
                    case TaskPriority.high:
                      label = AppStrings.priorityHigh;
                      color = AppColors.priorityHigh;
                      icon = Icons.arrow_upward;
                      break;
                    case TaskPriority.medium:
                      label = AppStrings.priorityMedium;
                      color = AppColors.priorityMedium;
                      icon = Icons.remove;
                      break;
                    case TaskPriority.low:
                      label = AppStrings.priorityLow;
                      color = AppColors.priorityLow;
                      icon = Icons.arrow_downward;
                      break;
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPriority = priority),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(icon, color: isSelected ? color : AppColors.textSecondary, size: 16),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? color : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ============================================================
              // DATE D'ÉCHÉANCE (optionnelle)
              // showDatePicker() ouvre le calendrier natif Flutter
              // ============================================================
              const Text(
                'Date d\'échéance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: _pickDueDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        // Afficher la date ou un message par défaut
                        _selectedDueDate != null
                            ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                            : 'Choisir une date (optionnel)',
                        style: TextStyle(
                          color: _selectedDueDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      // Bouton pour effacer la date
                      if (_selectedDueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedDueDate = null),
                          child: const Icon(Icons.close,
                              color: AppColors.textSecondary, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ============================================================
              // BOUTON CRÉER ou MODIFIER
              // ============================================================
              CustomButton(
                text: _isEditing ? AppStrings.edit : 'Créer la tâche',
                isLoading: isLoading,
                onPressed: isLoading ? null : _handleSubmit,
                icon: _isEditing ? Icons.save : Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}