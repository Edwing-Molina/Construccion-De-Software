import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class CitasAppBarWidget extends StatelessWidget {
  const CitasAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      color: AppColors.uadyBlue,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => context.go('/home'),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Mis Citas',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
