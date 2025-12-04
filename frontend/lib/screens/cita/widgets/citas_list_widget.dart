import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/models/models.dart';

class CitasListWidget extends StatelessWidget {
  final List<Appointment> citasVisibles;
  final bool isLoading;
  final String? userRole;
  final Function(Appointment) onBuildCitaCard;

  const CitasListWidget({
    super.key,
    required this.citasVisibles,
    required this.isLoading,
    required this.userRole,
    required this.onBuildCitaCard,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.uadyBlue),
      );
    }

    if (citasVisibles.isEmpty) {
      return const Center(
        child: Text(
          'No tienes citas por el momento',
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: citasVisibles.length,
      itemBuilder: (context, index) {
        final cita = citasVisibles[index];
        return onBuildCitaCard(cita) as Widget;
      },
    );
  }
}
