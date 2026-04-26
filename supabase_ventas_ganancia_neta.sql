alter table public.ventas_honey
add column if not exists ganancia_neta numeric(12,2) default 0;
