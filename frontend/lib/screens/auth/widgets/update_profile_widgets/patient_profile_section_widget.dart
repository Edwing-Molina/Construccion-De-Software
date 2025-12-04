import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/common/custom_text_field.dart';

class PatientProfileSectionWidget extends StatelessWidget {
  final String? selectedGender;
  final Function(String?) onGenderChanged;
  final List<String> genders;
  final String? selectedBloodType;
  final Function(String?) onBloodTypeChanged;
  final List<String> bloodTypes;
  final DateTime? selectedBirthDate;
  final VoidCallback onBirthDateTap;
  final TextEditingController emergencyNameController;
  final TextEditingController emergencyPhoneController;
  final TextEditingController nssController;

  const PatientProfileSectionWidget({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.genders,
    required this.selectedBloodType,
    required this.onBloodTypeChanged,
    required this.bloodTypes,
    required this.selectedBirthDate,
    required this.onBirthDateTap,
    required this.emergencyNameController,
    required this.emergencyPhoneController,
    required this.nssController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedGender,
          items:
              genders
                  .map(
                    (g) => DropdownMenuItem<String>(value: g, child: Text(g)),
                  )
                  .toList(),
          onChanged: onGenderChanged,
          decoration: const InputDecoration(
            labelText: 'Género',
            filled: true,
            fillColor: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: selectedBloodType,
          items:
              bloodTypes
                  .map(
                    (b) => DropdownMenuItem<String>(value: b, child: Text(b)),
                  )
                  .toList(),
          onChanged: onBloodTypeChanged,
          decoration: const InputDecoration(
            labelText: 'Tipo de Sangre',
            filled: true,
            fillColor: AppColors.lightGray,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onBirthDateTap,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha de nacimiento',
              filled: true,
              fillColor: AppColors.lightGray,
            ),
            child: Text(
              selectedBirthDate != null
                  ? DateFormat('dd/MM/yyyy').format(selectedBirthDate!)
                  : 'Selecciona una fecha',
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: 'Contacto de Emergencia',
          icon: Icons.contact_phone,
          controller: emergencyNameController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: 'Teléfono de Emergencia',
          icon: Icons.phone_callback,
          controller: emergencyPhoneController,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: 'Número de Seguro Social',
          icon: Icons.health_and_safety,
          controller: nssController,
        ),
      ],
    );
  }
}
