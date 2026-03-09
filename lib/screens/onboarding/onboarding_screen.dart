import 'package:flutter/material.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/core/constants/app_colors.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/core/constants/app_strings.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/models/OnboardingItem.dart';
import 'package:provider/provider.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/providers/app_provider.dart';

// OnboardingScreen affiche 3 pages de présentation de l'application
//on le met en StatefulWidget car il doit gérer :
//   - _currentPage : l'index de la page affichée
//   - _pageController : le controleur de défilement
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Les données des 3 pages d'onboarding
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

  // Libérer le PageController quand l'écran est détruit
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Appelée quand l'utilisateur clique sur "Commencer" ou "Passer"
  // Elle sauvegarde que l'onboarding est terminé et navigue vers Login
  Future<void> _finishOnboarding() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            // Bouton "Passer" en haut à droite
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

            // Contenu défilant des 3 pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
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

            // Barre de navigation en bas : Précédent | Points | Suivant
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // Visibility au lieu de if/else
                  // maintainSize : garde l'espace même quand le bouton est caché
                  // Comme ça le layout ne "saute" pas quand le bouton apparaît/disparaît
                  Visibility(
                    visible: _currentPage > 0,
                    maintainSize: true,
                    maintainState: true,
                    maintainAnimation: true,
                    child: TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text(AppStrings.previous),
                    ),
                  ),

                  // Points indicateurs de page
                  Row(
                    children: List.generate(
                      _items.length,
                          (index) => _buildDot(index),
                    ),
                  ),

                  // Bouton Suivant / Commencer
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

  // Construit un point indicateur animé
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      // Le point actif est plus large
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}