import 'package:flutter/material.dart';
import 'package:frontend/models/doctor_work_pattern.dart';

class PatternCardWidget extends StatelessWidget {
  final DoctorWorkPattern pattern;
  final Color primaryColor;
  final Color accentColor;
  final VoidCallback onDeactivate;
  final String Function(TimeOfDay?) formatTimeOfDay;
  final String Function(DateTime?) formatDate;

  const PatternCardWidget({
    super.key,
    required this.pattern,
    required this.primaryColor,
    required this.accentColor,
    required this.onDeactivate,
    required this.formatTimeOfDay,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          '${pattern.dayOfWeek.name} - '
          '${formatTimeOfDay(pattern.startTimePattern)} a '
          '${formatTimeOfDay(pattern.endTimePattern)}',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Desde: ${formatDate(pattern.startDateEffective)} '
          'hasta: ${pattern.endDateEffective != null ? formatDate(pattern.endDateEffective) : "Indefinido"}\n'
          'Slots: ${pattern.slotDurationMinutes} min\n'
          'Activo: ${pattern.isActive ? "Sí" : "No"}',
        ),
        trailing:
            pattern.isActive
                ? IconButton(
                  icon: Icon(Icons.block, color: accentColor),
                  tooltip: 'Desactivar patrón',
                  onPressed: onDeactivate,
                )
                : null,
      ),
    );
  }
}
