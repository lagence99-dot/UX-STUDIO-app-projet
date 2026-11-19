-- Daily project briefings: recipients, preferences and idempotent delivery log.
create table if not exists public.daily_briefing_settings (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.organizations(id) on delete cascade,
  enabled boolean not null default false,
  weekdays_only boolean not null default true,
  send_time time not null default '08:00',
  timezone text not null default 'Europe/Paris',
  include_budget boolean not null default true,
  include_week_tasks boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id)
);
create table if not exists public.daily_briefing_recipients (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.organizations(id) on delete cascade,
  project_id uuid references public.projects(id) on delete cascade,
  email text not null,
  full_name text,
  role text,
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  unique (project_id, email)
);
create table if not exists public.daily_briefing_logs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references public.projects(id) on delete cascade,
  recipient_email text not null,
  briefing_date date not null,
  status text not null default 'sent',
  provider_id text,
  error text,
  created_at timestamptz not null default now(),
  unique (project_id, recipient_email, briefing_date)
);
create index if not exists daily_briefing_recipients_project_idx on public.daily_briefing_recipients(project_id) where enabled;
create index if not exists daily_briefing_logs_date_idx on public.daily_briefing_logs(briefing_date);
alter table public.daily_briefing_settings enable row level security;
alter table public.daily_briefing_recipients enable row level security;
alter table public.daily_briefing_logs enable row level security;
create policy "org members manage briefing settings" on public.daily_briefing_settings for all using (organization_id is not null and public.is_org_member(organization_id)) with check (organization_id is not null and public.is_org_member(organization_id));
create policy "org members manage briefing recipients" on public.daily_briefing_recipients for all using (organization_id is not null and public.is_org_member(organization_id)) with check (organization_id is not null and public.is_org_member(organization_id));
create policy "org members view briefing logs" on public.daily_briefing_logs for select using (exists (select 1 from public.projects p where p.id = project_id and public.is_org_member(p.organization_id)));
