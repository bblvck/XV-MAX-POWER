-- Seed fictitious daily logs for all 10 test users (last 5-7 days)
-- Uses generic diet meals with realistic macros

DO $$
DECLARE
  uid uuid;
  d date;
  i int;
BEGIN
  -- Helper: iterate days from today-6 to today
  -- For each user we insert 6 days of logs with varied meals

  -- ═══════════════════════════════════════
  -- ANA (58kg, 165cm, bulk +150)
  -- ═══════════════════════════════════════
  SELECT id INTO uid FROM auth.users WHERE email='ana@test.com';
  IF uid IS NOT NULL THEN
    FOR i IN 0..5 LOOP
      d := CURRENT_DATE - (6 - i);
      INSERT INTO public.logs (user_id, date, meals) VALUES (uid, d, CASE (i % 3)
        WHEN 0 THEN '[{"name":"Desayuno","kcal":420,"p":32,"f":12,"c":48},{"name":"Comida","kcal":680,"p":48,"f":22,"c":72},{"name":"Cena","kcal":520,"p":42,"f":18,"c":44},{"name":"Snacks","kcal":180,"p":8,"f":6,"c":24},{"name":"Batido","kcal":280,"p":30,"f":4,"c":32}]'::jsonb
        WHEN 1 THEN '[{"name":"Desayuno","kcal":380,"p":28,"f":14,"c":42},{"name":"Comida","kcal":720,"p":52,"f":24,"c":68},{"name":"Cena","kcal":490,"p":38,"f":16,"c":46},{"name":"Snacks","kcal":220,"p":10,"f":8,"c":28},{"name":"Batido","kcal":260,"p":28,"f":4,"c":28}]'::jsonb
        ELSE '[{"name":"Desayuno","kcal":440,"p":30,"f":16,"c":50},{"name":"Comida","kcal":650,"p":46,"f":20,"c":70},{"name":"Cena","kcal":540,"p":40,"f":20,"c":48},{"name":"Snacks","kcal":200,"p":12,"f":6,"c":22},{"name":"Batido","kcal":300,"p":32,"f":5,"c":34}]'::jsonb
      END) ON CONFLICT (user_id, date) DO NOTHING;
    END LOOP;
  END IF;

  -- ═══════════════════════════════════════
  -- CARLOS (82kg, deficit -200)
  -- ═══════════════════════════════════════
  SELECT id INTO uid FROM auth.users WHERE email='carlos@test.com';
  IF uid IS NOT NULL THEN
    FOR i IN 0..5 LOOP
      d := CURRENT_DATE - (6 - i);
      INSERT INTO public.logs (user_id, date, meals) VALUES (uid, d, CASE (i % 3)
        WHEN 0 THEN '[{"name":"Desayuno","kcal":350,"p":30,"f":10,"c":40},{"name":"Comida","kcal":580,"p":45,"f":18,"c":55},{"name":"Cena","kcal":480,"p":40,"f":14,"c":42},{"name":"Snacks","kcal":120,"p":6,"f":4,"c":14},{"name":"Batido","kcal":250,"p":30,"f":3,"c":26}]'::jsonb
        WHEN 1 THEN '[{"name":"Desayuno","kcal":320,"p":28,"f":8,"c":38},{"name":"Comida","kcal":600,"p":48,"f":20,"c":52},{"name":"Cena","kcal":460,"p":38,"f":12,"c":40},{"name":"Snacks","kcal":140,"p":8,"f":4,"c":16},{"name":"Batido","kcal":230,"p":28,"f":3,"c":24}]'::jsonb
        ELSE '[{"name":"Desayuno","kcal":340,"p":32,"f":10,"c":36},{"name":"Comida","kcal":560,"p":42,"f":16,"c":58},{"name":"Cena","kcal":500,"p":42,"f":16,"c":44},{"name":"Snacks","kcal":130,"p":6,"f":4,"c":16},{"name":"Batido","kcal":240,"p":30,"f":3,"c":24}]'::jsonb
      END) ON CONFLICT (user_id, date) DO NOTHING;
    END LOOP;
  END IF;

  -- ═══════════════════════════════════════
  -- MARIA (62kg, moderate +100)
  -- ═══════════════════════════════════════
  SELECT id INTO uid FROM auth.users WHERE email='maria@test.com';
  IF uid IS NOT NULL THEN
    FOR i IN 0..5 LOOP
      d := CURRENT_DATE - (6 - i);
      INSERT INTO public.logs (user_id, date, meals) VALUES (uid, d, CASE (i % 3)
        WHEN 0 THEN '[{"name":"Desayuno","kcal":400,"p":26,"f":14,"c":46},{"name":"Comida","kcal":620,"p":40,"f":20,"c":65},{"name":"Cena","kcal":500,"p":36,"f":18,"c":48},{"name":"Snacks","kcal":160,"p":8,"f":6,"c":18},{"name":"Batido","kcal":240,"p":24,"f":4,"c":28}]'::jsonb
        WHEN 1 THEN '[{"name":"Desayuno","kcal":380,"p":24,"f":12,"c":44},{"name":"Comida","kcal":650,"p":42,"f":22,"c":62},{"name":"Cena","kcal":480,"p":38,"f":16,"c":44},{"name":"Snacks","kcal":180,"p":10,"f":6,"c":20},{"name":"Batido","kcal":260,"p":26,"f":4,"c":30}]'::jsonb
        ELSE '[{"name":"Desayuno","kcal":420,"p":28,"f":14,"c":48},{"name":"Comida","kcal":600,"p":38,"f":18,"c":68},{"name":"Cena","kcal":520,"p":34,"f":20,"c":50},{"name":"Snacks","kcal":150,"p":8,"f":5,"c":18},{"name":"Batido","kcal":250,"p":25,"f":4,"c":28}]'::jsonb
      END) ON CONFLICT (user_id, date) DO NOTHING;
    END LOOP;
  END IF;

  -- ═══════════════════════════════════════
  -- PEDRO (75kg, sedentary, maintenance)
  -- ═══════════════════════════════════════
  SELECT id INTO uid FROM auth.users WHERE email='pedro@test.com';
  IF uid IS NOT NULL THEN
    FOR i IN 0..5 LOOP
      d := CURRENT_DATE - (6 - i);
      INSERT INTO public.logs (user_id, date, meals) VALUES (uid, d, CASE (i % 3)
        WHEN 0 THEN '[{"name":"Desayuno","kcal":360,"p":24,"f":12,"c":42},{"name":"Comida","kcal":550,"p":36,"f":18,"c":58},{"name":"Cena","kcal":460,"p":32,"f":16,"c":44},{"name":"Snacks","kcal":160,"p":6,"f":6,"c":20},{"name":"Batido","kcal":220,"p":20,"f":4,"c":26}]'::jsonb
        WHEN 1 THEN '[{"name":"Desayuno","kcal":380,"p":26,"f":14,"c":40},{"name":"Comida","kcal":520,"p":34,"f":16,"c":56},{"name":"Cena","kcal":480,"p":34,"f":18,"c":42},{"name":"Snacks","kcal":180,"p":8,"f":6,"c":22},{"name":"Batido","kcal":200,"p":18,"f":4,"c":24}]'::jsonb
        ELSE '[{"name":"Desayuno","kcal":340,"p":22,"f":10,"c":44},{"name":"Comida","kcal":560,"p":38,"f":20,"c":54},{"name":"Cena","kcal":440,"p":30,"f":14,"c":46},{"name":"Snacks","kcal":150,"p":6,"f":5,"c":20},{"name":"Batido","kcal":230,"p":22,"f":4,"c":26}]'::jsonb
      END) ON CONFLICT (user_id, date) DO NOTHING;
    END LOOP;
  END IF;

  -- ═══════════════════════════════════════
  -- LAURA (55kg, very active, big bulk +300)
  -- ═══════════════════════════════════════
  SELECT id INTO uid FROM auth.users WHERE email='laura@test.com';
  IF uid IS NOT NULL THEN
    FOR i IN 0..5 LOOP
      d := CURRENT_DATE - (6 - i);
      INSERT INTO public.logs (user_id, date, meals) VALUES (uid, d, CASE (i % 3)
        WHEN 0 THEN '[{"name":"Desayuno","kcal":520,"p":34,"f":16,"c":60},{"name":"Comida","kcal":780,"p":52,"f":24,"c":82},{"name":"Cena","kcal":600,"p":44,"f":20,"c":55},{"name":"Snacks","kcal":250,"p":14,"f":8,"c":30},{"name":"Batido","kcal":320,"p":34,"f":6,"c":36}]'::jsonb
        WHEN 1 THEN '[{"name":"Desayuno","kcal":500,"p":32,"f":14,"c":58},{"name":"Comida","kcal":800,"p":54,"f":26,"c":78},{"name":"Cena","kcal":580,"p":42,"f":18,"c":56},{"name":"Snacks","kcal":270,"p":16,"f":8,"c":32},{"name":"Batido","kcal":300,"p":32,"f":5,"c":34}]'::jsonb
        ELSE '[{"name":"Desayuno","kcal":540,"p":36,"f":18,"c":58},{"name":"Comida","kcal":760,"p":50,"f":22,"c":84},{"name":"Cena","kcal":620,"p":46,"f":22,"c":52},{"name":"Snacks","kcal":240,"p":12,"f":8,"c":28},{"name":"Batido","kcal":340,"p":36,"f":6,"c":38}]'::jsonb
      END) ON CONFLICT (user_id, date) DO NOTHING;
    END LOOP;
  END IF;

  -- ═══════════════════════════════════════
  -- DIEGO (90kg, deficit -300, cut)
  -- ═══════════════════════════════════════
  SELECT id INTO uid FROM auth.users WHERE email='diego@test.com';
  IF uid IS NOT NULL THEN
    FOR i IN 0..5 LOOP
      d := CURRENT_DATE - (6 - i);
      INSERT INTO public.logs (user_id, date, meals) VALUES (uid, d, CASE (i % 3)
        WHEN 0 THEN '[{"name":"Desayuno","kcal":320,"p":28,"f":8,"c":38},{"name":"Comida","kcal":520,"p":42,"f":14,"c":50},{"name":"Cena","kcal":440,"p":38,"f":12,"c":38},{"name":"Snacks","kcal":100,"p":6,"f":2,"c":14},{"name":"Batido","kcal":220,"p":28,"f":2,"c":22}]'::jsonb
        WHEN 1 THEN '[{"name":"Desayuno","kcal":300,"p":26,"f":8,"c":34},{"name":"Comida","kcal":540,"p":44,"f":16,"c":48},{"name":"Cena","kcal":460,"p":40,"f":14,"c":36},{"name":"Snacks","kcal":120,"p":8,"f":2,"c":16},{"name":"Batido","kcal":200,"p":26,"f":2,"c":20}]'::jsonb
        ELSE '[{"name":"Desayuno","kcal":340,"p":30,"f":10,"c":36},{"name":"Comida","kcal":500,"p":40,"f":12,"c":52},{"name":"Cena","kcal":450,"p":36,"f":14,"c":40},{"name":"Snacks","kcal":110,"p":6,"f":2,"c":14},{"name":"Batido","kcal":230,"p":30,"f":2,"c":24}]'::jsonb
      END) ON CONFLICT (user_id, date) DO NOTHING;
    END LOOP;
  END IF;

  -- ═══════════════════════════════════════
  -- SARA (60kg, moderate +200)
  -- ═══════════════════════════════════════
  SELECT id INTO uid FROM auth.users WHERE email='sara@test.com';
  IF uid IS NOT NULL THEN
    FOR i IN 0..5 LOOP
      d := CURRENT_DATE - (6 - i);
      INSERT INTO public.logs (user_id, date, meals) VALUES (uid, d, CASE (i % 3)
        WHEN 0 THEN '[{"name":"Desayuno","kcal":430,"p":28,"f":14,"c":50},{"name":"Comida","kcal":660,"p":44,"f":22,"c":68},{"name":"Cena","kcal":530,"p":40,"f":18,"c":48},{"name":"Snacks","kcal":200,"p":10,"f":6,"c":24},{"name":"Batido","kcal":280,"p":30,"f":4,"c":30}]'::jsonb
        WHEN 1 THEN '[{"name":"Desayuno","kcal":400,"p":26,"f":12,"c":48},{"name":"Comida","kcal":680,"p":46,"f":24,"c":64},{"name":"Cena","kcal":510,"p":38,"f":16,"c":50},{"name":"Snacks","kcal":210,"p":12,"f":6,"c":26},{"name":"Batido","kcal":260,"p":28,"f":4,"c":28}]'::jsonb
        ELSE '[{"name":"Desayuno","kcal":420,"p":30,"f":14,"c":48},{"name":"Comida","kcal":640,"p":42,"f":20,"c":70},{"name":"Cena","kcal":550,"p":42,"f":20,"c":46},{"name":"Snacks","kcal":190,"p":10,"f":5,"c":24},{"name":"Batido","kcal":270,"p":28,"f":4,"c":32}]'::jsonb
      END) ON CONFLICT (user_id, date) DO NOTHING;
    END LOOP;
  END IF;

  -- ═══════════════════════════════════════
  -- JAVIER (78kg, sedentary, small bulk +100)
  -- ═══════════════════════════════════════
  SELECT id INTO uid FROM auth.users WHERE email='javier@test.com';
  IF uid IS NOT NULL THEN
    FOR i IN 0..5 LOOP
      d := CURRENT_DATE - (6 - i);
      INSERT INTO public.logs (user_id, date, meals) VALUES (uid, d, CASE (i % 3)
        WHEN 0 THEN '[{"name":"Desayuno","kcal":380,"p":26,"f":12,"c":44},{"name":"Comida","kcal":580,"p":40,"f":18,"c":58},{"name":"Cena","kcal":480,"p":36,"f":16,"c":44},{"name":"Snacks","kcal":170,"p":8,"f":6,"c":20},{"name":"Batido","kcal":260,"p":28,"f":4,"c":28}]'::jsonb
        WHEN 1 THEN '[{"name":"Desayuno","kcal":360,"p":24,"f":10,"c":42},{"name":"Comida","kcal":600,"p":42,"f":20,"c":56},{"name":"Cena","kcal":500,"p":38,"f":18,"c":42},{"name":"Snacks","kcal":180,"p":10,"f":6,"c":22},{"name":"Batido","kcal":240,"p":26,"f":4,"c":26}]'::jsonb
        ELSE '[{"name":"Desayuno","kcal":400,"p":28,"f":14,"c":44},{"name":"Comida","kcal":560,"p":38,"f":16,"c":60},{"name":"Cena","kcal":490,"p":34,"f":14,"c":46},{"name":"Snacks","kcal":160,"p":8,"f":5,"c":20},{"name":"Batido","kcal":270,"p":30,"f":4,"c":28}]'::jsonb
      END) ON CONFLICT (user_id, date) DO NOTHING;
    END LOOP;
  END IF;

  -- ═══════════════════════════════════════
  -- ELENA (65kg, moderate deficit -150)
  -- ═══════════════════════════════════════
  SELECT id INTO uid FROM auth.users WHERE email='elena@test.com';
  IF uid IS NOT NULL THEN
    FOR i IN 0..5 LOOP
      d := CURRENT_DATE - (6 - i);
      INSERT INTO public.logs (user_id, date, meals) VALUES (uid, d, CASE (i % 3)
        WHEN 0 THEN '[{"name":"Desayuno","kcal":350,"p":26,"f":10,"c":40},{"name":"Comida","kcal":560,"p":40,"f":16,"c":56},{"name":"Cena","kcal":470,"p":36,"f":14,"c":44},{"name":"Snacks","kcal":140,"p":8,"f":4,"c":16},{"name":"Batido","kcal":240,"p":26,"f":4,"c":26}]'::jsonb
        WHEN 1 THEN '[{"name":"Desayuno","kcal":330,"p":24,"f":8,"c":38},{"name":"Comida","kcal":580,"p":42,"f":18,"c":54},{"name":"Cena","kcal":490,"p":38,"f":16,"c":42},{"name":"Snacks","kcal":160,"p":10,"f":4,"c":18},{"name":"Batido","kcal":220,"p":24,"f":3,"c":24}]'::jsonb
        ELSE '[{"name":"Desayuno","kcal":360,"p":28,"f":10,"c":40},{"name":"Comida","kcal":540,"p":38,"f":14,"c":58},{"name":"Cena","kcal":480,"p":34,"f":16,"c":46},{"name":"Snacks","kcal":150,"p":8,"f":4,"c":18},{"name":"Batido","kcal":250,"p":28,"f":4,"c":26}]'::jsonb
      END) ON CONFLICT (user_id, date) DO NOTHING;
    END LOOP;
  END IF;

  -- ═══════════════════════════════════════
  -- PABLO (85kg, very active, big bulk +250)
  -- ═══════════════════════════════════════
  SELECT id INTO uid FROM auth.users WHERE email='pablo@test.com';
  IF uid IS NOT NULL THEN
    FOR i IN 0..5 LOOP
      d := CURRENT_DATE - (6 - i);
      INSERT INTO public.logs (user_id, date, meals) VALUES (uid, d, CASE (i % 3)
        WHEN 0 THEN '[{"name":"Desayuno","kcal":500,"p":36,"f":14,"c":58},{"name":"Comida","kcal":750,"p":54,"f":22,"c":78},{"name":"Cena","kcal":620,"p":48,"f":20,"c":56},{"name":"Snacks","kcal":260,"p":14,"f":8,"c":30},{"name":"Batido","kcal":340,"p":36,"f":6,"c":38}]'::jsonb
        WHEN 1 THEN '[{"name":"Desayuno","kcal":480,"p":34,"f":12,"c":56},{"name":"Comida","kcal":770,"p":56,"f":24,"c":74},{"name":"Cena","kcal":600,"p":46,"f":18,"c":58},{"name":"Snacks","kcal":280,"p":16,"f":8,"c":34},{"name":"Batido","kcal":320,"p":34,"f":5,"c":36}]'::jsonb
        ELSE '[{"name":"Desayuno","kcal":520,"p":38,"f":16,"c":58},{"name":"Comida","kcal":740,"p":52,"f":20,"c":80},{"name":"Cena","kcal":640,"p":50,"f":22,"c":54},{"name":"Snacks","kcal":250,"p":12,"f":8,"c":28},{"name":"Batido","kcal":350,"p":38,"f":6,"c":40}]'::jsonb
      END) ON CONFLICT (user_id, date) DO NOTHING;
    END LOOP;
  END IF;

END $$;
