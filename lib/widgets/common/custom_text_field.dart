import 'package:flutter/material.dart';

// CustomTextField est un champ de texte reutilisable.
// C'est un StatefulWidget car il doit gérer un état interne :
class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  // Gère si le mot de passe est visible ou caché
  // true = caché (par défaut), false = visible
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      // Si obscureText est true ET _isObscured est true → texte caché
      // Si obscureText est false → texte toujours visible (champ normal)
      obscureText: widget.obscureText ? _isObscured : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      // Un champ mot de passe ne peut avoir qu'une seule ligne
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,

        // Le bouton œil apparaît SEULEMENT si c'est un champ mot de passe
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            // setState() dit à Flutter de reconstruire le widget
            // qvec la nouvelle valeur isOn

            setState(() => _isObscured = !_isObscured);
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}