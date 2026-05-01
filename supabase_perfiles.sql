-- Tabla de perfiles vinculada a auth.users (ejecutar en SQL Editor de Supabase)
-- Tras crear la tabla, los usuarios NUEVOS recibirán una fila automática vía trigger.
-- Para usuarios ya existentes en auth.users, ejecutá el bloque BACKFILL al final.

create table if not exists public.perfiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  nombre_almacen text default ''::text,
  rol text not null default 'empleado',
  id_jefe uuid references auth.users (id) on delete set null
);

comment on table public.perfiles is 'Perfil de app: rol, vínculo empleado-admin, nombre de almacén.';
comment on column public.perfiles.id_jefe is 'Usuario admin dueño del negocio (empleados vinculados).';

create index if not exists perfiles_id_jefe_idx on public.perfiles (id_jefe);

alter table public.perfiles enable row level security;

-- Cada usuario autenticado solo lee su propia fila
drop policy if exists "perfiles_select_own" on public.perfiles;
create policy "perfiles_select_own"
  on public.perfiles
  for select
  to authenticated
  using (id = auth.uid());

-- Opcional: permitir que el usuario cree su fila si aún no existe (p. ej. antes del backfill)
drop policy if exists "perfiles_insert_own" on public.perfiles;
create policy "perfiles_insert_own"
  on public.perfiles
  for insert
  to authenticated
  with check (id = auth.uid());

-- Opcional: actualizar solo el propio perfil (nombre almacén, etc.)
drop policy if exists "perfiles_update_own" on public.perfiles;
create policy "perfiles_update_own"
  on public.perfiles
  for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- Trigger: nueva cuenta en auth.users → fila en perfiles
--
-- IMPORTANTE (RLS): durante este trigger NO hay sesión JWT del usuario nuevo,
-- así que auth.uid() suele ser NULL. La política INSERT "perfiles_insert_own"
-- (id = auth.uid()) falla y Auth devuelve "Database error saving new user".
-- Solución: dentro de esta función SECURITY DEFINER desactivar row_security
-- solo para el INSERT siguiente (equivale a lo que hace el dashboard de Supabase
-- en los ejemplos de "handle_new_user").
--
-- Columnas del INSERT (orden explícito, iguales a la tabla):
-- id, email, nombre_almacen, rol, id_jefe
create or replace function public.handle_new_user_perfil()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Sin esto, RLS bloquea el INSERT porque auth.uid() no está definido en el trigger.
  set local row_security = off;

  insert into public.perfiles (id, email, nombre_almacen, rol, id_jefe)
  values (
    new.id,
    coalesce(new.email::text, ''),
    ''::text,
    'empleado',
    null
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created_perfil on auth.users;
create trigger on_auth_user_created_perfil
  after insert on auth.users
  for each row
  execute procedure public.handle_new_user_perfil();

-- ========== BACKFILL (cuentas ya existentes en auth.users; seguro repetir: on conflict do nothing) ==========
insert into public.perfiles (id, email, nombre_almacen, rol)
select id, coalesce(email::text, ''), '', 'empleado'
from auth.users
on conflict (id) do nothing;
