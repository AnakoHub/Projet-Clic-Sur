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

> **Adaptations pour Supabase** (détail en Annexe B) :
> - La table `users` devient **`profiles`** : l'authentification (email, mot de passe hashé) est gérée par `auth.users` de Supabase, `profiles.id` y fait référence.
> - Le champ `order` devient **`sort_order`** (`order` est un mot réservé en SQL).
> - Ajout de **`levels.slug`** (`mdp`, `phishing`, `reseau`, `auth`) : c'est l'identifiant utilisé par l'app dans ses routes (`/quiz/mdp`).
> - Les questions du quiz sont de type `vrai_faux` : `correct_answer` vaut `true` ou `false` (jsonb) et `options` reste vide.

---

## 4. Endpoints API principaux (REST)

> Avec Supabase, ces endpoints n'ont **pas à être écrits** : l'API REST est générée automatiquement à partir des tables, et le client `supabase_flutter` l'appelle directement (`supabase.from('levels').select()`). La liste ci-dessous reste valable comme référence fonctionnelle, ou si l'on migre vers l'option B.

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

## Annexe A — Initialisation pratique du projet Flutter

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
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
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

---

## Annexe B — Mise en place de Supabase

Ordre à suivre : projet → schéma → profil automatique → sécurité (RLS) → authentification → contenu → connexion Flutter → vérification. Toutes les requêtes SQL se lancent dans **SQL Editor → New query → Run** depuis le dashboard Supabase.

> Ces scripts n'ont pas été exécutés sur une instance réelle au moment de la rédaction : les lancer sur un projet de test d'abord, et lire les éventuels messages d'erreur avant de poursuivre.

### B.1 Créer le projet et récupérer les clés

1. Sur supabase.com, créer un compte puis **New project** (nom, mot de passe de base de données à conserver, région européenne proche).
2. Attendre la fin du provisioning (1 à 2 minutes).
3. **Project Settings → API** : noter la **Project URL** (`SUPABASE_URL`) et la clé **anon public** (`SUPABASE_ANON_KEY`).
4. Ne jamais utiliser la clé **service_role** dans l'app : elle contourne toutes les règles de sécurité.

### B.2 Créer le schéma

```sql
-- Types énumérés
create type card_type       as enum ('lesson', 'quiz', 'challenge');
create type question_type   as enum ('qcm', 'vrai_faux', 'glisser_deposer');
create type progress_status as enum ('locked', 'in_progress', 'completed');

-- Profil utilisateur (l'authentification reste dans auth.users)
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  pseudo      text not null,
  avatar_url  text,
  xp_total    integer not null default 0,
  streak_days integer not null default 0,
  created_at  timestamptz not null default now()
);

-- Contenu pédagogique
create table themes (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text,
  icon        text,
  sort_order  integer not null default 0
);

create table levels (
  id               uuid primary key default gen_random_uuid(),
  theme_id         uuid not null references themes(id) on delete cascade,
  slug             text not null unique,
  sort_order       integer not null default 0,
  title            text not null,
  description      text,
  xp_reward        integer not null default 0,
  unlock_condition jsonb
);

create table cards (
  id         uuid primary key default gen_random_uuid(),
  level_id   uuid not null references levels(id) on delete cascade,
  sort_order integer not null default 0,
  type       card_type not null,
  content    jsonb not null default '{}'::jsonb
);

create table questions (
  id             uuid primary key default gen_random_uuid(),
  card_id        uuid not null references cards(id) on delete cascade,
  question_text  text not null,
  type           question_type not null default 'vrai_faux',
  options        jsonb,
  correct_answer jsonb not null,
  explanation    text
);

-- Données propres à chaque utilisateur
create table user_progress (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id) on delete cascade,
  level_id     uuid not null references levels(id) on delete cascade,
  status       progress_status not null default 'locked',
  score        integer not null default 0,
  completed_at timestamptz,
  unique (user_id, level_id)
);

create table user_answers (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id) on delete cascade,
  question_id  uuid not null references questions(id) on delete cascade,
  answer_given jsonb not null,
  is_correct   boolean not null,
  answered_at  timestamptz not null default now()
);

-- Gamification
create table badges (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text,
  icon        text,
  condition   jsonb
);

create table user_badges (
  user_id   uuid not null references profiles(id) on delete cascade,
  badge_id  uuid not null references badges(id) on delete cascade,
  earned_at timestamptz not null default now(),
  primary key (user_id, badge_id)
);
```

