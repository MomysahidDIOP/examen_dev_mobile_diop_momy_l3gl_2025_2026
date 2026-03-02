class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status;
  final String priority;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.status = 'todo',
    this.priority = 'medium',
  });
}