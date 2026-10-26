# Jakarta Vocab Duo

15 minutes d'anglais par jour, à deux, pour préparer la vie à Jakarta : révision espacée, Taboo, phrases à trous, jeux de rôle, duel express et histoire à deux.

- Chacun a son compte (email et mot de passe) et son propre paquet de révisions espacées.
- Séances à deux sur le même écran, ou seul : seuls les points de la personne qui joue comptent.
- Points, séries, thème de la semaine et progrès sont partagés dans un espace couple, synchronisés entre téléphone et ordinateur.
- Page Progrès : expressions maîtrisées, points par semaine, expressions les plus difficiles et séance express pour les retravailler.
- Fonctionne hors ligne une fois ouverte une première fois ; la synchro reprend au retour du réseau.
- L'appli s'installe sur l'écran d'accueil du téléphone (Partager > Sur l'écran d'accueil sur iPhone, menu ⋮ > Ajouter à l'écran d'accueil sur Android).

## Fichiers

| Fichier | Rôle |
|---|---|
| `index.html` | L'application |
| `config.js` | Adresse et clé publique du projet Supabase |
| `supabase.sql` | Tables, règles d'accès et fonctions de la base |
| `manifest.webmanifest`, `icon*` | Installation sur l'écran d'accueil |
| `sw.js` | Fonctionnement hors ligne |

## Mise en place

### 1. Supabase (comptes et sauvegarde)

1. Créer un compte sur supabase.com, puis un nouveau projet (offre gratuite).
2. Ouvrir **SQL Editor**, coller tout le contenu de `supabase.sql`, cliquer sur **Run**.
3. Dans **Project Settings > API**, copier l'**URL du projet** et la **clé publique** (publishable ou anon). Ne jamais utiliser la clé secrète (service_role).
4. Les coller dans `config.js`.
5. Dans **Authentication > URL Configuration**, mettre l'adresse GitHub Pages de l'appli dans **Site URL** (par exemple `https://ton-compte.github.io/jakarta-vocab-duo/`) et l'ajouter aux **Redirect URLs**. C'est ce qui fait fonctionner les liens de confirmation et de mot de passe oublié.

Un projet Supabase gratuit se met en pause après une semaine sans aucune activité. Il suffit de le relancer depuis le tableau de bord Supabase.

### 2. GitHub Pages (hébergement)

Dans le dépôt : **Settings > Pages > Source : Deploy from a branch**, branche `main`, dossier `/ (root)`.

### 3. Premier lancement

1. Gabriel crée son compte, confirme son email, se connecte, puis clique sur **Créer l'espace**. Un code à 6 caractères s'affiche en bas de la page d'accueil.
2. Margot crée son compte, confirme son email, se connecte, puis entre ce code dans **Rejoindre un espace**.

## Mise à jour de sécurité (si la base a été créée avant)

Dans **SQL Editor**, lancer une fois :

```sql
revoke update on public.couples from authenticated, anon;
grant update (state, updated_at) on public.couples to authenticated;
```

## Sans compte

Avec `config.js` vide, l'appli fonctionne aussi : la progression est alors gardée uniquement sur l'appareil.
