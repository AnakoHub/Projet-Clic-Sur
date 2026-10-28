import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_provider.dart';
import 'quiz_data.dart';

/// Lit les niveaux et leurs questions depuis Supabase.
class QuizRepository {
  final SupabaseClient _client;

  QuizRepository(this._client);

  Future<List<QuizLevelData>> fetchLevels() async {
    // Jointure automatique levels -> cards -> questions via les clés étrangères.
    final rows = await _client
        .from('levels')
        .select(
          'slug, title, description, sort_order, '
          'cards(type, sort_order, questions(question_text, correct_answer, explanation))',
        )
        .order('sort_order');

    final levels = <QuizLevelData>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final slug = row['slug'] as String;
      final style = styleFor(slug, i);

      final questions = <QuizQuestionData>[];
      final cards = (row['cards'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .where((c) => c['type'] == 'quiz')
          .toList()
        ..sort((a, b) => ((a['sort_order'] as int?) ?? 0).compareTo((b['sort_order'] as int?) ?? 0));

      for (final card in cards) {
        for (final q in (card['questions'] as List? ?? const []).cast<Map<String, dynamic>>()) {
          questions.add(
            QuizQuestionData(
              text: q['question_text'] as String,
              answer: q['correct_answer'] == true,
              explanation: (q['explanation'] as String?) ?? '',
            ),
          );
        }
      }

      // Un niveau sans question n'est pas jouable : on ne l'affiche pas.
      if (questions.isEmpty) continue;

      levels.add(
        QuizLevelData(
          id: slug,
          number: (row['sort_order'] as int?) ?? (i + 1),
          title: row['title'] as String,
          subtitle: (row['description'] as String?) ?? '',
          icon: style.icon,
          bg: style.bg,
          color: style.color,
          questions: questions,
        ),
      );
    }
    return levels;
  }
}

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ref.watch(supabaseClientProvider));
});

/// Liste des niveaux, chargée une fois puis mise en cache.
/// `ref.invalidate(quizLevelsProvider)` force un rechargement.
final quizLevelsProvider = FutureProvider<List<QuizLevelData>>((ref) {
  return ref.watch(quizRepositoryProvider).fetchLevels();
});