### B.3 Créer le profil automatiquement à l'inscription

Sans ce déclencheur, un utilisateur inscrit existerait dans `auth.users` mais n'aurait aucune ligne dans `profiles`.

```sql
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, pseudo)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'pseudo', split_part(new.email, '@', 1))
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
```

### B.4 Activer la sécurité par lignes (RLS)

Principe : **toutes les tables ont le RLS activé**, et une table sans règle est inaccessible. On ouvre ensuite uniquement ce qui est nécessaire.

```sql
alter table profiles      enable row level security;
alter table themes        enable row level security;
alter table levels        enable row level security;
alter table cards         enable row level security;
alter table questions     enable row level security;
alter table user_progress enable row level security;
alter table user_answers  enable row level security;
alter table badges        enable row level security;
alter table user_badges   enable row level security;

-- Contenu pédagogique : lecture seule pour les utilisateurs connectés
create policy "contenu lisible" on themes    for select to authenticated using (true);
create policy "contenu lisible" on levels    for select to authenticated using (true);
create policy "contenu lisible" on cards     for select to authenticated using (true);
create policy "contenu lisible" on questions for select to authenticated using (true);
create policy "contenu lisible" on badges    for select to authenticated using (true);

-- Profils : lisibles par tous les connectés (nécessaire au classement),
-- modifiables uniquement par leur propriétaire
create policy "profils lisibles" on profiles
  for select to authenticated using (true);
create policy "profil modifiable par son proprio" on profiles
  for update to authenticated
  using (auth.uid() = id) with check (auth.uid() = id);

-- Un utilisateur ne peut pas s'attribuer d'XP : seules ces colonnes sont modifiables
revoke update on profiles from authenticated;
grant  update (pseudo, avatar_url) on profiles to authenticated;

-- Progression : chacun ne voit et n'écrit que la sienne
create policy "progression perso" on user_progress
  for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Réponses : chacun ne voit et n'écrit que les siennes
create policy "reponses perso" on user_answers
  for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Badges obtenus : lecture de ses propres badges uniquement
-- (l'attribution se fera côté serveur, voir B.9)
create policy "badges perso" on user_badges
  for select to authenticated using (auth.uid() = user_id);
```

### B.5 Configurer l'authentification

Dans **Authentication** du dashboard :

1. **Providers → Email** : activé (par défaut).
2. **Confirm email** : le désactiver pendant le développement pour tester sans boîte mail, le réactiver avant la mise en production.
3. **URL Configuration** : renseigner la *Site URL* et, quand l'app sera publiée, l'URL de redirection (deep link) utilisée pour les e-mails de confirmation et de réinitialisation.
4. Connexion Google / Apple : optionnelle, à ajouter plus tard (Apple devient obligatoire sur iOS si une autre connexion sociale est proposée).

### B.6 Injecter le contenu pédagogique

Le script ci-dessous crée un thème, son niveau, une carte de quiz et ses 5 questions Vrai/Faux. Il illustre le schéma à reproduire pour les trois autres niveaux (`phishing`, `reseau`, `auth`), dont les textes se trouvent dans `lib/features/quiz/data/quiz_data.dart`. Les apostrophes dans les textes SQL se doublent (`''`).

