import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_top_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: 'Profil', xpPercent: 68, onBack: () => context.pop()),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.elevatedChip,
                    child: Icon(Icons.person, size: 48, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const Text('Miryame', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: const [
                Expanded(child: _StatCard(label: 'LEÇONS TERMINÉES', value: '24', badge: '+4 cette semaine')),
                SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'TOTAL XP GAGNÉS', value: '12 450', badge: 'Niveau 14', badgeColor: AppColors.accentText)),
              ],
            ),
            const SizedBox(height: 12),
            const _StatCard(label: 'CERTIFICATS', value: '3', badge: 'Statut Élite', badgeColor: Color(0xFFB45309)),
            const SizedBox(height: 28),
            // Le router renvoie automatiquement vers /login une fois la session fermée.
            OutlinedButton.icon(
              onPressed: () => Supabase.instance.client.auth.signOut(),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Se déconnecter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String badge;
  final Color? badgeColor;

  const _StatCard({required this.label, required this.value, required this.badge, this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.3)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor ?? AppColors.successText)),
        ],
      ),
    );
  }
}
