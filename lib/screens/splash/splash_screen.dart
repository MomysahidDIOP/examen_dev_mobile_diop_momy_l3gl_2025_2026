import 'dart:async';

import 'package:flutter/material.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/core/constants/app_colors.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/core/constants/app_strings.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/screens/home/home_screen.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/screens/onboarding/onboarding_screen.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/providers/app_provider.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/providers/auth_provider.dart';
//on voit le logo

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _showLogo = false;
  bool _showText = false;

  //============Cycle de vie===========

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _startTimer();
  }

  @override
  void dispose() {
    //Important: annuler la timer pour eviter les fuites de memoire
    _timer?.cancel();
    super.dispose();
  }
  void _startAnimations(){
    Future.delayed(Duration(microseconds: 100), (){

      if(mounted) {
        setState(() => _showLogo = true);
      }

    });

    Future.delayed(Duration(microseconds: 1500), (){
      if(mounted) {
        setState(() => _showText = true);
      }

    });
  }

  void _startTimer(){
    _timer = Timer(Duration(seconds: 3),_navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;


    final appProvider = context.read<AppProvider>();
    final authProvider = context.read<AuthProvider>();

    if (!appProvider.isOnboardingComplete) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    } else if (!authProvider.isAuthenticated) {
      // On ira vers le LoginScreen (qu'on va créer demain)
      // Pour l'instant, on peut laisser un print ou rediriger
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            _buidLogo(),
            SizedBox(height: 24,),
            //Nom App
            _buidAppName(),
            SizedBox(height: 8,),
            //Slogan
            _buidAppSlogan(),
            SizedBox(height: 48,),
            //Chargement
            _buidLoadingIndicator()
          ],
        ),
      ),
    );
  }
  Widget _buidLogo(){
    return AnimatedOpacity(// Rendu fondu :Demarrage Lent puis accelaration progressive
      opacity: _showLogo ? 1: 0,
      duration: Duration(microseconds: 500),
      curve: Curves.easeIn,
      child: AnimatedScale(//Demarrage rapide puis deceleration
        scale: _showLogo ? 1: 0,
        duration: Duration(microseconds: 500),
        curve: Curves.easeOut,
        child: Container(
          width: 124,
          height: 124,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(180),
                blurRadius: 20,
                offset: Offset(0, 10)
              )
            ]
            //shape: BoxShape.circle
          ),
          child: Icon(
            Icons.task_alt,
            size: 65,
            color: AppColors.white..withAlpha(200),
          ),
        ),
      ),
    );
  }

  Widget _buidAppName(){
    return AnimatedOpacity(
      opacity: _showText ? 1: 0,
      duration: Duration(microseconds: 500),
      child: Text(
       AppStrings.appName,
        style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buidAppSlogan(){
    return AnimatedOpacity(
      opacity: _showText ? 1: 0,
      duration: Duration(microseconds: 500),
      child: Text(
        AppStrings.appSlogan,
        style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary
        ),
      ),
    );
  }


  Widget _buidLoadingIndicator(){
    return AnimatedOpacity(
      opacity: _showText ? 1: 0,
      duration: Duration(microseconds: 500),
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          //value: 0.7,//taux de progression
          color: AppColors.primary,
          strokeWidth: 8.0,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}