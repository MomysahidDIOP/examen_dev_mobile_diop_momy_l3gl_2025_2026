import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Libérer les controllers quand l'écran est détruit

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // ÉTAPE 1 : Valider le formulaire
    // validate() appelle tous les validators des champs
    // et retourne true seulement si TOUS sont valides
    if (_formKey.currentState!.validate()) {

      // ÉTAPE 2 : Récupérer le provider sans écouter les changements
      // context.read = juste lire une fois, pas besoin de rebuild
      final auth = context.read<AuthProvider>();

      // ÉTAPE 3 : Appeler la méthode login du provider
      final success = await auth.login(
        _emailController.text.trim(), // trim() enlève les espaces inutiles
        _passwordController.text,
      );

      // ÉTAPE 4 : Selon le résultat...
      if (success && mounted) {
        // pushAndRemoveUntil : aller vers HomeScreen ET supprimer
        // tout l'historique de navigation (on ne peut plus revenir en arrière)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false, // false = supprimer toutes les routes précédentes
        );
      } else if (mounted) {
        // Afficher le message d'erreur du provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? "Erreur de connexion"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch : écouter les changements du provider
    // quand isLoading change → le widget se reconstruit
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Text(
                  "Bienvenue !",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // obscureText au lieu de isPassword
                CustomTextField(
                  controller: _emailController,
                  label: "Email",
                  hint: "momy@gmail.com",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email requis";
                    // Vérifier @ ET . comme demandé par le prof
                    if (!value.contains('@') || !value.contains('.')) {
                      return "Email invalide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  label: "Mot de passe",
                  hint: "******",
                  prefixIcon: Icons.lock_outline,
                  obscureText: true, // ← obscureText au lieu de isPassword
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Minimum 6 caractères";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: "Se connecter",
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleLogin,
                ),
                const SizedBox(height: 16),

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