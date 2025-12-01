import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomDropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final IconData icon;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool isExpanded;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.icon,
    required this.onChanged,
    this.validator,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth > 600 ? 400 : double.infinity,
          ),
          child: Stack(
            children: [
              DropdownButtonFormField<String>(
                value: value,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: AppColors.iconGray),
                  contentPadding: const EdgeInsets.fromLTRB(45, 14, 15, 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.uadyBlue,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.inputBg,
                ),
                items:
                    items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                onChanged: onChanged,
                validator: validator,
                isExpanded: isExpanded,
                dropdownColor: AppColors.white,
              ),
              Positioned(
                left: 15,
                top: 14,
                child: Icon(icon, color: AppColors.iconGray, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}
