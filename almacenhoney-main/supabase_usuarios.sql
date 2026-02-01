-- Tabla 'usuarios' para validación de roles (PIN + rol).
-- Ejecutar en el SQL Editor de tu proyecto Supabase si aún no existe.

CREATE TABLE IF NOT EXISTS public.usuarios (
    id BIGSERIAL PRIMARY KEY,
    pin TEXT NOT NULL UNIQUE,
    rol TEXT NOT NULL CHECK (rol IN ('ADMIN', 'VENDEDOR'))
);

-- Ejemplo: insertar un admin y un vendedor (cambia los PIN por los que quieras).
-- INSERT INTO public.usuarios (pin, rol) VALUES ('180686', 'ADMIN'), ('5678', 'VENDEDOR');

-- Habilitar RLS y permitir SELECT por anon para que el frontend pueda verificar el PIN.
-- (Solo se expone la columna 'rol' al buscar por 'pin'; no guardes datos sensibles en 'pin' en producción.)
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir leer rol por pin (anon)"
ON public.usuarios FOR SELECT
TO anon
USING (true);

-- Opcional: restringir a solo poder leer (no insert/update/delete desde anon).
-- Por defecto sin políticas de INSERT/UPDATE/DELETE, anon no puede modificar la tabla.
