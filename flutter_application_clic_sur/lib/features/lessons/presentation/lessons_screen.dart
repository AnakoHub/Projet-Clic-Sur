import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_header.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNav(current: AppTab.lessons),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(title: 'Leçons', streakDays: 12),
              const SizedBox(height: 24),
              _ModuleRow(
                icon: Icons.key_outlined,
                bg: AppColors.catBlueBg,
                color: AppColors.catBlueText,
                title: 'Hygiène des mots de passe',
                trailing: '75%',
                onTap: () => context.push('/lessons/mdp'),
              ),
              const SizedBox(height: 10),
              _ModuleRow(
                icon: Icons.mail_outline,
                bg: AppColors.catPurpleBg,
                color: AppColors.catPurpleText,
                title: 'Sensibilisation au phishing',
                trailing: '20%',
                onTap: () => context.push('/lessons/phishing'),
              ),
              const SizedBox(height: 10),
              const _ModuleRow(
                icon: Icons.wifi,
                bg: AppColors.surface,
                color: AppColors.textMuted,
                title: 'Sécurité réseau',
                trailingIcon: Icons.lock_outline,
                muted: true,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Quiz éclair : passe par l'écran d'intro de niveau.
                  onPressed: () => context.push('/quiz/mdp/intro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentFill,
                    foregroundColor: AppColors.textOnAccentFill,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.bolt, size: 16),
                      SizedBox(width: 6),
                      Text('Quiz éclair, +100 XP', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;
  final String title;
  final String? trailing;
  final IconData? trailingIcon;
  final bool muted;
  final VoidCallback? onTap;

  const _ModuleRow({
    required this.icon,
    required this.bg,
    required this.color,
    required this.title,
    this.trailing,
    this.trailingIcon,
    this.muted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: muted ? Border.all(color: AppColors.border) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted ? AppColors.textMuted : AppColors.textPrimary)),
            ),
            if (trailing != null) Text(trailing!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            if (trailingIcon != null) Icon(trailingIcon, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
