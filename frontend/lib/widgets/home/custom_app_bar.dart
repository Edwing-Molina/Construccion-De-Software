import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout;

  const CustomAppBar({super.key, required this.title, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.uadyBlue,
      foregroundColor: AppColors.white,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Row(
        children: [
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            child: Image.asset(
              'assets/images/logo.png',
              height: 35,
              width: 35,
              fit: BoxFit.contain,
              color: AppColors.white,
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: AppColors.uadyBlue,
                    size: 24,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          iconSize: 28.8,
          tooltip: 'Cerrar Sesión',
          color: AppColors.white,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