```sql
with t as (
  insert into themes (name, description, icon, sort_order)
  values ('Mots de passe', 'Créer et gérer des mots de passe solides', 'key', 1)
  returning id
),
l as (
  insert into levels (theme_id, slug, sort_order, title, description, xp_reward)
  select id, 'mdp', 1, 'Mots de passe', 'Premiers pas', 100 from t
  returning id
),
c as (
  insert into cards (level_id, sort_order, type)
  select id, 1, 'quiz'::card_type from l
  returning id
)
insert into questions (card_id, question_text, type, correct_answer, explanation)
select c.id, q.text, 'vrai_faux'::question_type, q.answer, q.explanation
from c,
(values
  ('Un mot de passe long est généralement plus sûr qu''un mot de passe court rempli de symboles.',
   'true'::jsonb,
   'Chaque caractère ajouté multiplie le nombre de combinaisons à tester.'),
  ('Remplacer les « a » par des « @ » et les « o » par des « 0 » rend un mot de passe très sécurisé.',
   'false'::jsonb,
   'Les pirates connaissent ces astuces et leurs outils les testent automatiquement.'),
  ('Utiliser le même mot de passe sur plusieurs sites est acceptable s''il est très fort.',
   'false'::jsonb,
   'Si un seul site est piraté, ce mot de passe est testé sur tous vos autres comptes.'),
  ('Un gestionnaire de mots de passe est une solution sûre pour stocker ses mots de passe.',
   'true'::jsonb,
   'Il génère et mémorise des mots de passe uniques, protégés par un seul mot de passe maître.'),
  ('Il faut changer tous ses mots de passe tous les mois pour rester en sécurité.',
   'false'::jsonb,
   'Les recommandations actuelles déconseillent les changements systématiques.')
) as q(text, answer, explanation);
```

### B.7 Brancher l'app Flutter

**Principe.** `main.dart` ne fait qu'une chose : initialiser Supabase une seule fois au démarrage (`Supabase.initialize`, Annexe A, étape 6). Il ne contient aucun appel de données. Ensuite, chaque appel Supabase se place **dans le fichier de la fonctionnalité concernée**. Par analogie : `main.dart` installe la ligne téléphonique ; les écrans et dépôts passent les appels.

Dans l'app, le client est obtenu via `supabaseClientProvider` (`lib/core/supabase/supabase_provider.dart`) ou `Supabase.instance.client`.

| Fonctionnalité | Fichier | Appel Supabase |
|---|---|---|
| Initialisation | `lib/main.dart` | `Supabase.initialize(url, anonKey)` |
| Inscription / connexion | `lib/features/auth/presentation/login_screen.dart` | `auth.signUp`, `auth.signInWithPassword` |
| Déconnexion | `lib/features/profile/presentation/profile_screen.dart` | `auth.signOut` |
| Redirection selon la session | `lib/core/router/app_router.dart` | `auth.currentSession`, `auth.onAuthStateChange` |
| Lecture des niveaux et questions | `lib/features/quiz/data/quiz_repository.dart` | `from('levels').select(...)` |
| Lecture de la progression | `lib/features/quiz/data/quiz_repository.dart` | `from('user_progress').select(...)` |
| Enregistrement d'une réponse | `lib/features/quiz/data/quiz_repository.dart` (appelé par `quiz_screen.dart`) | `from('user_answers').insert(...)` |
| Enregistrement du résultat d'un niveau | `lib/features/quiz/data/quiz_repository.dart` (appelé par `quiz_screen.dart`) | `from('user_progress').upsert(...)` |

Les écrans n'appellent jamais Supabase directement pour le quiz : ils passent par `QuizRepository` et ses providers Riverpod. Le jour où le contenu change de source, un seul fichier est à modifier.

**Inscription et connexion** (`login_screen.dart`)
```dart
// Le pseudo est transmis dans les métadonnées ; le déclencheur B.3 le lit.
await auth.signUp(email: email, password: password, data: {'pseudo': pseudo});
await auth.signInWithPassword(email: email, password: password);
```
Si la confirmation par email est activée (B.5), `signUp` ne renvoie pas de session : l'écran invite alors à confirmer l'adresse puis à se connecter.

**Redirection** (`app_router.dart`) : sans session, toute route renvoie vers `/login` ; avec session, `/login` renvoie vers `/home`. Le router se réévalue à chaque connexion ou déconnexion grâce à `GoRouterRefreshStream`.

**Lecture des niveaux et des questions** (`quiz_repository.dart`, méthode `fetchLevels`)
```dart
final rows = await client
    .from('levels')
    .select('id, slug, title, description, sort_order, '
        'cards(type, sort_order, questions(id, question_text, correct_answer, explanation))')
    .order('sort_order');
```
La jointure `levels → cards → questions` est automatique grâce aux clés étrangères. Le `quizLevelsProvider` expose le résultat à la Quiz Map, à l'intro de niveau et à l'écran de jeu, avec états de chargement, d'erreur et de liste vide. Seule la présentation (icône et couleur par `slug`) reste dans `quiz_data.dart` ; un niveau ajouté en base avec un nouveau slug reçoit un style par défaut, et un niveau sans question n'est pas affiché.

