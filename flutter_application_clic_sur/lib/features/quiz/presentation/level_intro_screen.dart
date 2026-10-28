import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/quiz_data.dart';
import '../data/quiz_repository.dart';
import 'quiz_async_views.dart';

/// Écran affiché après avoir tapé un niveau, avant de commencer les
/// questions : titre, seuils d'étoiles, bouton Jouer.
class LevelIntroScreen extends ConsumerWidget {
  final String levelId;

  const LevelIntroScreen({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(quizLevelsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: levelsAsync.when(
          loading: () => const QuizLoadingView(),
          error: (_, __) => QuizMessageView(
            icon: Icons.cloud_off_outlined,
            message: loadErrorMessage,
            onRetry: () => ref.invalidate(quizLevelsProvider),
          ),
          data: (levels) {
            final matches = levels.where((l) => l.id == levelId);
            if (matches.isEmpty) {
              return QuizMessageView(
                icon: Icons.search_off_outlined,
                message: "Ce niveau n'existe pas ou n'est plus disponible.",
                onRetry: () => context.pop(),
              );
            }
            return _IntroContent(level: matches.first);
          },
        ),
      ),
    );
  }
}

class _IntroContent extends StatelessWidget {
  final QuizLevelData level;

  const _IntroContent({required this.level});

  @override
  Widget build(BuildContext context) {
    final total = level.questions.length;
    // Seuils d'étoiles proportionnels au nombre de questions du niveau.
    final thresholds = [(total * 0.6).ceil(), (total * 0.8).ceil(), total];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.pop(),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 110,
            height: 110,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: level.bg, borderRadius: BorderRadius.circular(28)),
            child: Text('${level.number}', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: level.color)),
          ),
          const SizedBox(height: 24),
          Text('Niveau ${level.number}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(level.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: level.color)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(16)),
            child: Text(
              'Répondez Vrai ou Faux aux $total questions. Chaque bonne réponse vous rapproche du sommet.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.accentText, height: 1.4),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final t in thresholds)
                Column(
                  children: [
                    const Icon(Icons.star_rounded, size: 28, color: Color(0xFFF5B400)),
                    const SizedBox(height: 4),
                    Text('$t/$total', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/quiz/${level.id}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.accentFill,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Jouer !', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
