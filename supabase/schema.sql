-- Schéma cible pour la future version SaaS multi-organisations.
-- À exécuter dans Supabase après revue ; la version actuelle fonctionne en stockage local.
create extension if not exists pgcrypto;

create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique,
  created_at timestamptz not null default now()
);
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  created_at timestamptz not null default now()
);
create table if not exists public.memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','admin','manager','member')),
  created_at timestamptz not null default now(),
  unique (organization_id, user_id)
);
create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  name text not null,
  contact text,
  email text,
  website text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  client_id uuid references public.clients(id) on delete set null,
  name text not null,
  description text,
  project_type text not null default 'essential',
  status text not null default 'draft',
  progress integer not null default 0 check (progress between 0 and 100),
  budget numeric(12,2),
  budget_type text,
  start_date date,
  due_date date,
  project_data jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.project_members (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  email text not null,
  full_name text,
  role text not null,
  invitation_status text not null default 'pending',
  created_at timestamptz not null default now()
);
create index if not exists memberships_user_idx on public.memberships(user_id);
create index if not exists clients_org_idx on public.clients(organization_id);
create index if not exists projects_org_idx on public.projects(organization_id);
create index if not exists projects_client_idx on public.projects(client_id);
create index if not exists project_members_project_idx on public.project_members(project_id);

create or replace function public.is_org_member(target_org uuid)
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.memberships m where m.organization_id = target_org and m.user_id = auth.uid()); $$;

alter table public.organizations enable row level security;
alter table public.profiles enable row level security;
alter table public.memberships enable row level security;
alter table public.clients enable row level security;
alter table public.projects enable row level security;
alter table public.project_members enable row level security;

create policy "members can view their organizations" on public.organizations for select using (public.is_org_member(id));
create policy "users can view own profile" on public.profiles for select using (id = auth.uid());
create policy "users can update own profile" on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());
create policy "members can view memberships in their organizations" on public.memberships for select using (public.is_org_member(organization_id));
create policy "members can view clients in their organizations" on public.clients for select using (public.is_org_member(organization_id));
create policy "members can insert clients in their organizations" on public.clients for insert with check (public.is_org_member(organization_id));
create policy "members can update clients in their organizations" on public.clients for update using (public.is_org_member(organization_id)) with check (public.is_org_member(organization_id));
create policy "admins can delete clients in their organizations" on public.clients for delete using (exists (select 1 from public.memberships m where m.organization_id = clients.organization_id and m.user_id = auth.uid() and m.role in ('owner','admin')));
create policy "members can view projects in their organizations" on public.projects for select using (public.is_org_member(organization_id));
create policy "members can create projects in their organizations" on public.projects for insert with check (public.is_org_member(organization_id));
create policy "members can update projects in their organizations" on public.projects for update using (public.is_org_member(organization_id)) with check (public.is_org_member(organization_id));
create policy "admins can delete projects in their organizations" on public.projects for delete using (exists (select 1 from public.memberships m where m.organization_id = projects.organization_id and m.user_id = auth.uid() and m.role in ('owner','admin')));
create policy "members can view project members" on public.project_members for select using (exists (select 1 from public.projects p where p.id = project_id and public.is_org_member(p.organization_id)));
create policy "members can manage project members" on public.project_members for all using (exists (select 1 from public.projects p where p.id = project_id and public.is_org_member(p.organization_id))) with check (exists (select 1 from public.projects p where p.id = project_id and public.is_org_member(p.organization_id)));
