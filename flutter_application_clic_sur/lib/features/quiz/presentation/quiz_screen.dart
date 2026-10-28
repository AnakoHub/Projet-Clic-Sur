import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/quiz_data.dart';
import '../data/quiz_repository.dart';
import 'quiz_async_views.dart';

/// Écran de jeu : charge le niveau depuis Supabase, puis déroule les
/// questions Vrai/Faux avec un écran de transition entre chaque question.
class QuizScreen extends ConsumerWidget {
  final String levelId;

  const QuizScreen({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(quizLevelsProvider);

    return levelsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: QuizLoadingView()),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: QuizMessageView(
            icon: Icons.cloud_off_outlined,
            message: loadErrorMessage,
            onRetry: () => ref.invalidate(quizLevelsProvider),
          ),
        ),
      ),
      data: (levels) {
        final matches = levels.where((l) => l.id == levelId);
        if (matches.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: QuizMessageView(
                icon: Icons.search_off_outlined,
                message: "Ce niveau n'existe pas ou n'est plus disponible.",
                onRetry: () => context.pop(),
              ),
            ),
          );
        }
        return _QuizPlayer(level: matches.first);
      },
    );
  }
}

class _QuizPlayer extends StatefulWidget {
  final QuizLevelData level;

  const _QuizPlayer({required this.level});

  @override
  State<_QuizPlayer> createState() => _QuizPlayerState();
}

class _QuizPlayerState extends State<_QuizPlayer> {
  QuizLevelData get _level => widget.level;
  int _index = 0;
  bool? _selected;
  bool _locked = false;
  int _score = 0;
  bool _finished = false;

  void _answer(bool value) {
    if (_locked) return;
    final correct = value == _level.questions[_index].answer;
    setState(() {
      _selected = value;
      _locked = true;
      if (correct) _score++;
    });
  }

  void _next() {
    if (_index == _level.questions.length - 1) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _locked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _CompletionView(level: _level, score: _score);

    final question = _level.questions[_index];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Niveau ${_level.number}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, size: 14, color: AppColors.accentText),
                        const SizedBox(width: 4),
                        Text('${_score * 10}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentText)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 0; i < _level.questions.length; i++) ...[
                    Expanded(
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: i < _index || (i == _index && _locked) ? AppColors.accentFill : AppColors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    if (i < _level.questions.length - 1) const SizedBox(width: 4),
                  ],
                ],
              ),
              Expanded(
                child: _locked
                    ? _AnswerTransition(
                        question: question,
                        selected: _selected!,
                        onContinue: _next,
                      )
                    : _QuestionView(level: _level, question: question, onAnswer: _answer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final QuizLevelData level;
  final QuizQuestionData question;
  final ValueChanged<bool> onAnswer;

  const _QuestionView({required this.level, required this.question, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: level.bg, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(level.icon, size: 14, color: level.color),
              const SizedBox(width: 6),
              Text(level.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: level.color)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          question.text,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.35),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: _ChoiceButton(
                label: 'Faux',
                icon: Icons.close,
                onTap: () => onAnswer(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceButton(
                label: 'Vrai',
                icon: Icons.check,
                onTap: () => onAnswer(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ChoiceButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: AppColors.elevatedChip, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _AnswerTransition extends StatelessWidget {
  final QuizQuestionData question;
  final bool selected;
  final VoidCallback onContinue;

  const _AnswerTransition({required this.question, required this.selected, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final correct = selected == question.answer;
    final verdict = question.answer ? 'Vrai' : 'Faux';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onContinue,
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < -100) onContinue();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            question.text,
            style: const TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          const _DashedDivider(),
          const SizedBox(height: 16),
          Text(
            verdict,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Text(
            question.explanation,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: correct ? AppColors.successBg : AppColors.dangerBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  correct ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                  color: correct ? AppColors.successText : AppColors.dangerText,
                ),
              ),
              const Spacer(),
              Text(
                'swipez pour passer à la suivante !',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(24, (i) {
        return Expanded(
          child: Container(
            height: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: i.isEven ? AppColors.border : Colors.transparent,
          ),
        );
      }),
    );
  }
}

class _CompletionView extends StatelessWidget {
  final QuizLevelData level;
  final int score;

  const _CompletionView({required this.level, required this.score});

  @override
  Widget build(BuildContext context) {
    final total = level.questions.length;
    final ratio = score / total;
    final stars = ratio >= 1.0 ? 3 : (ratio >= 0.8 ? 2 : (ratio >= 0.6 ? 1 : 0));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 44,
                    color: i < stars ? const Color(0xFFF5B400) : AppColors.border,
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                'Niveau ${level.number} terminé !',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                '$score / $total bonnes réponses',
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/quiz-map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentFill,
                    foregroundColor: AppColors.textOnAccentFill,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Retour à la carte', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
