import 'package:flutter/material.dart';
import '../models/Task.dart';
import '../services/storage_service.dart';

// TaskProvider gère la liste des tâches d un  projet.
// on  s'occupe :
//   1. Charger les tâches d'un projet depuis SharedPreferences
//   2. Créer, modifier, supprimer des tâches (CRUD)
//   3. Filtrer les tâches par statut et/ou priorité
//   4. Trier les tâches : inProgress en premier, puis todo, puis done
//      Et pour chaque statut : high en premier, puis medium, puis low
class TaskProvider extends ChangeNotifier {

  // ============================================================
  // PROPRIÉTÉS PRIVÉES
  // ============================================================
  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;

  // ============================================================
  // GETTERS PUBLICS
  // ============================================================
  List<Task> get tasks {
    List<Task> filtered = List.from(_tasks);

    if (_statusFilter != null) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList();
    }
    if (_priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    }

    // on TRI  d'abord par statut, puis par priorité

    const statusOrder = {
      TaskStatus.inProgress: 0,
      TaskStatus.todo: 1,
      TaskStatus.done: 2,
    };

    const priorityOrder = {
      TaskPriority.high: 0,
      TaskPriority.medium: 1,
      TaskPriority.low: 2,
    };

    filtered.sort((a, b) {

      final statusCompare = (statusOrder[a.status] ?? 99)
          .compareTo(statusOrder[b.status] ?? 99);
      if (statusCompare != 0) return statusCompare;

      // Si le statut est identique, on compare par priorité
      return (priorityOrder[a.priority] ?? 99)
          .compareTo(priorityOrder[b.priority] ?? 99);
    });

    return filtered;
  }

  // Compteur de tâches par statut (pour les statistiques du Dashboard)

  Map<TaskStatus, int> get taskCountByStatus {
    final map = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      map[status] = _tasks.where((t) => t.status == status).length;
    }
    return map;
  }

  bool get isLoading => _isLoading;

  // ============================================================
  // MÉTHODE loadTasks() - Charger les tâches d'un projet
  // ============================================================
  // Elle prend le projectId pour ne charger QUE les tâches de ce projet
  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();
    _tasks = StorageService.instance.getTasks()
        .where((t) => t.projectId == projectId)
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // MÉTHODE createTask() - Créer une nouvelle tâche
  // ============================================================

  Future<void> createTask(Task task) async {
    _tasks.add(task);
    await _saveAll();
    notifyListeners();
  }

  // ============================================================
  // MÉTHODE updateTask() - Modifier une tâche existante
  // ============================================================

  Future<void> updateTask(Task task) async {
    // On cherche la position de la tâche dans la liste grâce à son id
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      // On remplace l'ancienne tâche par la nouvelle
      _tasks[index] = task;
      await _saveAll();
      notifyListeners();
    }
  }

  // ============================================================
  // MÉTHODE deleteTask() - Supprimer une tâche
  // ============================================================

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _saveAll();
    notifyListeners();
  }

  // ============================================================
  // MÉTHODE updateTaskStatus() - Changer le statut rapidement
  // ============================================================

  // Appelée depuis TaskDetailScreen quand on change le statut
  // sans passer par le formulaire complet
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      // copyWith() crée une copie de la tâche avec juste le statut modifié
      _tasks[index] = _tasks[index].copyWith(status: status);
      await _saveAll();
      notifyListeners();
    }
  }

  // ============================================================
  // FILTRES
  // ============================================================

  // Active le filtre par statut (ex: voir seulement les tâches "todo")
  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners(); // Le getter "tasks" va recalculer avec le nouveau filtre
  }

  // ← AJOUTER : Active le filtre par priorité
  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  // ← AJOUTER : Efface tous les filtres pour voir toutes les tâches
  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }

  // ============================================================
  // MÉTHODE PRIVÉE _saveAll() - Sauvegarder dans SharedPreferences
  // ============================================================

  // Même logique que dans ProjectProvider :
  // On garde les tâches des AUTRES projets et on ajoute nos tâches mises à jour
  Future<void> _saveAll() async {
    final allTasks = StorageService.instance.getTasks();

    await StorageService.instance.saveTasks([
      // Tâches des autres projets (on ne les touche pas)
      ...allTasks.where(
              (t) => !_tasks.any((mt) => mt.projectId == t.projectId)
      ),
      // Nos tâches mises à jour
      ..._tasks,
    ]);
  }
}