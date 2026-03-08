import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Contrôleurs pour récupérer le texte
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Clé pour la validation du formulaire
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Nettoyage des ressources
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // 1. Déclencher la validation visuelle
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      // 2. Appeler la logique d'inscription du Provider
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // 3. Si succès, on va vers l'accueil
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        // 4. Si erreur, afficher un message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? "Erreur d'inscription")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // On écoute le chargement pour animer le bouton
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Créer un compte",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Champ Nom
                CustomTextField(
                  controller: _nameController,
                  label: "Nom complet",
                  hint: "Ex: Momy Diop",
                  prefixIcon: Icons.person_outline,
                  validator: (v) => (v == null || v.length < 2) ? "Nom trop court (min 2)" : null,
                ),
                const SizedBox(height: 16),

                // Champ Email
                CustomTextField(
                  controller: _emailController,
                  label: "Email",
                  hint: "votre@email.com",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? "Email invalide" : null,
                ),
                const SizedBox(height: 16),

                // Champ Mot de passe
                CustomTextField(
                  controller: _passwordController,
                  label: "Mot de passe",
                  hint: "******",
                  prefixIcon: Icons.lock_outline,
                  obscureText: true, // ← isPassword: true → obscureText: true
                  validator: (v) => (v == null || v.length < 6) ? "Minimum 6 caractères" : null,
                ),
                const SizedBox(height: 16),

                // Confirmation Mot de passe
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: "Confirmer",
                  hint: "******",
                  prefixIcon: Icons.lock_clock_outlined,
                  obscureText: true, // ← isPassword: true → obscureText: true
                  validator: (v) => (v != _passwordController.text) ? "Les mots de passe diffèrent" : null,
                ),
                const SizedBox(height: 32),

                // Bouton d'inscription
                CustomButton(
                  text: "S'inscrire",
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleRegister,
                ),

                const SizedBox(height: 16),

                // Retour au Login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Déjà un compte ? Se connecter"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}