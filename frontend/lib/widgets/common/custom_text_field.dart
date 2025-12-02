import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: AppDimensions.maxInputWidth),
      child: Stack(
        children: [
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly, // Aplicar propiedad readOnly
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.iconGray),
              contentPadding: const EdgeInsets.fromLTRB(45, 14, 15, 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                borderSide: const BorderSide(color: AppColors.lightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                borderSide: const BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                borderSide: const BorderSide(
                  color: AppColors.uadyBlue,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.inputBg,
              suffixIcon: suffixIcon,
            ),
            validator: validator,
          ),
          Positioned(
            left: 15,
            top: 14,
            child: Icon(icon, color: AppColors.iconGray, size: 20),
          ),
        ],
      ),
    );
  }
}
