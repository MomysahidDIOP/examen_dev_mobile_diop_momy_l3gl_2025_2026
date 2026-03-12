import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/Project.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/cards/project_card.dart';

// ProjectFormScreen  cet page sert à la FOIS pour créer ET modifier un projet.

//   Si project == null  : c'est une CRÉATION
//   Si project != null  : c'est une MODIFICATION (les champs sont pré-remplis)
class ProjectFormScreen extends StatefulWidget {
  // Le projet à modifier (null si on crée un nouveau projet)
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {

  // Controllers pour récupérer le texte saisi
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Cle pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // La couleur sélectionnée par l'utilisateur
  // Par défaut on prend la couleur primaire de l'app
  Color _selectedColor = AppColors.primary;

  // Les 8 couleurs prédéfinies dans le sélecteur de couleur
  final List<Color> _availableColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.error,
    AppColors.warning,
    AppColors.success,
    AppColors.info,
    const Color(0xFF9C27B0), // Violet
    const Color(0xFF795548), // Marron
  ];

  // Vrai si on est en mode modification, faux si création
  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    // Si on est en mode modification, on préremplit les champs
    // avec les valeurs du projet existant
    if (_isEditing) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description;
      _selectedColor = widget.project!.color;
    }
  }

  @override
  void dispose() {
    // Libérer les controllers pour éviter les fuites mémoire
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Méthode appelée quand on appuie sur "Créer" ou "Modifier"
  Future<void> _handleSubmit() async {
    // Étape 1 : Valider le formulaire
    if (!_formKey.currentState!.validate()) return;

    final projectProvider = context.read<ProjectProvider>();
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    if (_isEditing) {
      // MODE MODIFICATION : on crée une copie du projet avec les nouvelles valeurs
      // copyWith() garde les valeurs non modifiées (userId, createdAt, id)
      final updatedProject = widget.project!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
      );
      await projectProvider.updateProject(updatedProject);
    } else {
      // MODE CREATION : on cree un nouveau projet
      final newProject = Project(
        id: const Uuid().v4(), // ID  genere automatiquement
        userId: user.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
      );
      await projectProvider.createProject(newProject);
    }

    // Retourner à l'écran précédent après sauvegarde
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProjectProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        // Le titre change selon le mode
        title: Text(_isEditing ? AppStrings.editProject : AppStrings.newProject),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ============================================================
              // CHAMP NOM DU PROJET
              // ============================================================
              CustomTextField(
                controller: _nameController,
                label: AppStrings.projectName,
                hint: 'Ex: Application mobile',
                prefixIcon: Icons.folder_outlined,
                //  obligatoire et minimu 3 caractères
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.nameRequired;
                  }
                  if (value.trim().length < 3) {
                    return 'Minimum 3 caractères';
                  }
                  return null;
                },
                // Rebuild l'aperçu en temps réel quand on tape
                // (setState pour que la ProjectCard se mette à jour)
              ),
              const SizedBox(height: 16),

              // ============================================================
              // CHAMP DESCRIPTION (multiligne, optionnel)
              // ============================================================
              CustomTextField(
                controller: _descriptionController,
                label: AppStrings.projectDescription,
                hint: 'Décrivez votre projet...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3, // Multiligne
              ),
              const SizedBox(height: 24),

              // ============================================================
              // SÉLECTEUR DE COULEUR
              // 8 cercles colorés dans un Wrap
              // L'utilisateur clique sur un pour le sélectionner
              // ============================================================
              Text(
                AppStrings.projectColor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              // Wrap : dispose les cercles en ligne passe a la ligne si nécessaire
              Wrap(
                spacing: 12, // Espace horizontal entre les cercles
                runSpacing: 12, // Espace vertical entre les lignes
                children: _availableColors.map((color) {
                  // on pose cet Q  Est-ce que cette couleur est la couleur sélectionnée ?
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      // Sélectionner la couleur et reconstruire l'UI
                      setState(() => _selectedColor = color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        // Bordure blanche plus ombre quand la couleur est sélectionnée
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )]
                            : null,
                      ),
                      // Icone de validation sur la couleur sélectionnée
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ============================================================
              // APERÇU EN TEMPS RÉEL
              // ListenableBuilder écoute les changements du controller
              // pour mettre à jour la ProjectCard en temps réel
              // ============================================================
              Text(
                'Aperçu',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              // AnimatedBuilder reconstruit la carte quand les controllers changent
              ListenableBuilder(
                listenable: Listenable.merge([
                  _nameController,
                  _descriptionController,
                ]),
                builder: (context, _) {
                  return ProjectCard(
                    project: Project(
                      id: 'preview',
                      userId: 'preview',
                      // Si le champ est vide, on affiche un placeholder
                      name: _nameController.text.isEmpty
                          ? 'Nom du projet'
                          : _nameController.text,
                      description: _descriptionController.text.isEmpty
                          ? 'Description...'
                          : _descriptionController.text,
                      color: _selectedColor,
                    ),
                    taskCount: 0,
                    onTap: () {},   // Desactive dans l'aper
                    onEdit: () {},  // Desactive dans l'aper
                    onDelete: () {}, // Desactive dans l'aper
                  );
                },
              ),
              const SizedBox(height: 24),

              // ============================================================
              // BOUTON CRÉER ou MODIFIER
              // ============================================================
              CustomButton(
                text: _isEditing ? AppStrings.edit : 'Créer',
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