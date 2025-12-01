import 'package:flutter/material.dart';
import '../../core/utils/date_formatter.dart';
import '../../widgets/widgets.dart';

class BirthDateField extends StatelessWidget {
  final TextEditingController controller;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final String? Function(String?)? validator;
  final String hintText;

  const BirthDateField({
    super.key,
    required this.controller,
    required this.selectedDate,
    required this.onDateSelected,
    this.validator,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectBirthDate(context),
      child: AbsorbPointer(
        child: CustomTextField(
          controller: controller,
          hintText: hintText,
          icon: Icons.cake_outlined,
          validator: validator,
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
      controller.text = DateFormatter.formatForDisplay(picked);
    }
  }
}
