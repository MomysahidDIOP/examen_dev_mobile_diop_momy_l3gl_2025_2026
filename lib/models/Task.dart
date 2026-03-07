//Les statuts possibles d'une tache
enum TaskStatus {
  todo,
  inProgress,
  done,
}

//Les priorites possibles d'une tache
enum TaskPriority {
  low,
  medium,
  high,
}

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status; // Statut : todo / inProgress / done
  final TaskPriority priority; // Priorité : low / medium / high
  final DateTime? dueDate;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo, // Par défaut todoo
    this.priority = TaskPriority.medium, // Par défaut  medium
    this.dueDate, // Par défaut on aura pas de date limite
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // toMap : pour sauvegarder dans SharedPreferences
  // On convertit l enum en String via ".name"
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      // On cherche l enum dont le name correspond à la String sauvegardee
      // oubien: si jamais la valeur est inconnue, on met la valeur par défaut
      status: TaskStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
            (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }


}