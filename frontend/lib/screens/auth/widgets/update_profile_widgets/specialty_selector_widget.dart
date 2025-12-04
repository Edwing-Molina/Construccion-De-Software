import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../../../core/constants/app_colors.dart';

class SpecialtySelectorWidget extends StatelessWidget {
  final List<int> selectedSpecialtyIds;
  final List<Specialty> allSpecialties;
  final Function(int) onSpecialtyAdded;
  final Function(int) onSpecialtyRemoved;

  const SpecialtySelectorWidget({
    super.key,
    required this.selectedSpecialtyIds,
    required this.allSpecialties,
    required this.onSpecialtyAdded,
    required this.onSpecialtyRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          if (selectedSpecialtyIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    selectedSpecialtyIds.map<Widget>((specialtyId) {
                      final specialty = allSpecialties.firstWhere(
                        (s) => s.id == specialtyId,
                        orElse:
                            () => Specialty(id: specialtyId, name: 'Unknown'),
                      );
                      return Chip(
                        label: Text(specialty.name),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => onSpecialtyRemoved(specialtyId),
                        backgroundColor: AppColors.uadyBlue.withOpacity(0.1),
                        deleteIconColor: AppColors.uadyBlue,
                        labelStyle: const TextStyle(color: AppColors.uadyBlue),
                      );
                    }).toList(),
              ),
            ),
          ExpansionTile(
            title: Text(
              selectedSpecialtyIds.isEmpty
                  ? 'Seleccionar especialidades'
                  : 'Agregar más especialidades',
              style: TextStyle(
                color:
                    selectedSpecialtyIds.isEmpty
                        ? Colors.grey[600]
                        : AppColors.uadyBlue,
              ),
            ),
            children: <Widget>[
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allSpecialties.length,
                  itemBuilder: (context, index) {
                    final specialty = allSpecialties[index];
                    final isSelected = selectedSpecialtyIds.contains(
                      specialty.id,
                    );

                    return CheckboxListTile(
                      title: Text(specialty.name),
                      value: isSelected,
                      onChanged: (bool? value) {
                        if (value == true) {
                          if (!selectedSpecialtyIds.contains(specialty.id)) {
                            onSpecialtyAdded(specialty.id);
                          }
                        } else {
                          onSpecialtyRemoved(specialty.id);
                        }
                      },
                      activeColor: AppColors.uadyBlue,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
