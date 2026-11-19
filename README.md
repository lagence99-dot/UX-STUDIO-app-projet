# UX Studio — Projet Essentiel (prototype local)

Version de travail du produit UX Studio, orientée **Projet Essentiel** (0.3.0).

## Fonctionnalités présentes

- Création d'un compte local et connexion sur le même navigateur.
- Tableau de bord.
- Gestion des clients : création, liste et suppression.
- Création de projets Essentiel UX avec budget, dates et équipe.
- Espace projet : pilotage, statut, équipe et tâches.
- Parcours UX : brief, recherche, personas, user journey, audit UX, moodboard, priorisation MVP et livrables.
- Recherche : saisie manuelle et import de fichiers Excel (.xlsx, .xls), CSV, Word (.docx), texte (.txt) et Markdown (.md), séparés entre données qualitatives et quantitatives.
- Recherche : compte rendu préliminaire local avec repérage de mots récurrents et extraction d’extraits.
- Personas : besoins, objectifs, irritants, verbatims et fonctionnalités potentielles par profil.
- Backlog de fonctionnalités sous forme de cartes, regroupées par persona.
- Parcours utilisateur : association des étapes à un persona, filtre par profil et visualisation graphique horizontale.
- Sauvegarde locale automatique dans le navigateur.
- Export des livrables via la fonction d'impression du navigateur (choisir « Enregistrer au format PDF »).

## Installation sur macOS

1. Installer Node.js LTS : https://nodejs.org/
2. Ouvrir le dossier `ux-studio` dans Visual Studio Code.
3. Dans le terminal intégré :

```bash
npm install
npm run dev
```

4. Ouvrir http://localhost:3000.

## Important — état technique

Cette version est un **prototype fonctionnel local**, pas encore un SaaS hébergé.

- Les comptes et les données sont conservés dans le stockage local du navigateur.
- Le mot de passe n'est pas envoyé à un serveur ; le compte local ne permet pas de se connecter depuis un autre ordinateur ou navigateur.
- Les invitations sont enregistrées dans l'équipe du projet mais aucun e-mail n'est envoyé.
- L’import du brief conserve encore le nom du document ; l’extraction du contenu du brief sera traitée séparément.
- L’analyse de recherche de cette version est une aide locale heuristique, pas une analyse par grand modèle de langage. Elle ne navigue pas sur Internet et ne remplace pas l’interprétation du consultant UX.
- La génération de personas à partir de données sectorielles sur Internet et l’import d’un modèle graphique de persona ne sont pas encore connectés.
- L'analyse IA, Google OAuth, la synchronisation multi-utilisateur, Supabase et les abonnements Stripe ne sont pas encore connectés.
- Les images du moodboard sont conservées localement (limite de 1,5 Mo par image).

La prochaine étape technique pour passer en SaaS consiste à connecter Supabase Auth, PostgreSQL et Storage, puis à appliquer les politiques RLS du schéma de données. Ne pas utiliser cette version locale pour stocker des données confidentielles ou personnelles de clients.


### Recherche et personas — version 0.4.0
La recherche accepte la saisie manuelle et l’import de fichiers CSV, Excel (.xlsx, .xls), Word (.docx), texte (.txt) et Markdown (.md). Les données importées sont extraites dans les champs quantitatifs ou qualitatifs, puis peuvent être synthétisées par un repérage local des thèmes et extraits. Cette synthèse n’est pas une analyse par IA générative.

Les fiches personas comprennent le segment, l’âge, la profession, la localisation, les motivations, les besoins, les objectifs, les frustrations, les verbatims, les fonctionnalités potentielles, les canaux et les traits de personnalité. Les personas créés restent modifiables dans les données du projet, mais l’édition détaillée d’une fiche existante est à compléter dans une prochaine itération.

Les propositions de personas issues d’une recherche Internet ou d’une IA externe ne sont pas activées dans cette version : les profils hypothétiques doivent être renseignés et validés à partir de données vérifiables.

