import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

enum AppTab { home, lessons, quiz }

/// Barre de navigation basse — forme reprise des maquettes de référence :
/// carte blanche flottante, icône + libellé par onglet, pastille colorée
/// derrière l'icône de l'onglet actif. Couleurs et onglets restent les nôtres.
class AppBottomNav extends StatelessWidget {
  final AppTab current;

  const AppBottomNav({super.key, required this.current});

  static const _tabs = [
    (AppTab.home, Icons.home_rounded, 'Accueil', '/home'),
    (AppTab.lessons, Icons.menu_book_rounded, 'Leçons', '/lessons'),
    (AppTab.quiz, Icons.emoji_events_rounded, 'Quiz', '/quiz-map'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _tabs.map((tab) {
            final (id, icon, label, route) = tab;
            final active = id == current;
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.go(route),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? AppColors.textPrimary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 20, color: active ? AppColors.accentFill : AppColors.navInactive),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? AppColors.textPrimary : AppColors.navInactive,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
