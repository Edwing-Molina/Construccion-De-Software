import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/widgets.dart';
import '../../models/appointment.dart';
import '../../services/services.dart';
import 'package:intl/intl.dart';

class HistorialMedicoScreen extends StatefulWidget {
  const HistorialMedicoScreen({super.key});

  @override
  State<HistorialMedicoScreen> createState() => _HistorialMedicoScreenState();
}

class _HistorialMedicoScreenState extends State<HistorialMedicoScreen> {
  bool isLoading = false;
  List<Appointment> historialItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  Future<void> _loadHistorial() async {
    setState(() {
      isLoading = true;
    });

    try {
      final serviceCitas = serviceLocator.serviceCitas;

      final citas = await serviceCitas.obtenerHistorialMedico();

      setState(() {
        historialItems = citas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar historial: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        title: 'Historial Médico',
        onLogout: () => context.go('/login'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 800),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => context.go('/home'),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Mi Historial Médico',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.uadyBlue,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (historialItems.isEmpty)
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No hay registros en tu historial médico',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...historialItems.map(
                          (item) => HistorialCard(
                            fecha:
                                item.availableSchedule?.date != null
                                    ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(item.availableSchedule!.date)
                                    : 'Fecha no disponible',
                            doctor:
                                item.doctor?.user?.name ??
                                'Doctor no especificado',
                            especialidad:
                                item.doctor?.specialties?.isNotEmpty == true
                                    ? item.doctor!.specialties!.first.name
                                    : 'Especialidad no especificada',
                            estado: item.status ?? 'Desconocido',
                            clinica:
                                item.availableSchedule?.clinic?.name ??
                                'Clínica no especificada',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}

class HistorialCard extends StatelessWidget {
  final String fecha;
  final String doctor;
  final String especialidad;
  final String estado;
  final String clinica;

  const HistorialCard({
    super.key,
    required this.fecha,
    required this.doctor,
    required this.especialidad,
    required this.estado,
    required this.clinica,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fecha,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.uadyBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.uadyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  especialidad,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.uadyBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            doctor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Clínica: $clinica',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              Text(
                'Estado: ',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      estado == 'completado'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  estado == 'completado' ? 'Completada' : 'Cancelada',
                  style: TextStyle(
                    fontSize: 12,
                    color: estado == 'completado' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
