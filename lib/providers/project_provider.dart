import 'package:flutter/material.dart';
import '../models/Project.dart';
import '../services/storage_service.dart';

// ProjectProvider gère la liste des projets de l'utilisateur connecté.
// ici on  s'occupe  :
//   1. Charger les projets depuis SharedPreferences
//   2. Créer, modifier, supprimer des projets (CRUD)
//   3. Sauvegarder les changements dans SharedPreferences
//   4. Notifier les widgets quand la liste change
class ProjectProvider extends ChangeNotifier {

  // ============================================================
  // PROPRIÉTÉS PRIVÉES
  // ============================================================
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  // ============================================================
  // GETTERS PUBLICS
  // ============================================================
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;

  // ============================================================
  // MÉTHODE loadProjects() - Charger les projets au démarrage
  // ============================================================

  // Cette méthode est appelée quand l'utilisateur arrive sur le HomeScreen.
  // Elle prend l'userId pour ne charger que les projets de cet utilisateur
  // (car plusieurs utilisateurs peuvent être enregistrés dans l'app)
  Future<void> loadProjects(String userId) async {
    // On démarre le chargement pour afficher le spinner
    _isLoading = true;
    notifyListeners();

    // On récupère TOUS les projets stockes dans SharedPreferences
    // puis on filtre avec .where() pour garder seulement ceux
    // qui appartiennent à l'utilisateur connecté (userId correspond)
    _projects = StorageService.instance.getProjects()
        .where((p) => p.userId == userId)
        .toList();

    // Chargement terminé, on cache le spinner
    _isLoading = false;
    notifyListeners(); // Les widgets se mettent à jour avec la nouvelle liste
  }

  // ============================================================
  // MÉTHODE createProject() - Créer un nouveau projet
  // ============================================================

  // Appelée quand l'utilisateur valide le formulaire de création de projet.
  // Elle reçoit un objet Project déjà construit (avec son id, nom, couleur...)
  Future<void> createProject(Project project) async {

    // On ajoute le nouveau projet à notre liste en mémoire
    _projects.add(project);

    // On sauvegarde TOUTE la liste dans SharedPreferences
    // pour que le projet soit retrouvé au prochain démarrage
    await _saveAll();

    // On prévient les widgets : la liste a un nouveau projet !
    notifyListeners();
  }

  // ============================================================
  // MÉTHODE updateProject() - Modifier un projet existant
  // ============================================================

  // Appelée quand l'utilisateur modifie un projet et valide le formulaire.
  // Elle reçoit le projet avec les nouvelles valeurs.
  Future<void> updateProject(Project project) async {

    // On cherche la POSITION du projet dans la liste grâce à son id
    // indexWhere retourne l'index (0, 1, 2...) ou -1 si pas trouvé
    final index = _projects.indexWhere((p) => p.id == project.id);

    // On vérifie que le projet existe bien dans la liste (index != -1)
    if (index != -1) {
      // On remplace l'ancien projet par le nouveau à la même position
      _projects[index] = project;

      // On sauvegarde les changements dans SharedPreferences
      await _saveAll();

      // On prévient les widgets : un projet a été modifié !
      notifyListeners();
    }
  }

  // ============================================================
  // MÉTHODE deleteProject() - Supprimer un projet
  // ============================================================

  // Appelée quand l'utilisateur confirme la suppression d'un projet.
  // Elle reçoit juste l'id du projet à supprimer.
  Future<void> deleteProject(String projectId) async {

    // removeWhere parcourt la liste et supprime tous les éléments
    // dont la condition est vraie (ici : dont l'id correspond)
    _projects.removeWhere((p) => p.id == projectId);

    // On sauvegarde la liste mise à jour dans SharedPreferences
    await _saveAll();

    // On prévient les widgets : un projet a été supprimé !
    notifyListeners();
  }

  // ============================================================
  // MÉTHODE selectProject() - Sélectionner un projet
  // ============================================================

  // Appelee quand l'utilisateur clique sur un projet dans la liste.
  // Elle mémorise quel projet est sélectionné pour pouvoir l'afficher
  // dans ProjectDetailScreen.
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners(); // Les widgets savent quel projet est sélectionné
  }

  // ============================================================
  // MÉTHODE PRIVÉE _saveAll() - Sauvegarder dans SharedPreferences
  // ============================================================
  // Son rôle : synchroniser notre liste _projects avec SharedPreferences.
  Future<void> _saveAll() async {

    // ÉTAPE 1 : On récupère TOUS les projets stockés (tous utilisateurs confondus)
    final allProjects = StorageService.instance.getProjects();

    // ÉTAPE 2 : On construit la nouvelle liste à sauvegarder :
    //   - On garde les projets des AUTRES utilisateurs (ceux qui n'ont pas le même userId)
    //   - On ajoute nos projets mis à jour (_projects)
    // Le spread operator "..." permet de fusionner deux listes en une seule
    await StorageService.instance.saveProjects([
      ...allProjects.where(
              (p) => !_projects.any((mp) => mp.userId == p.userId)
      ),
      ..._projects,
    ]);
  }
}