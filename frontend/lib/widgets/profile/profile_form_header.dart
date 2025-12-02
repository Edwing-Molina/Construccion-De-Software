import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProfileFormHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const ProfileFormHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleSize = constraints.maxWidth > 600 ? 24.0 : 18.0;
        final subtitleSize = constraints.maxWidth > 600 ? 14.0 : 12.0;

        return Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: AppColors.uadyBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: subtitleSize,
                color: AppColors.darkGray.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
