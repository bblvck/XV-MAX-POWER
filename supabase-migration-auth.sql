-- ============================================
-- MIGRACIÓN COMPLETA: Auth + Admin + Alimentos
-- Ejecutar en SQL Editor de Supabase
-- ============================================
-- IMPORTANTE: Antes de ejecutar, ve a Supabase Dashboard → Authentication →
-- Settings → desactiva "Confirm email" para poder crear usuarios de prueba.

-- ============================================
-- PASO 1: Tabla profiles (info básica de usuario)
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text DEFAULT '',
  created_at timestamptz DEFAULT now()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles public read" ON public.profiles
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles own update" ON public.profiles
  FOR UPDATE TO authenticated USING (auth.uid() = id);

-- ============================================
-- PASO 2: Trigger auto-crear perfil al registrarse
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (new.id, COALESCE(new.raw_user_meta_data ->> 'name', ''));
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- PASO 3: Añadir user_id a tablas existentes
-- ============================================
ALTER TABLE public.foods ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.logs ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.settings ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

-- ============================================
-- PASO 4: Limpiar datos viejos (sin user_id)
-- ============================================
DELETE FROM public.foods WHERE user_id IS NULL;
DELETE FROM public.logs WHERE user_id IS NULL;
DELETE FROM public.settings WHERE user_id IS NULL;

-- ============================================
-- PASO 5: Eliminar TODAS las políticas viejas
-- ============================================
DROP POLICY IF EXISTS "public read foods" ON public.foods;
DROP POLICY IF EXISTS "public insert foods" ON public.foods;
DROP POLICY IF EXISTS "public update foods" ON public.foods;
DROP POLICY IF EXISTS "public delete foods" ON public.foods;
DROP POLICY IF EXISTS "public read logs" ON public.logs;
DROP POLICY IF EXISTS "public insert logs" ON public.logs;
DROP POLICY IF EXISTS "public update logs" ON public.logs;
DROP POLICY IF EXISTS "public delete logs" ON public.logs;
DROP POLICY IF EXISTS "public read settings" ON public.settings;
DROP POLICY IF EXISTS "public insert settings" ON public.settings;
DROP POLICY IF EXISTS "public update settings" ON public.settings;
DROP POLICY IF EXISTS "public delete settings" ON public.settings;
DROP POLICY IF EXISTS "user select foods" ON public.foods;
DROP POLICY IF EXISTS "user insert foods" ON public.foods;
DROP POLICY IF EXISTS "user update foods" ON public.foods;
DROP POLICY IF EXISTS "user delete foods" ON public.foods;
DROP POLICY IF EXISTS "user select logs" ON public.logs;
DROP POLICY IF EXISTS "user insert logs" ON public.logs;
DROP POLICY IF EXISTS "user update logs" ON public.logs;
DROP POLICY IF EXISTS "user delete logs" ON public.logs;
DROP POLICY IF EXISTS "user select settings" ON public.settings;
DROP POLICY IF EXISTS "user insert settings" ON public.settings;
DROP POLICY IF EXISTS "user update settings" ON public.settings;
DROP POLICY IF EXISTS "user delete settings" ON public.settings;

-- ============================================
-- PASO 6: Nuevas políticas (per-user + admin bypass)
-- Admin detectado via: auth.jwt() -> 'user_metadata' ->> 'role' = 'admin'
-- ============================================

