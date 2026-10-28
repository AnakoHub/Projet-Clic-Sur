import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final int streakDays;

  const AppHeader({super.key, required this.title, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.streakBg, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, size: 14, color: AppColors.streakText),
                  const SizedBox(width: 4),
                  Text('$streakDays', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.streakText)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/profile'),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.elevatedChip,
                child: Icon(Icons.person, size: 16, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
