-- State Scout: player profiles with PIN-gated progress sync.
-- The anon (publishable) key can ONLY call the three RPC functions below;
-- the table itself is locked down (RLS on, no policies, privileges revoked).

create table if not exists public.players (
  slug       text primary key check (slug ~ '^[a-z0-9-]{2,24}$'),
  name       text not null check (char_length(name) between 2 and 24),
  pin_hash   text not null check (pin_hash ~ '^[0-9a-f]{64}$'),
  progress   jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.players enable row level security;
revoke all on table public.players from anon, authenticated;

create or replace function public.player_create(
  p_slug text, p_name text, p_pin_hash text, p_progress jsonb default '{}'::jsonb
) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  if exists (select 1 from players where slug = p_slug) then
    return jsonb_build_object('error', 'taken');
  end if;
  insert into players (slug, name, pin_hash, progress)
  values (p_slug, p_name, p_pin_hash, coalesce(p_progress, '{}'::jsonb));
  return jsonb_build_object('ok', true);
exception when others then
  return jsonb_build_object('error', 'server');
end $$;

create or replace function public.player_load(p_slug text, p_pin_hash text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare rec players;
begin
  select * into rec from players where slug = p_slug;
  if not found then return jsonb_build_object('error', 'not_found'); end if;
  if rec.pin_hash <> p_pin_hash then return jsonb_build_object('error', 'wrong_pin'); end if;
  return jsonb_build_object('ok', true, 'name', rec.name, 'progress', rec.progress);
end $$;

create or replace function public.player_save(p_slug text, p_pin_hash text, p_progress jsonb) returns jsonb
language plpgsql security definer set search_path = public as $$
declare rec players;
begin
  select * into rec from players where slug = p_slug;
  if not found then return jsonb_build_object('error', 'not_found'); end if;
  if rec.pin_hash <> p_pin_hash then return jsonb_build_object('error', 'wrong_pin'); end if;
  if p_progress is null or jsonb_typeof(p_progress) <> 'object'
     or pg_column_size(p_progress) > 20000 then
    return jsonb_build_object('error', 'server');
  end if;
  update players set progress = p_progress, updated_at = now() where slug = p_slug;
  return jsonb_build_object('ok', true);
end $$;

grant execute on function public.player_create(text, text, text, jsonb) to anon;
grant execute on function public.player_load(text, text) to anon;
grant execute on function public.player_save(text, text, jsonb) to anon;
