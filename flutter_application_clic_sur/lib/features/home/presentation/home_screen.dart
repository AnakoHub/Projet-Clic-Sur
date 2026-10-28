import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNav(current: AppTab.home),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(title: 'Salut, Alex', streakDays: 12),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield_outlined, size: 20, color: AppColors.accentText),
                        SizedBox(width: 8),
                        Text('Mission du jour', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentText)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Fondamentaux de la sécurité', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.accentText)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 0.45),
                        duration: const Duration(milliseconds: 700),
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: AppColors.surface,
                          valueColor: const AlwaysStoppedAnimation(AppColors.accentFill),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/lessons/reseau'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentFill,
                          foregroundColor: AppColors.textOnAccentFill,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Continuer', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Autres thèmes', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ThemeCircle(icon: Icons.mail_outline, bg: AppColors.catPurpleBg, color: AppColors.catPurpleText, onTap: () => context.push('/lessons/phishing')),
                  const SizedBox(width: 12),
                  _ThemeCircle(icon: Icons.lock_outline, bg: AppColors.catBlueBg, color: AppColors.catBlueText, onTap: () => context.push('/lessons/vie_privee')),
                  const SizedBox(width: 12),
                  // Quiz éclair : passe par l'écran d'intro de niveau.
                  _ThemeCircle(icon: Icons.bolt, bg: AppColors.catRedBg, color: AppColors.catRedText, onTap: () => context.push('/quiz/phishing/intro')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeCircle extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;
  final VoidCallback onTap;

  const _ThemeCircle({required this.icon, required this.bg, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
