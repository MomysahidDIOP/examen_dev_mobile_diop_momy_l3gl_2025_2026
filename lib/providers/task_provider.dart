import 'package:flutter/material.dart';
import '../models/Task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String? _statusFilter;
  bool _isLoading = false;


  List<Task> get tasks {
    List<Task> filtered = List.from(_tasks);

    if (_statusFilter != null) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList();
    }


    final order = {'inProgress': 0, 'todo': 1, 'done': 2};

    filtered.sort((a, b) {
      int statusCompare = (order[a.status] ?? 99).compareTo(order[b.status] ?? 99);
      return statusCompare;
    });

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

// CRUD
}