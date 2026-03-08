import 'package:flutter/material.dart';

// CustomButton est un bouton reutilisable avec DEUX variantes :
// - ElevatedButton (bouton plein, par défaut)
// - OutlinedButton (bouton avec contour, quand isOutlined = true)
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {

    // Le contenu du bouton : spinner OU (icône +) texte
    final child = isLoading
    // Si chargement en cours on affiche un spinner
        ? const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    )
    // Sinon on affichera l'icone (si présente) et le texte
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // L'icone s'affiche seulement si elle est fournie
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    // Le style selon la variante choisie
    final buttonStyle = isOutlined
    // Style bouton contour
        ? OutlinedButton.styleFrom(
      foregroundColor: color ?? Theme.of(context).primaryColor,
      side: BorderSide(color: color ?? Theme.of(context).primaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    )
    // Style bouton plein
        : ElevatedButton.styleFrom(
      backgroundColor: color ?? Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return SizedBox(
      width: width ?? double.infinity, // Pleine largeur par défaut
      height: height ?? 50,
      child: isOutlined
          ? OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      )
          : ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      ),
    );
  }
}