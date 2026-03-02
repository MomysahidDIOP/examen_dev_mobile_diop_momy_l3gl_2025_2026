import 'package:flutter/material.dart';
import '../models/Task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String? _statusFilter;
  bool _isLoading = false;

  List<Task> get tasks {
    List<Task> filtered = _tasks;
    if (_statusFilter != null) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList();
    }
    // Tri par statut (InProgress > Todo > Done) comme demandé
    filtered.sort((a, b) => a.status.compareTo(b.status));
    return filtered;
  }

  bool get isLoading => _isLoading;

  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }
}