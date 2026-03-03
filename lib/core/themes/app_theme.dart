import 'package:flutter/material.dart';
import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/core/constants/app_colors.dart';

/**
* ThemeData est la classe qui defini l'apparence global de l'application:
 * - couleurs
 * -typographique
 * -styles des composants(buttonTheme,inputDecorationTheme)
*/

class AppTheme{
  AppTheme._(); //constructeur prive pour empecher la creation de l'objet
  //===============configuration du theme claire=============
  static ThemeData get lightTheme{
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        //surcharge pour personnaliser
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error

      ),
      //couleur de fond
      scaffoldBackgroundColor: AppColors.background,
      //AppBar
      appBarTheme:  AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700
        ),
      ),

      //pour les boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),

          ),
          textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700

          )

        )
      ),

      //Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: TextStyle(color: AppColors.textDisable),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16
        ),
        //Au repos
        border: OutlineInputBorder(
          borderRadius:  BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border)
        ),
        //
        enabledBorder:OutlineInputBorder(
            borderRadius:  BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary)
        ),
        errorBorder: OutlineInputBorder(
            borderRadius:  BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error)
        ),
      )
    );
  }
//===============configuration du theme Sombre=========
  static ThemeData get darkTheme{
    return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,


        ),
    );
  }
}