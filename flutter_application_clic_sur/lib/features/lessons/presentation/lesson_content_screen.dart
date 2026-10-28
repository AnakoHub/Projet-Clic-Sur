import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_top_bar.dart';

class _LessonResource {
  final String label;
  final String url;
  const _LessonResource(this.label, this.url);
}

class _LessonData {
  final String title;
  final String intro;
  final List<String> tips;
  final List<_LessonResource> resources;
  const _LessonData({required this.title, required this.intro, required this.tips, required this.resources});
}

const Map<String, _LessonData> _lessonBank = {
  'mdp': _LessonData(
    title: 'Hygiène des mots de passe',
    intro: "Un mot de passe est souvent la seule chose qui protège vos comptes en ligne.",
    tips: [
      'Utilisez un mot de passe différent pour chaque compte important.',
      "Préférez une phrase longue plutôt qu'un mot complexe court.",
      'Utilisez un gestionnaire de mots de passe.',
      "Activez la double authentification (2FA) dès que possible.",
    ],
    resources: [
      _LessonResource('Cybermalveillance.gouv.fr — Bonnes pratiques mots de passe', 'https://www.cybermalveillance.gouv.fr/tous-nos-contenus/bonnes-pratiques/mots-de-passe'),
    ],
  ),
  'phishing': _LessonData(
    title: 'Sensibilisation au Phishing',
    intro: "Le phishing imite une source de confiance pour voler vos informations.",
    tips: [
      "Vérifiez toujours l'adresse réelle de l'expéditeur.",
      'Méfiez-vous des messages urgents.',
      "Ne cliquez jamais directement sur un lien suspect.",
      "Signalez le message en cas de doute.",
    ],
    resources: [
      _LessonResource('Cybermalveillance.gouv.fr — Fiche réflexe hameçonnage', 'https://www.cybermalveillance.gouv.fr/tous-nos-contenus/fiches-reflexes/hameconnage-phishing'),
    ],
  ),
  'reseau': _LessonData(
    title: 'Fondamentaux de la Sécurité',
    intro: "Quelques règles de base réduisent fortement les risques, surtout sur Wifi public.",
    tips: [
      'Évitez les opérations sensibles sur Wifi public.',
      'Privilégiez données mobiles ou VPN.',
      'Vérifiez le cadenas et "https".',
      'Maintenez vos appareils à jour.',
    ],
    resources: [
      _LessonResource('Cybermalveillance.gouv.fr — 10 mesures essentielles', 'https://www.cybermalveillance.gouv.fr/tous-nos-contenus/bonnes-pratiques/10-mesures-essentielles-assurer-securite-numerique'),
    ],
  ),
  'vie_privee': _LessonData(
    title: 'Confidentialité des Données',
    intro: "Ce que vous partagez en dit souvent plus que vous ne le pensez.",
    tips: [
      'Réglez vos paramètres de confidentialité.',
      'Réfléchissez avant de publier.',
      'Vérifiez les applications tierces connectées.',
      'Sécurisez le compte avec un mot de passe fort et la 2FA.',
    ],
    resources: [
      _LessonResource('CNIL — 5 conseils vie privée sur les réseaux sociaux', 'https://www.cnil.fr/fr/5-conseils-pour-proteger-ma-vie-privee-sur-les-reseaux-sociaux'),
    ],
  ),
};

class LessonContentScreen extends StatelessWidget {
  final String lessonId;
  const LessonContentScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    final lesson = _lessonBank[lessonId];
    if (lesson == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppTopBar(title: 'Leçon', xpPercent: 0, onBack: () => context.pop()),
        body: const Center(child: Text('Contenu à venir.')),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: lesson.title, xpPercent: 0, onBack: () => context.pop()),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(lesson.intro, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 20),
            const Text('À retenir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            for (final tip in lesson.tips) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.check_circle, size: 16, color: AppColors.successText)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.45))),
                ],
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
            const Text('Pour aller plus loin', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            for (final r in lesson.resources)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => launchUrl(Uri.parse(r.url), mode: LaunchMode.externalApplication),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      const Icon(Icons.open_in_new, size: 18, color: AppColors.accentText),
                      const SizedBox(width: 10),
                      Expanded(child: Text(r.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accentText))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
