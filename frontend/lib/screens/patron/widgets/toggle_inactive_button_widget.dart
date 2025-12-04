import 'package:flutter/material.dart';

class ToggleInactiveButtonWidget extends StatelessWidget {
  final bool showInactive;
  final VoidCallback onPressed;
  final ButtonStyle buttonStyle;

  const ToggleInactiveButtonWidget({
    super.key,
    required this.showInactive,
    required this.onPressed,
    required this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: buttonStyle.copyWith(
        padding: MaterialStatePropertyAll(
          const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        showInactive
            ? 'Ocultar patrones inactivos'
            : 'Mostrar patrones inactivos',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
