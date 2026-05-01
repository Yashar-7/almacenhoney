-- Solo si ya creaste la tabla y el trigger antes del arreglo RLS:
-- Pegá esto en SQL Editor y ejecutá (reemplaza la función del trigger).

create or replace function public.handle_new_user_perfil()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
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
