# Briefing automatique — lundi à vendredi, 08:00 Europe/Paris

## Architecture
- Supabase PostgreSQL conserve les préférences, destinataires et journaux d'envoi.
- Supabase Edge Function `daily-briefing` récupère les projets actifs et les tâches depuis `projects.project_data.tasks`, puis envoie un message individuel à chaque e-mail d'intervenant présent dans `projects.project_members`.
- Resend transporte les e-mails.
- Le déclencheur doit appeler la fonction toutes les 15 minutes. La fonction ne poursuit l'envoi qu'à 08:00 Europe/Paris du lundi au vendredi. Cela évite les décalages heure d'été/hiver dus à un cron UTC fixe.

## Pré-requis avant activation
1. Créer un projet Supabase et migrer les tables de base (`supabase/schema.sql`), puis exécuter `supabase/migrations/202611150001_daily_briefing.sql`.
2. Créer et vérifier un domaine d'envoi dans Resend.
3. Déployer `supabase/functions/daily-briefing`.
4. Configurer les secrets Edge Function : `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `RESEND_API_KEY`, `BRIEFING_FROM_EMAIL`, `BRIEFING_CRON_SECRET`.
5. Programmer un appel HTTP toutes les 15 minutes vers `https://<project-ref>.supabase.co/functions/v1/daily-briefing`, avec l'en-tête `x-cron-secret: <BRIEFING_CRON_SECRET>` et `Content-Type: application/json`.
6. Ajouter les intervenants réels dans `project_members` avec leur adresse e-mail. Aucun envoi ne part aux membres sans adresse valide.

## Important
Le prototype actuel stocke encore projets et intervenants dans le navigateur. Tant que les données ne sont pas migrées vers Supabase, l'Edge Function n'a aucune donnée projet à lire et aucun mail ne sera envoyé. Cette intégration est préparée, mais elle ne peut pas être activée sans les identifiants Supabase, la clé Resend, un domaine vérifié et la migration des données locales. Le service role key et la clé Resend ne doivent jamais être intégrés au navigateur.

## Exemple de planification native Supabase (pg_cron + pg_net)

Après avoir activé les extensions `pg_cron`, `pg_net` et `supabase_vault`, stocker le secret partagé dans Vault sous le nom `briefing_cron_secret`, puis programmer l'appel toutes les 15 minutes :

```sql
select cron.schedule(
  'uxstudio-daily-briefing-check',
  '*/15 * * * *',
  $$
  select net.http_post(
    url := 'https://<project-ref>.supabase.co/functions/v1/daily-briefing',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-cron-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'briefing_cron_secret' limit 1)
    ),
    body := '{}'::jsonb
  );
  $$
);
```

L'Edge Function filtre elle-même l'horaire local `Europe/Paris` et n'envoie qu'à 08:00 les jours ouvrés. Vérifier les journaux `cron.job_run_details` et les logs de la fonction après activation.
