import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class UserInfoCard extends StatelessWidget {
  final String userName;
  final String userRole;

  const UserInfoCard({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, $userName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.uadyBlue,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: 'Rol: ',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF555555),
                  fontFamily: 'Poppins',
                ),
                children: [
                  TextSpan(
                    text: _formatRole(userRole),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
      case 'paciente':
        return 'Paciente';
      case 'doctor':
        return 'Doctor';
      default:
        return role;
    }
  }
}
