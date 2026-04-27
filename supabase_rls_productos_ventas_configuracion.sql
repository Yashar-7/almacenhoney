-- RLS unificado para productos, ventas y configuración de negocio.
-- Ejecutar este script en Supabase SQL Editor.

-- =========================
-- 1) PRODUCTOS
-- =========================
alter table if exists public.productos_almacen
  add column if not exists user_id uuid references auth.users(id) on delete cascade;

alter table if exists public.productos_almacen
  alter column user_id set default auth.uid();

alter table if exists public.productos_almacen
  enable row level security;

drop policy if exists productos_select_own on public.productos_almacen;
drop policy if exists productos_insert_own on public.productos_almacen;
drop policy if exists productos_update_own on public.productos_almacen;
drop policy if exists productos_delete_own on public.productos_almacen;

create policy productos_select_own
on public.productos_almacen
for select
to authenticated
using (auth.uid() = user_id);

create policy productos_insert_own
on public.productos_almacen
for insert
to authenticated
with check (auth.uid() = user_id);

create policy productos_update_own
on public.productos_almacen
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy productos_delete_own
on public.productos_almacen
for delete
to authenticated
using (auth.uid() = user_id);


-- =========================
-- 2) VENTAS
-- =========================
alter table if exists public.ventas_honey
  add column if not exists user_id uuid references auth.users(id) on delete cascade;

alter table if exists public.ventas_honey
  alter column user_id set default auth.uid();

alter table if exists public.ventas_honey
  enable row level security;

drop policy if exists ventas_select_own on public.ventas_honey;
drop policy if exists ventas_insert_own on public.ventas_honey;
drop policy if exists ventas_update_own on public.ventas_honey;
drop policy if exists ventas_delete_own on public.ventas_honey;

create policy ventas_select_own
on public.ventas_honey
for select
to authenticated
using (auth.uid() = user_id);

create policy ventas_insert_own
on public.ventas_honey
for insert
to authenticated
with check (auth.uid() = user_id);

create policy ventas_update_own
on public.ventas_honey
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy ventas_delete_own
on public.ventas_honey
for delete
to authenticated
using (auth.uid() = user_id);


-- =========================
-- 3) CONFIGURACION
-- =========================
create table if not exists public.configuracion_negocio (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nombre_comercio text not null default 'Tu Almacén',
  logo_url text
);

alter table if exists public.configuracion_negocio
  add column if not exists user_id uuid references auth.users(id) on delete cascade;

alter table if exists public.configuracion_negocio
  add column if not exists nombre_comercio text not null default 'Tu Almacén';

alter table if exists public.configuracion_negocio
  add column if not exists logo_url text;

alter table if exists public.configuracion_negocio
  alter column user_id set default auth.uid();

alter table if exists public.configuracion_negocio
  enable row level security;

drop policy if exists config_select_own on public.configuracion_negocio;
drop policy if exists config_insert_own on public.configuracion_negocio;
drop policy if exists config_update_own on public.configuracion_negocio;
drop policy if exists config_delete_own on public.configuracion_negocio;

create policy config_select_own
on public.configuracion_negocio
for select
to authenticated
using (auth.uid() = user_id);

create policy config_insert_own
on public.configuracion_negocio
for insert
to authenticated
with check (auth.uid() = user_id);

create policy config_update_own
on public.configuracion_negocio
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy config_delete_own
on public.configuracion_negocio
for delete
to authenticated
using (auth.uid() = user_id);
