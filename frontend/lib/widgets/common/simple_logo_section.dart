import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SimpleLogoSection extends StatelessWidget {
  const SimpleLogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logoSize = constraints.maxWidth > 600 ? 70.0 : 50.0;
        final iconSize = constraints.maxWidth > 600 ? 35.0 : 25.0;
        final titleSize = constraints.maxWidth > 600 ? 18.0 : 14.0;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.medical_services,
                        size: iconSize,
                        color: AppColors.uadyBlue,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Servicio Médico UADY',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
