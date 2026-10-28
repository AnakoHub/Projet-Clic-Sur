# PareClic
Application mobile de sensibilisation à la cybersécurité
construite sur le même principe pédagogique que Flouze :

- Progression en niveaux déverrouillés les uns après les autres
- Cartes de contenu courtes (texte + visuel), sans jargon technique
- Quiz et mini-défis interactifs à la fin de chaque niveau
- Classement entre utilisateurs (optionnel, motivant sans être stressant)
- Récompense finale pour les utilisateurs qui terminent le parcours

## Stack technique

| Brique | Techno | Pourquoi |
|---|---|---|
| Frontend mobile | Flutter (Dart) | Un seul code pour iOS/Android, très bonnes performances (compilé nativement), hot reload rapide pour itérer sur les niveaux/cartes |
| Gestion d'état | Riverpod | Simple à apprendre, bien adapté à un flux progression/niveaux, bonne intégration avec Supabase |
| Backend + DB | Supabase (PostgreSQL managé + API auto-générée + Auth) | Évite d'écrire un backend from scratch, gain de temps énorme pour un MVP, package officiel `supabase_flutter` |
| Authentification | Supabase Auth (ou Firebase Auth) | Gestion des comptes, mots de passe, réinitialisation, tout géré |
| Contenu pédagogique | Table dédiée dans Supabase + interface admin simple | Pas besoin d'un CMS complet au démarrage |
| Hébergement mobile | Flutter build + Codemagic (CI/CD) → App Store / Play Store | Codemagic est pensé spécifiquement pour Flutter, simplifie les builds iOS/Android |