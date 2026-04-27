create table if not exists public.configuracion_negocio (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nombre_comercio text not null,
  logo_url text
);

alter table public.configuracion_negocio enable row level security;

drop policy if exists config_select_own on public.configuracion_negocio;
drop policy if exists config_insert_own on public.configuracion_negocio;
drop policy if exists config_update_own on public.configuracion_negocio;
drop policy if exists config_delete_own on public.configuracion_negocio;

create policy config_select_own
on public.configuracion_negocio
for select
to authenticated
using (user_id = auth.uid());

create policy config_insert_own
on public.configuracion_negocio
for insert
to authenticated
with check (user_id = auth.uid());

create policy config_update_own
on public.configuracion_negocio
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy config_delete_own
on public.configuracion_negocio
for delete
to authenticated
using (user_id = auth.uid());
