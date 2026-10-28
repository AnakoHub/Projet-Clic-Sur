# Spécifications techniques — App éducative Cybersécurité
### (inspirée du format Flouze, adaptée à un public grand public non-technique)

---

## 1. Résumé fonctionnel

Application mobile de sensibilisation à la cybersécurité, construite sur le même principe pédagogique que Flouze :

- **Progression en niveaux** déverrouillés les uns après les autres
- **Cartes de contenu** courtes (texte + visuel), sans jargon technique
- **Quiz et mini-défis interactifs** à la fin de chaque niveau
- **Classement** entre utilisateurs (optionnel, motivant sans être stressant)
- **Récompense finale** pour les utilisateurs qui terminent le parcours

Contrainte principale du public visé (grand public non-technique) : **vocabulaire simple, exemples concrets de la vie quotidienne, sessions courtes (2-5 min), aucun prérequis technique**.

---

## 2. Stack technique recommandée

### Option A — MVP rapide (recommandée pour démarrer)

| Brique | Techno | Pourquoi |
|---|---|---|
| Frontend mobile | Flutter (Dart) | Un seul code pour iOS/Android, très bonnes performances (compilé nativement), hot reload rapide pour itérer sur les niveaux/cartes |
| Gestion d'état | Riverpod | Simple à apprendre, bien adapté à un flux progression/niveaux, bonne intégration avec Supabase |
| Backend + DB | Supabase (PostgreSQL managé + API auto-générée + Auth) | Évite d'écrire un backend from scratch, gain de temps énorme pour un MVP, package officiel `supabase_flutter` |
| Authentification | Supabase Auth (ou Firebase Auth) | Gestion des comptes, mots de passe, réinitialisation, tout géré |
| Contenu pédagogique | Table dédiée dans Supabase + interface admin simple | Pas besoin d'un CMS complet au démarrage |
| Hébergement mobile | Flutter build + Codemagic (CI/CD) → App Store / Play Store | Codemagic est pensé spécifiquement pour Flutter, simplifie les builds iOS/Android |

### Option B — Stack scalable (si le projet grandit)

| Brique | Techno | Pourquoi |
|---|---|---|
| Frontend mobile | Flutter (Dart) | Cohérent avec l'option A, pas de réécriture du frontend en cas de montée en charge |
| Gestion d'état | Riverpod ou Bloc | Bloc devient intéressant si l'équipe s'agrandit (séparation stricte logique/UI) |
| Backend API | Node.js + NestJS (REST) | Structure claire, TypeScript, bonne base pour une équipe |
| Base de données | PostgreSQL (hébergé sur Neon, Railway ou AWS RDS) | Relationnel, adapté à la progression/scores |
| Cache classement | Redis | Calcul rapide du leaderboard sans surcharger PostgreSQL |
| Authentification | Auth0 ou Firebase Auth | Délégué à un service géré, plus sûr que du "fait maison" |
| CMS contenu | Strapi (headless) | Permet de mettre à jour le contenu (nouvelles menaces, nouveaux niveaux) sans redéployer l'app |
| Hébergement backend | Render / Railway | Simple à mettre en place, scalable ensuite |
| Analytics | Amplitude ou Mixpanel | Suivre où les utilisateurs décrochent, quels niveaux posent problème |

**Recommandation** : démarrer avec l'option A pour valider le concept, migrer vers l'option B si l'app prend de l'ampleur (plus de contenu, plus d'utilisateurs, besoin d'un CMS pour une équipe éditoriale).

---

## 3. Modèle de données

### Tables principales

