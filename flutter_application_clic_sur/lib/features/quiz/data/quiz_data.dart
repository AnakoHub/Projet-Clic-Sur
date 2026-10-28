import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Une question Vrai/Faux. Le contenu vient de la table `questions` de Supabase.
class QuizQuestionData {
  final String text;
  final bool answer; // true = "Vrai" est la bonne réponse
  final String explanation;

  const QuizQuestionData({
    required this.text,
    required this.answer,
    required this.explanation,
  });
}

/// Un niveau de quiz. Le contenu (titre, description, questions) vient de
/// Supabase ; seule la présentation (icône, couleurs) est définie ici.
class QuizLevelData {
  final String id; // = levels.slug, utilisé dans les routes (/quiz/mdp)
  final int number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bg;
  final Color color;
  final List<QuizQuestionData> questions;

  const QuizLevelData({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bg,
    required this.color,
    required this.questions,
  });
}

/// Présentation d'un niveau : non stockée en base, donc associée au slug.
class LevelStyle {
  final IconData icon;
  final Color bg;
  final Color color;

  const LevelStyle(this.icon, this.bg, this.color);
}

const Map<String, LevelStyle> _stylesBySlug = {
  'mdp': LevelStyle(Icons.key_outlined, AppColors.catBlueBg, AppColors.catBlueText),
  'phishing': LevelStyle(Icons.mail_outline, AppColors.catPurpleBg, AppColors.catPurpleText),
  'reseau': LevelStyle(Icons.wifi, AppColors.catGreenBg, AppColors.catGreenText),
  'auth': LevelStyle(Icons.verified_user_outlined, AppColors.catRedBg, AppColors.catRedText),
};

/// Styles utilisés pour un niveau ajouté en base dont le slug n'est pas
/// connu ci-dessus : il reçoit automatiquement une présentation.
const List<LevelStyle> _fallbackStyles = [
  LevelStyle(Icons.shield_outlined, AppColors.catAmberBg, AppColors.catAmberText),
  LevelStyle(Icons.lock_outline, AppColors.catBlueBg, AppColors.catBlueText),
  LevelStyle(Icons.quiz_outlined, AppColors.catPurpleBg, AppColors.catPurpleText),
];

LevelStyle styleFor(String slug, int index) =>
    _stylesBySlug[slug] ?? _fallbackStyles[index % _fallbackStyles.length];
