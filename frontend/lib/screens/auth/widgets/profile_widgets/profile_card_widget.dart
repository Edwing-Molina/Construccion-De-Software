import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/common/custom_button.dart';
import '../../../../models/models.dart';
import 'detail_row_widget.dart';
import 'section_title_widget.dart';
import 'clinic_info_widget.dart';

class ProfileCardWidget extends StatelessWidget {
  final User user;
  final List<Specialty> specialties;
  final List<ClinicInfo> clinics;
  final VoidCallback onEditPressed;

  const ProfileCardWidget({
    super.key,
    required this.user,
    required this.specialties,
    required this.clinics,
    required this.onEditPressed,
  });

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final doctor = user.doctor;
    final patient = user.patient;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRowWidget(label: 'Nombre', value: user.name),
                DetailRowWidget(label: 'Correo', value: user.email),
                if (user.phone != null)
                  DetailRowWidget(label: 'Teléfono', value: user.phone!),
                const Divider(),
                if (patient != null) ...[
                  SectionTitleWidget(title: 'Información del Paciente'),
                  DetailRowWidget(
                    label: 'Fecha de nacimiento',
                    value: _formatDate(patient.birth) ?? 'No especificada',
                  ),
                  if (patient.gender != null)
                    DetailRowWidget(label: 'Género', value: patient.gender!),
                  if (patient.bloodType != null)
                    DetailRowWidget(
                      label: 'Tipo de Sangre',
                      value: patient.bloodType!,
                    ),
                  if (patient.emergencyContactName != null)
                    DetailRowWidget(
                      label: 'Contacto de Emergencia',
                      value: patient.emergencyContactName!,
                    ),
                  if (patient.emergencyContactPhone != null)
                    DetailRowWidget(
                      label: 'Tel. de Emergencia',
                      value: patient.emergencyContactPhone!,
                    ),
                  if (patient.nssNumber != null)
                    DetailRowWidget(
                      label: 'Número NSS',
                      value: patient.nssNumber!,
                    ),
                ],
                if (doctor != null) ...[
                  SectionTitleWidget(title: 'Descripción del Doctor'),
                  if (doctor.description != null &&
                      doctor.description!.isNotEmpty)
                    DetailRowWidget(
                      label: 'Cédula Profesional',
                      value: doctor.description!,
                    ),
                  DetailRowWidget(
                    label: 'Especialidades',
                    value:
                        specialties.isNotEmpty
                            ? specialties.map((s) => s.name).join(', ')
                            : 'No asignadas',
                  ),
                  ClinicInfoWidget(clinics: clinics),
                ],
                const SizedBox(height: 20),
                CustomButton(text: 'Editar Perfil', onPressed: onEditPressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