-- FOODS: catálogo compartido (visible para todos los autenticados)
ALTER TABLE public.foods ENABLE ROW LEVEL SECURITY;
CREATE POLICY "foods select" ON public.foods
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "foods insert" ON public.foods
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "foods update" ON public.foods
  FOR UPDATE TO authenticated USING (auth.uid() = user_id OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');
CREATE POLICY "foods delete" ON public.foods
  FOR DELETE TO authenticated USING (auth.uid() = user_id OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- LOGS: per-user, admin ve todo
ALTER TABLE public.logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "logs select" ON public.logs
  FOR SELECT TO authenticated USING (
    auth.uid() = user_id OR
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );
CREATE POLICY "logs insert" ON public.logs
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "logs update" ON public.logs
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "logs delete" ON public.logs
  FOR DELETE TO authenticated USING (
    auth.uid() = user_id OR
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );

-- SETTINGS: per-user, admin ve todo
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "settings select" ON public.settings
  FOR SELECT TO authenticated USING (
    auth.uid() = user_id OR
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );
CREATE POLICY "settings insert" ON public.settings
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "settings update" ON public.settings
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "settings delete" ON public.settings
  FOR DELETE TO authenticated USING (
    auth.uid() = user_id OR
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );

-- ============================================
-- PASO 7: Constraints
-- ============================================
ALTER TABLE public.settings DROP CONSTRAINT IF EXISTS settings_pkey;
ALTER TABLE public.settings ADD PRIMARY KEY (user_id);

ALTER TABLE public.logs DROP CONSTRAINT IF EXISTS logs_date_key;
ALTER TABLE public.logs ADD CONSTRAINT logs_user_date_unique UNIQUE (user_id, date);

-- ============================================
-- PASO 8: Alimentos (catálogo completo)
-- ============================================
INSERT INTO public.foods (name, brand, kcal, p, f, c, icon) VALUES
  ('Almendra Cruda', 'Alipende', 612, 26, 52, 4.9, '🥜'),
  ('Arroz', 'SOS', 351, 7.3, 1.3, 77, '🍚'),
  ('Arroz Integral', 'Día', 344, 8, 2.1, 71, '🍚'),
  ('Arroz Redondo', 'Alipende', 344, 7.6, 0.9, 75.3, '🍚'),
  ('Arroz Redondo', 'Hacendado', 344, 8.2, 1, 75, '🍚'),
  ('Atún al natural', 'Alipende', 100, 23, 0.9, 0, '🐟'),
  ('Avena Integral', 'Alipende', 376, 11.8, 6.5, 62.1, '🌾'),
  ('Barbacoa Miel', 'Prima', 83, 1.5, 0, 18, '🫙'),
  ('Cacao', 'La Chocolatera', 375, 25.5, 16, 16.3, '🍫'),
  ('Cacao', 'Valor', 339, 25, 11, 17, '🍫'),
  ('Caldo de Pollo', 'Alipende', 6, 0.6, 0.4, 0, '🍲'),
  ('Caldo de Pollo', 'Día', 10, 0, 0.6, 0.5, '🍲'),
  ('Caldo de Pollo', 'Gallina Blanca', 5, 0.4, 0.3, 0.2, '🍲'),
  ('Cereales de Arroz', 'BM', 385, 9.4, 1.5, 82, '🥣'),
  ('Cereales Veganos', '', 374, 11, 3.5, 70.9, '🥣'),
  ('Chocolate 85%', 'Alipende', 541, 12.4, 38.2, 30.3, '🍫'),
  ('Claras de Huevo', 'Mercadona', 42, 11, 0.5, 0.5, '🥚'),
  ('Corn Flakes', 'Hacendado', 373, 6.7, 1.1, 82, '🥣'),
  ('Crema de cacahuete Crunchy', 'Alipende', 619, 27, 49, 15, '🥜'),
  ('Crema de Calabacin', 'Hacendado', 36, 0.3, 1, 5.5, '🥣'),
  ('Esparragos', 'Alipende', 27, 2.1, 0.6, 2.5, '🥬'),
  ('Fideos', 'BM', 344, 12, 2, 68, '🍝'),
  ('Fuet Espetec', 'Alipende', 425, 24, 35, 3.2, '🍖'),
  ('Galleta con Vainilla', 'Biscoff', 522, 3.5, 26, 67, '🍪'),
  ('Garbanzos', 'Alipende', 98, 5.4, 1.9, 12, '🫘'),
  ('Gazpacho', 'Don Simon', 37, 0.9, 2.2, 2.9, '🍲'),
  ('Gazpacho', 'Hacendado', 75, 0.9, 7, 2.5, '🍲'),
  ('Gelatina Frutos Rojos', 'Alipende', 40, 10, 0, 0, '🍮'),
  ('Guisantes', 'Alipende', 80, 5.4, 0.8, 10, '🟢'),
  ('Helado Proteico Brownie', 'Carrefour', 202, 10, 10, 18, '🍦'),
  ('Helado Sandwich de Nata 0', 'Alipende', 247, 4.3, 11.5, 33.3, '🍦'),
  ('Ketchup 0', 'Alipende', 35, 1.6, 0.1, 6.2, '🫙'),
  ('Leche', 'Alipende', 35, 3.2, 0.3, 4.9, '🥛'),
  ('Macarrón', 'Hacendado', 361, 13, 1.5, 72, '🍝'),
  ('Maiz dulce', 'Alipende', 77, 2.7, 1.8, 11, '🌽'),
  ('Mayonesa ligera', 'BM', 228, 0, 22, 7, '🫙'),
  ('Miel de flores', 'Alipende', 338, 0.3, 0, 84, '🍯'),
  ('Mostaza', 'Día', 102, 4.2, 4.1, 10.8, '🫙'),
  ('Nocilla de Pistacho', '', 554, 5, 33, 59, '🥜'),
  ('Pan de maiz', 'Alipende', 327, 10, 8.6, 49, '🍞'),
  ('Pan de molde integral', 'Alipende', 276, 11.1, 3.2, 47.5, '🍞'),
  ('Pan de molde integral', 'BM', 250, 10, 4, 40, '🍞'),
  ('Pan de molde integral grande', 'Alipende', 243, 8.7, 2.8, 42.4, '🍞'),
  ('Pan de molde Maiz', 'Alipende', 327, 10, 8.6, 49, '🍞'),
  ('Pan Masa Madre', 'Ahorramas', 242, 7.4, 0.9, 51, '🍞'),
  ('Pasta de Lentejas', 'Gallo', 347, 26, 2.5, 49, '🫘'),
  ('Pastilla de Caldo de Pollo', 'Alipende', 202, 6.6, 6.1, 30, '🍲'),
  ('Pavo sin grasa', 'Alipende', 75, 17, 0.5, 0.5, '🍖'),
  ('Quesito Light', 'Hacendado', 151, 11.5, 9, 6, '🧀'),
  ('Quesitos Light', 'Alipende', 146, 11.3, 8.6, 5.9, '🧀'),
  ('Quesitos Light', 'Dia', 156, 11.2, 10.7, 3.6, '🧀'),
  ('Queso cottage', 'Margui', 66, 12, 0.1, 4.5, '🧀'),
  ('Siracha', '', 95, 1.3, 1.7, 18, '🌶️'),
  ('Taquitos de Jamon', 'Dia', 274, 32, 16, 0.5, '🍖'),
  ('Tiburon', 'Alipende', 349, 12, 1.5, 70, '🍞'),
  ('Tomate frito', 'Alipende', 78, 1, 3.7, 9.6, '🍅'),
  ('Tomate triturado', 'Alipende', 21, 0.9, 0, 3.5, '🍅'),
  ('Tortitas de Maiz', 'Alipende', 379, 6, 2, 83, '🫓'),
  ('Tortitas de trigo', '', 379, 6, 2, 83, '🫓'),
  ('Whey Caramelo', 'Myprotein', 379, 72, 5.9, 9, '💪'),
  ('Whey Cereales', 'Myprotein', 378, 74, 6, 7.5, '💪'),
  ('Yogur griego Ligero', 'Alipende', 44, 4, 2, 2.5, '🥣'),
  ('Yogurt griego Ligero', 'Mercadona', 60, 5.8, 2, 4.7, '🥣'),
  ('Yogurt proteinas de stracciatella', 'Alipende', 64, 11.5, 0.6, 3, '🥣'),
  ('Helado de pistacho', 'Alipende', 180, 4.2, 7.1, 17.4, '🍦'),
  ('Maiz para palomitas', 'Mama · por 40g', 120, 4, 2, 10, '🌽')
ON CONFLICT DO NOTHING;

-- ============================================
-- PASO 9: Instrucciones para crear el admin
-- ============================================
-- 1. Abre la app y registra esta cuenta:
--    Email:    xvadmin@javicalorias.app
--    Password: Xv#Adm1n!7k9R
--    Nombre:   XVADMIN
--
-- 2. Después de registrar, ejecuta en SQL Editor:
UPDATE auth.users
SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || '{"role":"admin","name":"XVADMIN"}'::jsonb
WHERE email = 'xvadmin@javicalorias.app';
