import 'package:flutter/material.dart';

class Project {
  final String id;
  final String userId;
  final String name;
  final String description;
  final Color color;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.userId,
    required this.name,
    this.description = '',
    this.color = const Color(0xFF0293ED),
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();



  Project copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    Color? color,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'color': color.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }


  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      color: Color(map['color'] as int),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}