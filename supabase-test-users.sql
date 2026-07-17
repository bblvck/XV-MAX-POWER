-- ============================================
-- 10 CUENTAS DE PRUEBA
-- Ejecutar en SQL Editor de Supabase
-- ============================================
-- Todas usan la contraseña: Test1234
-- Ejecutar DESPUÉS del migration de auth

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  u RECORD;
  users_data TEXT[][] := ARRAY[
    ARRAY['Ana García',      'ana@test.com',      '58',  '165', '25', '1.55'],
    ARRAY['Carlos Ruiz',     'carlos@test.com',   '82',  '178', '30', '1.55'],
    ARRAY['María López',     'maria@test.com',    '62',  '160', '28', '1.375'],
    ARRAY['Pedro Sánchez',   'pedro@test.com',    '75',  '175', '35', '1.2'],
    ARRAY['Laura Martín',    'laura@test.com',    '55',  '162', '22', '1.725'],
    ARRAY['Diego Torres',    'diego@test.com',    '90',  '180', '29', '1.55'],
    ARRAY['Sara Fernández',  'sara@test.com',     '60',  '168', '26', '1.375'],
    ARRAY['Javier Díaz',     'javier@test.com',   '78',  '176', '32', '1.2'],
    ARRAY['Elena Moreno',    'elena@test.com',    '65',  '170', '27', '1.55'],
    ARRAY['Pablo Jiménez',   'pablo@test.com',    '85',  '182', '33', '1.725']
  ];
  uid uuid;
BEGIN
  FOREACH u SLICE 0 IN ARRAY users_data LOOP
    uid := gen_random_uuid();

    -- Insertar en auth.users
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, raw_user_meta_data, created_at, updated_at
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      uid,
      'authenticated',
      'authenticated',
      u[2],
      crypt('Test1234', gen_salt('bf')),
      now(),
      jsonb_build_object('name', u[1]),
      now(),
      now()
    );

    -- Insertar identidad
    INSERT INTO auth.identities (
      id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    ) VALUES (
      gen_random_uuid(),
      uid,
      jsonb_build_object('sub', uid::text, 'email', u[2]),
      'email',
      now(),
      now(),
      now()
    );

    -- Crear settings con datos realistas
    INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at)
    VALUES (
      uid,
      u[3]::numeric,
      u[4]::int,
      u[5]::int,
      u[6]::numeric,
      CASE (random()*2)::int
        WHEN 0 THEN -200
        WHEN 1 THEN 150
        ELSE 300
      END,
      now()
    )
    ON CONFLICT (user_id) DO NOTHING;

    RAISE NOTICE 'Creado: % (%)', u[1], u[2];
  END LOOP;
END $$;