**Enregistrement des réponses** (`quiz_repository.dart`, méthode `saveAnswer`, appelée à chaque réponse par `quiz_screen.dart`)
```dart
await client.from('user_answers').insert({
  'user_id': userId,
  'question_id': questionId,
  'answer_given': answerGiven, // true ou false
  'is_correct': isCorrect,
});
```
Chaque réponse ajoute une ligne : rejouer un niveau conserve donc tout l'historique. L'enregistrement s'effectue en arrière-plan : un échec réseau est journalisé mais n'interrompt pas la partie.

**Enregistrement de la progression** (`quiz_repository.dart`, méthode `saveLevelResult`, appelée à la fin d'un niveau)
```dart
await client.from('user_progress').upsert({
  'user_id': userId,
  'level_id': levelDbId,
  'status': 'completed',
  'score': bestScore, // meilleur score entre la partie et l'existant
  'completed_at': DateTime.now().toUtc().toIso8601String(),
}, onConflict: 'user_id,level_id');
```
Il y a une seule ligne par utilisateur et par niveau (contrainte `unique (user_id, level_id)` de B.2) ; seul le meilleur score est conservé. La Quiz Map lit ces scores via `userProgressProvider` et affiche les étoiles : 1, 2 ou 3 étoiles à 60 %, 80 % et 100 % de bonnes réponses (`starThresholds` dans `quiz_data.dart`). Après une partie, le provider est invalidé et la carte se met à jour.

**Ordre des questions** : la table `questions` n'a pas de colonne d'ordre, l'app les affiche donc dans l'ordre renvoyé par la base (en pratique, celui d'insertion). Pour le garantir, ajouter une colonne `sort_order` à `questions`, puis trier dessus dans `fetchLevels`.

### B.8 Vérifier la mise en place

1. **Table Editor** : les 9 tables apparaissent, et `themes`, `levels`, `cards`, `questions` contiennent les lignes du seed.
2. **Inscription** : créer un compte depuis l'app, puis vérifier qu'une ligne est apparue dans `auth.users` **et** dans `profiles`.
3. **RLS sans connexion** : une requête avec la seule clé anon doit renvoyer une liste vide.
```
curl "https://<projet>.supabase.co/rest/v1/questions?select=*" \
  -H "apikey: <SUPABASE_ANON_KEY>"
```
4. **RLS connecté** : depuis l'app, un utilisateur voit le contenu pédagogique mais uniquement sa propre progression et ses propres réponses.
5. **Écriture interdite** : tenter de modifier `xp_total` depuis le client doit être refusé.
6. **Réponses enregistrées** : après avoir répondu à une question, une ligne apparaît dans `user_answers` (Table Editor) avec le bon `user_id`, `is_correct` cohérent et `answer_given` à `true` ou `false`.
7. **Progression enregistrée** : après avoir terminé un niveau, `user_progress` contient une ligne `completed` avec le score, et la Quiz Map affiche les étoiles correspondantes. Rejouer avec un score plus faible ne doit pas faire baisser le score conservé.
8. **Isolation des comptes** : avec un second compte, la Quiz Map repart sans étoiles et `user_progress` contient des lignes séparées.

### B.9 Points de vigilance

- **XP, scores et badges** : en MVP, la progression est écrite par le client, donc un utilisateur averti pourrait tricher sur son score. Pour un classement équitable, déplacer ces écritures dans une fonction SQL `security definer` (ou une Edge Function) qui calcule l'XP côté serveur, et ne plus autoriser l'écriture directe de `score`.
- **Bonnes réponses exposées** : `correct_answer` est lisible par le client, ce qui est cohérent avec une correction affichée immédiatement. Si des quiz certifiants sont ajoutés, la correction devra passer par le serveur.
- **Clé service_role** : à conserver hors de l'app et du dépôt Git.
- **Migrations** : une fois le schéma stabilisé, versionner le SQL dans le dépôt (Supabase CLI : `supabase migration new`) plutôt que de le rejouer à la main dans l'éditeur.
- **Sauvegardes** : vérifier la politique de sauvegarde du plan Supabase utilisé avant d'accueillir de vrais utilisateurs.