### Version 0.6.0 — Interface 2026
L'espace de travail adopte désormais une interface sombre premium (bleu nuit, violet et magenta). Dans Personas, une photo peut être ajoutée à la fiche et apparaît dans la restitution graphique. Dans Pilotage du projet, le planning Gantt présente les tâches sur 12 semaines. Chaque tâche peut contenir une date de début, une échéance, un responsable et un budget. Glissez une barre sur une autre semaine pour décaler son calendrier ; la durée est conservée. Les budgets de tâches sont consolidés par intervenant et dans le budget planifié.

Limites de cette version : le Gantt fonctionne sur une fenêtre de 12 semaines et le déplacement se fait par semaine (pas à la journée). Les budgets par intervenant correspondent à la somme des budgets des tâches qui lui sont affectées ; aucun taux journalier ou coût horaire n'est encore calculé automatiquement. Les photos de persona sont stockées dans le stockage local du navigateur.

### Planning & Budget (0.7.0)
Les événements et tâches partagent une fiche de modification. Double-cliquez un élément du diagramme de Gantt pour ouvrir l’éditeur. Renseignez début/fin, intervenant, tarif journalier ou budget fixe, priorité et couleur. La poignée à droite de la barre permet d’étendre sa durée; le glisser-déposer décale l’élément. Le tarif journalier est calculé sur les jours calendaires, dates de début et de fin incluses.

### Bibliothèque de tâches (0.9.0)

Le formulaire de planning propose des catégories prédéfinies organisées par familles : recherche et cadrage, UX et conception, UI et prototypage, production et livraison. L’intitulé reste libre et les niveaux de priorité existants sont conservés.

### Briefing quotidien par e-mail — préparation 1.0.0
Un écran **Briefing quotidien** permet de définir l'envoi du lundi au vendredi à 08:00 (Europe/Paris), ainsi que les sections à inclure. Le choix est conservé localement dans ce prototype. Le socle serveur est fourni dans `supabase/migrations/202611150001_daily_briefing.sql` et `supabase/functions/daily-briefing` : fonction d'envoi Resend, filtrage heure de Paris, destinataires d'équipe et journal anti-doublon. Lire `supabase/README-briefing.md` pour le déploiement et la planification.

**Non activé dans cette archive :** les projets et membres de l'application sont encore stockés dans le navigateur. Les e-mails ne peuvent pas partir tant que les données ne sont pas migrées vers Supabase, que les secrets Supabase/Resend ne sont pas configurés et que la fonction planifiée n'est pas déployée. Ne jamais mettre une clé service role ou Resend dans le code client.

### Planning interactif (v1.1)
Le planning propose une vue Gantt sur 12 mois, une vue semaine et une vue liste. Les tâches peuvent être déplacées, redimensionnées et ouvertes dans une fiche latérale qui contient description, notes, points à traiter, liens et tickets de projet. Dans le Gantt, maintenez la barre Espace et faites glisser la souris pour naviguer horizontalement. Les métadonnées des pièces jointes sont conservées localement ; le stockage réel des fichiers sera raccordé à Supabase Storage.


## Analyse de site assistée par IA

Pour activer le bouton « Lancer l’analyse IA » dans Pilotage projet IA :
1. Créer un fichier `.env.local` à la racine du projet.
2. Ajouter `OPENAI_API_KEY=...` et éventuellement `OPENAI_ANALYSIS_MODEL=gpt-6-astra`.
3. Redémarrer `npm run dev`.

La clé reste côté serveur dans `src/app/api/project-analysis/route.ts`. L'analyse utilise l'API Responses d'OpenAI avec l'outil `web_search`. Elle produit une pré-étude, des personas au statut « Hypothèse » et des étapes de parcours reliées aux personas. Les résultats sont à vérifier par une recherche utilisateur réelle. L'appel API est facturé selon le compte OpenAI utilisé.
