import 'package:flutter/material.dart';

class WorkPatternFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String? selectedDay;
  final List<String> diasSemana;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final DateTime? startDate;
  final int slotDurationMinutes;
  final bool isActive;
  final bool isLoading;
  final Color primaryColor;
  final Color accentColor;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final VoidCallback onPickStartDate;
  final ValueChanged<String?> onDayChanged;
  final ValueChanged<int?> onSlotDurationChanged;
  final ValueChanged<bool> onIsActiveChanged;
  final ValueChanged<int?> onDurationDaysChanged;
  final VoidCallback onCreatePattern;
  final String Function(TimeOfDay?) formatTimeOfDay;
  final String Function(DateTime?) formatDate;
  final InputDecoration Function(String) inputDecoration;
  final ButtonStyle buttonStyle;

  const WorkPatternFormWidget({
    super.key,
    required this.formKey,
    required this.selectedDay,
    required this.diasSemana,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.slotDurationMinutes,
    required this.isActive,
    required this.isLoading,
    required this.primaryColor,
    required this.accentColor,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.onPickStartDate,
    required this.onDayChanged,
    required this.onSlotDurationChanged,
    required this.onIsActiveChanged,
    required this.onDurationDaysChanged,
    required this.onCreatePattern,
    required this.formatTimeOfDay,
    required this.formatDate,
    required this.inputDecoration,
    required this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: inputDecoration('Día de la semana'),
            value: selectedDay,
            items:
                diasSemana
                    .map(
                      (d) => DropdownMenuItem<String>(value: d, child: Text(d)),
                    )
                    .toList(),
            onChanged: onDayChanged,
            validator: (v) => v == null ? 'Selecciona un día' : null,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: inputDecoration('Hora Inicio'),
                  child: TextButton(
                    onPressed: onPickStartTime,
                    child: Text(
                      startTime == null
                          ? 'Seleccionar'
                          : formatTimeOfDay(startTime),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InputDecorator(
                  decoration: inputDecoration('Hora Fin'),
                  child: TextButton(
                    onPressed: onPickEndTime,
                    child: Text(
                      endTime == null
                          ? 'Seleccionar'
                          : formatTimeOfDay(endTime),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InputDecorator(
            decoration: inputDecoration('Fecha Inicio'),
            child: TextButton(
              onPressed: onPickStartDate,
              child: Text(
                startDate == null ? 'Seleccionar' : formatDate(startDate),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: inputDecoration('Duración en días'),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa duración';
              final n = int.tryParse(v);
              if (n == null || n < 1) return 'Duración inválida';
              return null;
            },
            onChanged: (v) => onDurationDaysChanged(int.tryParse(v)),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            decoration: inputDecoration('Duración de slot (minutos)'),
            value: slotDurationMinutes,
            items:
                [15, 30, 45, 60]
                    .map(
                      (e) => DropdownMenuItem<int>(value: e, child: Text('$e')),
                    )
                    .toList(),
            onChanged: onSlotDurationChanged,
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Activo'),
            value: isActive,
            onChanged: onIsActiveChanged,
            activeColor: accentColor,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: buttonStyle,
            onPressed: isLoading ? null : onCreatePattern,
            child: const Text('Crear Patrón'),
          ),
        ],
      ),
    );
  }
}
