import 'package:flutter/material.dart';
import 'package:frontend/models/doctor.dart';

class DoctorListWidget extends StatelessWidget {
  final List<Doctor> doctors;
  final Function(Doctor) onShowAvailability;

  const DoctorListWidget({
    super.key,
    required this.doctors,
    required this.onShowAvailability,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const Center(child: Text('No hay doctores disponibles.'));
    }

    return ListView.builder(
      itemCount: doctors.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        final name = doctor.user?.name ?? 'Sin nombre';
        final specialties =
            doctor.specialties?.map((s) => s.name).join(', ') ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 40,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialties,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => onShowAvailability(doctor),
                  child: const Text('Ver disponibilidad'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
