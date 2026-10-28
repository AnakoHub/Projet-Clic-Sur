import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// En-tête de section réutilisé sur plusieurs écrans (Accueil, Modules...).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentText),
          ),
      ],
    );
  }
}
