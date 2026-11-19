# Changelog

## 1.0.0 — Préparation du briefing quotidien
- Ajout d'un écran de configuration du briefing : lundi–vendredi, 08:00, fuseau Europe/Paris par défaut.
- Préférences locales : activation, inclusion du récapitulatif hebdomadaire et du budget.
- Migration SQL pour les paramètres, destinataires et journaux d'envoi.
- Edge Function Supabase utilisant Resend, destinataires de projet et journal anti-doublon.
- Documentation du déploiement et du déclenchement périodique compatible heure d'été/hiver.
- L'envoi réel reste inactif tant que les données ne sont pas hébergées dans Supabase et que les secrets / domaine Resend ne sont pas configurés.

## 1.1.0 — Planning interactif
- Vue macro étendue sur 12 mois calendaires et navigation par période.
- Déplacement des éléments par glisser-déposer et redimensionnement de leur durée.
- Navigation horizontale au clavier : maintenir Espace et déplacer la souris.
- Ajout d'une vue liste structurée des étapes.
- Ajout d'une fiche latérale par étape : description, notes, points à traiter, liens, fichiers référencés et tickets développement/recette/anomalie/amélioration.
- Les champs complémentaires restent dans les données locales du projet. Le téléversement binaire et le partage des fichiers nécessitent encore le raccordement à Supabase Storage.
