import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // 1. Ta clé est bien là
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // On utilise SafeArea pour éviter que le contenu touche la barre d'état (heure, batterie)
      body: SafeArea(
        // 2. On entoure tout avec Form pour activer la validation
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Pour éviter les erreurs de pixels quand le clavier sort
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60), // Un peu d'espace en haut
                Text(
                  "Bienvenue !",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Champ Email
                CustomTextField(
                  controller: _emailController,
                  label: "Email",
                  hint: "votre@email.com",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  // Optionnel : tu peux ajouter ton validateur ici
                  validator: (value) => (value == null || !value.contains('@')) ? "Email invalide" : null,
                ),

                const SizedBox(height: 16),

                // Champ Mot de passe
                CustomTextField(
                  controller: _passwordController,
                  label: "Mot de passe",
                  hint: "******",
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) => (value == null || value.length < 6) ? "Minimum 6 caractères" : null,
                ),

                const SizedBox(height: 24),

                // Bouton de connexion
                CustomButton(
                  text: "Se connecter",
                  onPressed: () {
                    // 3. On vérifie si le formulaire est valide avant de naviguer
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                ),

                const SizedBox(height: 16),

                // 4. Lien vers l'inscription (demandé dans le projet)
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("Pas de compte ? S'inscrire"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}