-- Jakarta Vocab Duo : base de données Supabase
-- À coller en entier dans Supabase > SQL Editor > New query, puis cliquer sur Run.

create table if not exists public.couples (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.couple_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  couple_id uuid not null references public.couples(id) on delete cascade,
  joined_at timestamptz not null default now()
);

alter table public.couples enable row level security;
alter table public.couple_members enable row level security;

-- Chaque personne ne voit que sa propre appartenance
drop policy if exists "read own membership" on public.couple_members;
create policy "read own membership" on public.couple_members
  for select to authenticated using (user_id = auth.uid());

-- Les membres d'un espace couple peuvent lire et mettre à jour sa progression
drop policy if exists "members read couple" on public.couples;
create policy "members read couple" on public.couples
  for select to authenticated using (
    exists (select 1 from public.couple_members m where m.couple_id = couples.id and m.user_id = auth.uid())
  );

drop policy if exists "members update couple" on public.couples;
create policy "members update couple" on public.couples
  for update to authenticated using (
    exists (select 1 from public.couple_members m where m.couple_id = couples.id and m.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.couple_members m where m.couple_id = couples.id and m.user_id = auth.uid())
  );

-- Créer un espace et recevoir un code à 6 caractères
create or replace function public.create_couple() returns text
language plpgsql security definer set search_path = public as $$
declare
  c uuid;
  k text;
begin
  if auth.uid() is null then raise exception 'not_signed_in'; end if;
  if exists (select 1 from couple_members where user_id = auth.uid()) then
    raise exception 'already_in_couple';
  end if;
  loop
    k := upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));
    exit when not exists (select 1 from couples where code = k);
  end loop;
  insert into couples(code) values (k) returning id into c;
  insert into couple_members(user_id, couple_id) values (auth.uid(), c);
  return k;
end $$;

-- Rejoindre un espace avec son code (2 personnes maximum)
create or replace function public.join_couple(p_code text) returns void
language plpgsql security definer set search_path = public as $$
declare
  c uuid;
begin
  if auth.uid() is null then raise exception 'not_signed_in'; end if;
  select id into c from couples where code = upper(trim(p_code));
  if c is null then raise exception 'code_not_found'; end if;
  if exists (select 1 from couple_members where user_id = auth.uid() and couple_id = c) then return; end if;
  if exists (select 1 from couple_members where user_id = auth.uid()) then raise exception 'already_in_couple'; end if;
  if (select count(*) from couple_members where couple_id = c) >= 2 then raise exception 'couple_full'; end if;
  insert into couple_members(user_id, couple_id) values (auth.uid(), c);
end $$;

revoke all on function public.create_couple() from public, anon;
revoke all on function public.join_couple(text) from public, anon;
grant execute on function public.create_couple() to authenticated;
grant execute on function public.join_couple(text) to authenticated;

-- Les membres ne peuvent modifier que la progression, jamais le code de l'espace
revoke update on public.couples from authenticated, anon;
grant update (state, updated_at) on public.couples to authenticated;
