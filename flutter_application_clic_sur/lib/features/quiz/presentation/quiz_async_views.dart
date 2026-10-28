import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// États de chargement / erreur communs aux écrans alimentés par Supabase.
class QuizLoadingView extends StatelessWidget {
  const QuizLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.accentText));
  }
}

class QuizMessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  const QuizMessageView({super.key, required this.icon, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentFill,
                  foregroundColor: AppColors.textOnAccentFill,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

const emptyQuizMessage =
    "Aucun quiz disponible. Vérifie que le contenu a bien été ajouté dans Supabase et que tu es connecté.";
const loadErrorMessage = "Impossible de charger les quiz. Vérifie ta connexion et la configuration Supabase.";
