import 'package:flutter/material.dart';

class AuthMessageWidget extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onDismiss;

  const AuthMessageWidget({
    super.key,
    required this.message,
    this.isError = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade50 : Colors.green.shade50,
        border: Border.all(
          color: isError ? Colors.red.shade200 : Colors.green.shade200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red.shade600 : Colors.green.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red.shade800 : Colors.green.shade800,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: isError ? Colors.red.shade600 : Colors.green.shade600,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
