import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo con filtro para hacerlo blanco
        Container(
          width: AppDimensions.logoSize,
          height: AppDimensions.logoSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadius,
                      ),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      size: 50,
                      color: AppColors.uadyBlue,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.logoBottomMargin),
        // Título principal
        Text(
          'Servicio Médico UADY',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            shadows: [
              Shadow(
                color: AppColors.black.withOpacity(0.4),
                offset: const Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
