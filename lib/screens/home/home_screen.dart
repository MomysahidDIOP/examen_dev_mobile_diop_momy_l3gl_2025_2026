import 'package:flutter/material.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/core/constants/app_colors.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/core/constants/app_strings.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
         backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text(
          'Ecran Acceuil',
          style: TextStyle(
            fontSize: 24,
            color: AppColors.textPrimary
          ),
        ),
      ),
    );
  }

}