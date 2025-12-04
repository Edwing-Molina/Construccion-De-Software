import 'package:flutter/material.dart';
import 'package:frontend/models/specialty.dart';

class SpecialtyDropdownWidget extends StatelessWidget {
  final List<Specialty> specialties;
  final int? selectedSpecialtyId;
  final ValueChanged<int?> onSpecialtyChanged;

  const SpecialtyDropdownWidget({
    super.key,
    required this.specialties,
    required this.selectedSpecialtyId,
    required this.onSpecialtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final specialtiesWithAll = [null, ...specialties];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: DropdownMenu<int?>(
        width: MediaQuery.of(context).size.width,
        initialSelection: selectedSpecialtyId,
        hintText: 'Especialidad',
        dropdownMenuEntries:
            specialtiesWithAll.map((s) {
              if (s == null) {
                return DropdownMenuEntry<int?>(
                  value: null,
                  label: 'Todas las especialidades',
                );
              } else {
                return DropdownMenuEntry<int?>(value: s.id, label: s.name);
              }
            }).toList(),
        onSelected: onSpecialtyChanged,
      ),
    );
  }
}
