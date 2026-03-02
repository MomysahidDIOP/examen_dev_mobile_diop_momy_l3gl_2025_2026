import 'package:flutter/material.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/core/constants/app_colors.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/core/constants/app_strings.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/models/OnboardingItem.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/screens/home/home_screen.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/services/storage_service.dart';


class OnboardingScreen extends StatefulWidget{
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();


}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Le PageController permet de contrôler le défilement des pages (aller à la suivante/précédente)
  final PageController _pageController = PageController();

  // Variable pour suivre l'index de la page affichée (0, 1 ou 2)
  int _currentPage = 0;

  // Liste des données à afficher sur chaque page

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      icon: Icons.explore,
      color: AppColors.primary,
    ),
    OnboardingItem(
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      icon: Icons.people_alt,
      color: AppColors.secondary,
    ),
    OnboardingItem(
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      icon: Icons.checklist_rtl_rounded,
      color: AppColors.warning,
    ),
  ];

  @override


  // Fonction appelee  pour quitter l'onboarding définitivement
  void _finishOnboarding() {
    // Correction : on passe "true" pour dire que c'est fini
    StorageService.instance.setOnboardingComplete(true);

    // On change d'écran vers le LoginScreen (comme demandé dans la Partie 3.3 du PDF)
    // Au lieu de HomeScreen, on doit maintenant aller vers LoginScreen
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // SafeArea évite que le contenu touche l'enco ou la barre de batterie
      body: SafeArea(
        child: Column(
          children: [
            // Section du haut : Bouton Skip (Passer)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    AppStrings.skip,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            //  Le contenu défilant
            // Expanded permet au PageView de prendre toute la place disponible
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                // On met a jour l'index quand on change de page
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 100, color: item.color),
                        const SizedBox(height: 42),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Section du bas : Navigation (Boutons et points)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Affiche "Précédent" seulement si on n'est pas sur la première page
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text(AppStrings.previous),
                    )
                  else
                    const SizedBox(width: 80), // Espace vide pour garder l'alignement

                  // Les petits points indicateurs de page
                  Row(
                    children: List.generate(
                      _items.length,
                          (index) => _buildDot(index),
                    ),
                  ),

                  // Bouton Suivant (ou Commencer sur la derniere page)
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _items.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == _items.length - 1
                          ? AppStrings.getStarted
                          : AppStrings.next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour construire un point indicateur
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      // Ils devient plus large
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

