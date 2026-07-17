-- Limpiar políticas existentes
drop policy if exists "public read foods" on public.foods;
drop policy if exists "public insert foods" on public.foods;
drop policy if exists "public update foods" on public.foods;
drop policy if exists "public delete foods" on public.foods;
drop policy if exists "public read logs" on public.logs;
drop policy if exists "public insert logs" on public.logs;
drop policy if exists "public update logs" on public.logs;
drop policy if exists "public delete logs" on public.logs;
drop policy if exists "public read settings" on public.settings;
drop policy if exists "public insert settings" on public.settings;
drop policy if exists "public update settings" on public.settings;
drop policy if exists "public delete settings" on public.settings;

-- Crear políticas fresh
create policy "public read foods" on public.foods for select to anon using (true);
create policy "public insert foods" on public.foods for insert to anon with check (true);
create policy "public update foods" on public.foods for update to anon using (true);
create policy "public delete foods" on public.foods for delete to anon using (true);

create policy "public read logs" on public.logs for select to anon using (true);
create policy "public insert logs" on public.logs for insert to anon with check (true);
create policy "public update logs" on public.logs for update to anon using (true);
create policy "public delete logs" on public.logs for delete to anon using (true);

create policy "public read settings" on public.settings for select to anon using (true);
create policy "public insert settings" on public.settings for insert to anon with check (true);
create policy "public update settings" on public.settings for update to anon using (true);
create policy "public delete settings" on public.settings for delete to anon using (true);

-- Asegurar datos iniciales
insert into public.settings (id, weight, height, age, activity, surplus)
values ('default', 56.45, 165, 26, 1.2, 150)
on conflict (id) do nothing;

insert into public.foods (name, brand, kcal, p, f, c, icon) values
  ('Avena', 'Base habitual', 389, 16.9, 6.9, 66.3, '🌾'),
  ('Pechuga de pollo', 'Por 100 g', 110, 23, 1.2, 0, '🍗'),
  ('Arroz blanco cocido', 'Por 100 g', 130, 2.7, 0.3, 28, '🍚'),
  ('Huevos', 'Unidad mediana', 78, 6.3, 5.3, 0.6, '🥚'),
  ('Yogur griego', 'Por 100 g', 97, 9, 5, 3.6, '🥣'),
  ('Plátano', 'Unidad mediana', 105, 1.3, 0.4, 27, '🍌')
on conflict do nothing;