**users**
| Champ | Type | Description |
|---|---|---|
| id | uuid (PK) | |
| pseudo | text | |
| email | text (unique) | |
| password_hash | text | (géré par le service d'auth si Option A/B managée) |
| avatar_url | text | |
| xp_total | integer | |
| streak_days | integer | Jours consécutifs d'activité (motivation) |
| created_at | timestamp | |

**themes**
| Champ | Type | Description |
|---|---|---|
| id | uuid (PK) | |
| name | text | Ex : "Le phishing", "Mots de passe" |
| description | text | |
| icon | text | |
| order | integer | Ordre d'affichage |

**levels**
| Champ | Type | Description |
|---|---|---|
| id | uuid (PK) | |
| theme_id | uuid (FK → themes) | |
| order | integer | |
| title | text | |
| description | text | |
| xp_reward | integer | |
| unlock_condition | jsonb | Ex : `{"requires_level": "uuid-du-niveau-precedent"}` |

**cards**
| Champ | Type | Description |
|---|---|---|
| id | uuid (PK) | |
| level_id | uuid (FK → levels) | |
| order | integer | |
| type | enum | `lesson`, `quiz`, `challenge` |
| content | jsonb | Texte, image, structure flexible selon le type |

**questions**
| Champ | Type | Description |
|---|---|---|
| id | uuid (PK) | |
| card_id | uuid (FK → cards) | |
| question_text | text | |
| type | enum | `qcm`, `vrai_faux`, `glisser_deposer` |
| options | jsonb | |
| correct_answer | jsonb | |
| explanation | text | Affichée après la réponse, pédagogique |

**user_progress**
| Champ | Type | Description |
|---|---|---|
| id | uuid (PK) | |
| user_id | uuid (FK → users) | |
| level_id | uuid (FK → levels) | |
| status | enum | `locked`, `in_progress`, `completed` |
| score | integer | |
| completed_at | timestamp | |

**user_answers**
| Champ | Type | Description |
|---|---|---|
| id | uuid (PK) | |
| user_id | uuid (FK → users) | |
| question_id | uuid (FK → questions) | |
| answer_given | jsonb | |
| is_correct | boolean | |
| answered_at | timestamp | |

**badges**
| Champ | Type | Description |
|---|---|---|
| id | uuid (PK) | |
| name | text | |
| description | text | |
| icon | text | |
| condition | jsonb | Ex : "terminer le thème Phishing" |

**user_badges**
| Champ | Type | Description |
|---|---|---|
| user_id | uuid (FK → users) | |
| badge_id | uuid (FK → badges) | |
| earned_at | timestamp | |

### Relations clés
- `themes 1—N levels`
- `levels 1—N cards`
- `cards 1—N questions`
- `users 1—N user_progress` (une ligne par niveau tenté)
- `users 1—N user_answers` (historique détaillé, utile pour analytics pédagogique)

Le classement (leaderboard) n'a pas besoin de table dédiée au départ : `SELECT pseudo, xp_total FROM users ORDER BY xp_total DESC` suffit pour un MVP. Une table `leaderboard_snapshot` (avec période weekly/global) devient utile seulement si le volume d'utilisateurs grandit et que le calcul en temps réel devient coûteux.

---

## 4. Endpoints API principaux (REST)

```
POST   /auth/register
POST   /auth/login
POST   /auth/refresh

GET    /themes
GET    /themes/:id/levels
GET    /levels/:id/cards
GET    /levels/:id/cards/:cardId/questions

POST   /levels/:id/start
POST   /questions/:id/answer
POST   /levels/:id/complete

GET    /users/me
GET    /users/me/progress
GET    /users/me/badges

GET    /leaderboard?period=weekly
```

---

## 5. Proposition de structure pédagogique (thèmes / niveaux)

Adaptée à un public non-technique, chaque thème progresse du plus concret au plus subtil :

1. **Mots de passe** — reconnaître un mot de passe faible, utiliser un gestionnaire de mots de passe
2. **Le phishing** — repérer un email ou SMS frauduleux (faux indices visuels, urgence artificielle, lien suspect)
3. **Réseaux sociaux** — paramètres de confidentialité, ce qu'il ne faut pas partager publiquement
4. **Wifi public et connexions** — risques d'un wifi ouvert, reconnaître une connexion sécurisée (HTTPS)
5. **Arnaques en ligne** — fausses annonces, faux sites de vente, arnaques aux colis
6. **Authentification à deux facteurs** — pourquoi et comment l'activer
7. **Ingénierie sociale** — faux support technique, appels frauduleux, manipulation psychologique
8. **Mises à jour et sauvegardes** — pourquoi mettre à jour ses appareils, sauvegarder ses données

Chaque thème : 3 à 5 niveaux, chaque niveau mélange 1-2 cartes de leçon courte + 1 quiz + 1 mini-défi pratique (ex : "identifie les 3 indices de phishing dans ce faux email").

---

## 6. Sécurité de l'application elle-même

Un point important vu la thématique : l'app doit être exemplaire sur ses propres pratiques de sécurité.

- HTTPS/TLS obligatoire sur tous les échanges
- Hashing des mots de passe avec bcrypt ou argon2 (ou délégué à Supabase/Firebase/Auth0)
- Rate limiting sur les endpoints d'authentification
- Utilisation d'un ORM (Prisma, TypeORM) pour éviter les injections SQL
- Minimisation des données personnelles collectées (RGPD)
- Si le public inclut des mineurs : vérifier les règles de consentement parental applicables

---

## 7. Étapes de développement

**Phase 1 — Cadrage & conception**
- Parcours utilisateur (user flow) : onboarding → accueil → sélection thème → niveau → carte de leçon → quiz → résultat/récompense → profil/classement
- Maquettes Figma : wireframes basse fidélité, puis haute fidélité avec charte graphique (couleurs, typographie) et design system de base (bouton, carte de niveau, barre de progression, badge)
- Rédaction du contenu pédagogique du premier thème : découpage en 3-5 niveaux, textes de leçon courts, questions de quiz avec explications pédagogiques, choix des illustrations
- Guide de style éditorial : niveau de langue, tutoiement/vouvoiement, glossaire des mots autorisés/à éviter (pas de jargon non expliqué)
- Test de concept auprès de 3-5 personnes du public cible (maquettes ou prototype papier) avant de coder

**Phase 2 — Setup technique**
- Initialisation du projet Flutter : architecture feature-first (`/features/auth`, `/features/levels`, `/features/quiz`), dépendances clés (`riverpod`, `supabase_flutter`, `go_router`), configuration du thème à partir de la charte graphique
- Création des tables Supabase selon le modèle de données, avec leurs clés étrangères
- Règles Row Level Security (RLS) : progression lisible/modifiable uniquement par son propriétaire, contenu pédagogique lisible par tous les utilisateurs authentifiés mais non modifiable côté client — à tester dans l'éditeur SQL avant de brancher le frontend
- Configuration de Supabase Auth (email/mot de passe, éventuellement Google/Apple)
- Repo Git (branches main/develop/feature) + CI/CD Codemagic (builds iOS/Android)
- Gestion des secrets via variables d'environnement (`--dart-define` ou `flutter_dotenv`), jamais commitées
- Vérifications automatiques dans le pipeline (`flutter analyze`, `dart format`)

**Phase 3 — Cœur fonctionnel (MVP)**
- Inscription / connexion
- Navigation thèmes → niveaux → cartes
- Moteur de quiz interactif
- Sauvegarde de la progression

**Phase 4 — Contenu & tests utilisateurs**
- Intégration du premier thème complet dans Supabase
- Tests utilisateurs auprès du public cible (vocabulaire, clarté des exemples)
- Ajustements basés sur les retours

**Phase 5 — Fonctionnalités de motivation**
- Classement (leaderboard)
- Badges
- Streaks

**Phase 6 — Beta & lancement**
- Tests beta (TestFlight / Play Console)
- Corrections de bugs et de performance
- Publication sur les stores
- Itération post-lancement : nouveaux thèmes, ajustements analytics

---

## Annexe — Initialisation pratique du projet Flutter

**1. Vérifier les prérequis**
```
flutter doctor
```

**2. Créer le projet**
```
flutter create --org com.tonentreprise cyberapp
```

**3. Architecture feature-first**
```
lib/
  core/        → thème, widgets partagés, constantes
  features/
    auth/
    levels/
    quiz/
    profile/
```

**4. Dépendances clés**
```
flutter pub add flutter_riverpod
flutter pub add supabase_flutter
flutter pub add go_router
```

**5. Thème**
Créer `lib/core/theme/app_theme.dart` avec un `ThemeData` reprenant les couleurs et typographies de la phase 1.

**6. Initialisation de Supabase** (dans `main.dart`)
```dart
await Supabase.initialize(
  url: String.fromEnvironment('SUPABASE_URL'),
  anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```
Lancement sans committer les clés :
```
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

**7. Vérification**
```
flutter run
```

**8. Installation d'Android SDK (Windows)**
Via Android Studio, qui installe et configure le SDK automatiquement :
- Télécharger et installer Android Studio (mode Standard) depuis developer.android.com/studio → installe SDK + émulateur + Platform-Tools
- SDK situé par défaut dans `C:\Users\<TonNom>\AppData\Local\Android\Sdk`
- Compléter les composants via SDK Manager (`File > Settings > Languages & Frameworks > Android SDK`) : dernière version stable + Build-Tools + Command-line Tools + Platform-Tools
- Variables d'environnement Windows : `ANDROID_HOME` = chemin du SDK, puis ajouter à `Path` :
```
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\cmdline-tools\latest\bin
```
- Accepter les licences :
```
flutter doctor --android-licenses
```
- Vérifier :
```
flutter doctor
```

**9. Lancer et tester l'app (VS Code)**
VS Code a besoin d'une cible pour exécuter l'app — un émulateur ou un appareil physique.
- Vérifier que l'extension **Flutter** est installée dans VS Code (installe aussi Dart automatiquement)
- Émulateur : Android Studio → *More Actions* → *Virtual Device Manager* → créer un appareil virtuel (ex : Pixel 7) → le lancer → il apparaît ensuite dans le sélecteur d'appareil de VS Code
- Ou appareil physique : activer les options développeur sur le téléphone (*Paramètres > À propos > taper 7x sur "Numéro de build"*), activer le **Débogage USB**, connecter en USB, autoriser la popup sur le téléphone
- Vérifier avec :
```
flutter devices
```
