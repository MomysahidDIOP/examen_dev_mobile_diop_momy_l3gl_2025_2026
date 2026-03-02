

import 'package:flutter/animation.dart';

/**
 *Pallette de la couleur de l'application sunuTask
 */
class AppColors {
  AppColors._();//constructeur prive pour empecher l'instanciation
  //=======couleur principale======
   static const Color primary = Color(0xFF0293ED);
   static const Color primaryLight = Color(0xFF64BBF1);
   static const Color primaryDark = Color(0xFF03436D);

   //==========couleurs secondaire===========
  static const Color secondary = Color(0xFF61E561);
  static const Color secondaryLight = Color(0xFF41F246);
  static const Color secondaryDark = Color(0xFF05412B);
  static const Color white = Color(0xFFFFFFFF);




  //==========couleurs neutre===========
  //Fond de l'application
  static const Color background = Color(0xFFE2DEDE);

  //Fond des cartes et surfaces
  static const Color surface = Color(0xFFFFFFFF);

  // text principal
  static const Color textPrimary = Color(0xFF263B4D);

  // text secondaire
  static const Color textSecondary = Color(0xFF5C96C2);

  // text desactive
  static const Color textDisable = Color(0xFF919194);

  // Bordures et separateurs
  static const Color border = Color(0xFFCECECE);


//==========couleurs neutre===========
   // Success - Vert
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFC8FFDB);

  // Erreur - Rouge
  static const Color error = Color(0xFFE90000);
  static const Color errorLight = Color(0xFFFBADAD);

  // Warning -Orange
  static const Color warning = Color(0xFFD54F04);
  static const Color warningLight = Color(0xFFF7A071);

  // Information - Bleue
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF7EAAF1);

  //===============Couleurs des priorites===============
// ============== Couleurs des priorites ==============

  /// Priorite basse
  static const Color priorityLow = Color(0xFF22C55E);

  /// Priorite moyenne
  static const Color priorityMedium = Color(0xFFF59E0B);

  /// Priorite haute
  static const Color priorityHigh = Color(0xFFEF4444);

  // ============== Couleurs des statuts ==============

  /// A faire
  static const Color statusTodo = Color(0xFF64748B);

  /// En cours
  static const Color statusInProgress = Color(0xFF3B82F6);

  /// Termine
  static const Color statusDone = Color(0xFF22C55E);



}