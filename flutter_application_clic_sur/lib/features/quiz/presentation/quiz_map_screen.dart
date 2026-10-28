import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_header.dart';
import '../data/quiz_data.dart';
import '../data/quiz_repository.dart';
import 'quiz_async_views.dart';

/// Premier écran de la section Quiz : chemin sinueux de niveaux chargés
/// depuis Supabase, avec étoiles de progression.
class QuizMapScreen extends ConsumerWidget {
  const QuizMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(quizLevelsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNav(current: AppTab.quiz),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: AppHeader(title: 'Quiz', streakDays: 12),
            ),
            Expanded(
              child: levelsAsync.when(
                loading: () => const QuizLoadingView(),
                error: (_, __) => QuizMessageView(
                  icon: Icons.cloud_off_outlined,
                  message: loadErrorMessage,
                  onRetry: () => ref.invalidate(quizLevelsProvider),
                ),
                data: (levels) {
                  if (levels.isEmpty) {
                    return QuizMessageView(
                      icon: Icons.quiz_outlined,
                      message: emptyQuizMessage,
                      onRetry: () => ref.invalidate(quizLevelsProvider),
                    );
                  }
                  final ordered = levels.reversed.toList(); // niveau le plus avancé en haut
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(quizLevelsProvider.future),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      itemCount: ordered.length,
                      itemBuilder: (context, i) {
                        final align = switch (i % 3) {
                          0 => Alignment.center,
                          1 => Alignment.centerLeft,
                          _ => Alignment.centerRight,
                        };
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Align(
                            alignment: align,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: _LevelNode(level: ordered[i]),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final QuizLevelData level;

  const _LevelNode({required this.level});

  @override
  Widget build(BuildContext context) {
    // Démo : niveau 1 complété à 3 étoiles, le reste pas encore joué.
    // À remplacer par la table user_progress.
    final stars = level.number == 1 ? 3 : 0;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/quiz/${level.id}/intro'),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 18,
                color: i < stars ? const Color(0xFFF5B400) : AppColors.border,
              );
            }),
          ),
          const SizedBox(height: 6),
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: level.bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surface, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(level.icon, size: 22, color: level.color),
                const SizedBox(height: 4),
                Text('${level.number}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: level.color)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(level.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
