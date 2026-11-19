# UX Studio — édition HTML statique

Cette édition transforme l'interface Next.js en site statique exportable (HTML, CSS et JavaScript). Les données du prototype restent enregistrées dans le stockage local du navigateur (`localStorage`).

## Générer le dossier HTML

Prérequis : Node.js 20 ou plus récent.

1. Décompresser l'archive.
2. Ouvrir Terminal dans le dossier `ux-studio`.
3. Exécuter :

```bash
npm install
npm run export
```

4. Le site statique est généré dans le dossier `out/`.

Pour l'ouvrir de manière fiable, déposer le contenu de `out/` sur un hébergement statique (Netlify, Vercel static, GitHub Pages ou serveur web local). Le double-clic direct sur `index.html` peut être limité par les règles de sécurité des navigateurs.

## Limites de cette édition HTML

- Les projets et préférences restent locaux au navigateur et à cet ordinateur.
- Pas de synchronisation entre ordinateurs ni de comptes multi-utilisateurs.
- L'analyse IA d'une URL est désactivée dans cette édition : elle nécessite une API serveur pour protéger la clé OpenAI. Ne jamais placer une clé secrète dans le HTML ou le JavaScript public.
- Les briefings email planifiés Supabase/Resend ne sont pas actifs dans cette édition.
- Les fichiers enregistrés localement dans le navigateur ne constituent pas une sauvegarde cloud.

Pour activer l'analyse IA, la synchronisation ou les emails, il faudra une version hébergée avec un backend sécurisé.

## Version de départ

Basée sur UX Studio 1.6.2, avec correctif de navigation entre Pilotage du projet et Pilotage projet IA.
