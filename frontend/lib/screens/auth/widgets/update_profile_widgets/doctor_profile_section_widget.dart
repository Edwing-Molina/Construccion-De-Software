import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/common/custom_text_field.dart';
import 'specialty_selector_widget.dart';

class DoctorProfileSectionWidget extends StatelessWidget {
  final TextEditingController descriptionController;
  final List<int> selectedSpecialtyIds;
  final List<Specialty> allSpecialties;
  final Function(int) onSpecialtyAdded;
  final Function(int) onSpecialtyRemoved;
  final String? selectedClinicId;
  final Function(String?) onClinicChanged;
  final List<ClinicInfo> clinics;
  final TextEditingController officeNumberController;

  const DoctorProfileSectionWidget({
    super.key,
    required this.descriptionController,
    required this.selectedSpecialtyIds,
    required this.allSpecialties,
    required this.onSpecialtyAdded,
    required this.onSpecialtyRemoved,
    required this.selectedClinicId,
    required this.onClinicChanged,
    required this.clinics,
    required this.officeNumberController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          hintText: 'Descripción',
          icon: Icons.info_outline,
          controller: descriptionController,
        ),
        const SizedBox(height: 20),
        const Text(
          'Especialidades',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SpecialtySelectorWidget(
          selectedSpecialtyIds: selectedSpecialtyIds,
          allSpecialties: allSpecialties,
          onSpecialtyAdded: onSpecialtyAdded,
          onSpecialtyRemoved: onSpecialtyRemoved,
        ),
        const SizedBox(height: 20),
        const Text('Clínica', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedClinicId,
          items:
              clinics
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c.id.toString(),
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
          onChanged: onClinicChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: 'Número de Consultorio',
          icon: Icons.door_front_door_outlined,
          controller: officeNumberController,
          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
        ),
      ],
    );
  }
}
