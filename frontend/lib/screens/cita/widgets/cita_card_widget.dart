import 'package:flutter/material.dart';
import 'package:frontend/models/appointment.dart';
import 'package:frontend/widgets/common/custom_button.dart';
import 'package:intl/intl.dart';

class CitaCardWidget extends StatelessWidget {
  final Appointment cita;
  final String? userRole;
  final bool isLoading;
  final VoidCallback? onCancelPressed;
  final VoidCallback? onCompletePressed;
  final VoidCallback? onRemovePressed;

  const CitaCardWidget({
    super.key,
    required this.cita,
    required this.userRole,
    required this.isLoading,
    this.onCancelPressed,
    this.onCompletePressed,
    this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final displayDateFormat = DateFormat('dd/MM/yyyy');

    final pacienteNombre = cita.patient?.user?.name ?? 'Paciente';
    final fechaDate =
        (cita.appointmentDate ?? cita.availableSchedule?.date)?.toLocal();
    final startTime = cita.availableSchedule?.startTime;
    final horaFormatted = startTime != null ? startTime.format(context) : 'N/D';
    final status = cita.status;
    final doctorId = cita.doctor?.id;
    final clinicId = cita.availableSchedule?.clinicId;
    final formattedDate =
        fechaDate != null ? displayDateFormat.format(fechaDate) : 'N/D';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userRole == 'doctor')
              Text(
                'Paciente: $pacienteNombre',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            if (userRole == 'patient')
              Text(
                'Doctor $doctorId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 6),
            Text('Fecha: $formattedDate - $horaFormatted'),
            const SizedBox(height: 6),
            Text(
              'Estado: $status',
              style: TextStyle(
                color:
                    status == 'completado'
                        ? Colors.green
                        : (status == 'cancelada' ? Colors.red : Colors.orange),
              ),
            ),
            if (userRole == 'patient' &&
                status != 'completado' &&
                status != 'cancelada')
              CustomButton(
                text: 'Cancelar cita',
                onPressed: isLoading ? null : onCancelPressed,
                isLoading: isLoading,
              ),
            const SizedBox(height: 8),
            if (userRole == 'doctor' &&
                status != 'completado' &&
                status != 'cancelada')
              CustomButton(
                text: 'Completar Cita',
                onPressed: isLoading ? null : onCompletePressed,
                isLoading: isLoading,
              ),
            if (userRole == 'doctor' && status == 'cancelada')
              CustomButton(
                text: 'Quitar cita de la lista',
                onPressed: isLoading ? null : onRemovePressed,
                isLoading: isLoading,
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text('Más información'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Detalles de la Cita'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (clinicId != null)
                              Text('Clínica Uady:$clinicId'),
                            Text('Hora inicio: $horaFormatted'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
