CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  u uuid;
BEGIN
  u := gen_random_uuid();
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', u, 'authenticated', 'authenticated', 'ana@test.com', crypt('Test1234', gen_salt('bf')), now(), '{"name":"Ana Garcia"}', now(), now());
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), u, jsonb_build_object('sub', u::text, 'email', 'ana@test.com'), 'email', 'ana@test.com', now(), now(), now());
  INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at) VALUES (u, 58, 165, 25, 1.55, 150, now());

  u := gen_random_uuid();
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', u, 'authenticated', 'authenticated', 'carlos@test.com', crypt('Test1234', gen_salt('bf')), now(), '{"name":"Carlos Ruiz"}', now(), now());
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), u, jsonb_build_object('sub', u::text, 'email', 'carlos@test.com'), 'email', 'carlos@test.com', now(), now(), now());
  INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at) VALUES (u, 82, 178, 30, 1.55, -200, now());

  u := gen_random_uuid();
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', u, 'authenticated', 'authenticated', 'maria@test.com', crypt('Test1234', gen_salt('bf')), now(), '{"name":"Maria Lopez"}', now(), now());
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), u, jsonb_build_object('sub', u::text, 'email', 'maria@test.com'), 'email', 'maria@test.com', now(), now(), now());
  INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at) VALUES (u, 62, 160, 28, 1.375, 100, now());

  u := gen_random_uuid();
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', u, 'authenticated', 'authenticated', 'pedro@test.com', crypt('Test1234', gen_salt('bf')), now(), '{"name":"Pedro Sanchez"}', now(), now());
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), u, jsonb_build_object('sub', u::text, 'email', 'pedro@test.com'), 'email', 'pedro@test.com', now(), now(), now());
  INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at) VALUES (u, 75, 175, 35, 1.2, 0, now());

  u := gen_random_uuid();
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', u, 'authenticated', 'authenticated', 'laura@test.com', crypt('Test1234', gen_salt('bf')), now(), '{"name":"Laura Martin"}', now(), now());
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), u, jsonb_build_object('sub', u::text, 'email', 'laura@test.com'), 'email', 'laura@test.com', now(), now(), now());
  INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at) VALUES (u, 55, 162, 22, 1.725, 300, now());

  u := gen_random_uuid();
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', u, 'authenticated', 'authenticated', 'diego@test.com', crypt('Test1234', gen_salt('bf')), now(), '{"name":"Diego Torres"}', now(), now());
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), u, jsonb_build_object('sub', u::text, 'email', 'diego@test.com'), 'email', 'diego@test.com', now(), now(), now());
  INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at) VALUES (u, 90, 180, 29, 1.55, -300, now());

  u := gen_random_uuid();
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', u, 'authenticated', 'authenticated', 'sara@test.com', crypt('Test1234', gen_salt('bf')), now(), '{"name":"Sara Fernandez"}', now(), now());
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), u, jsonb_build_object('sub', u::text, 'email', 'sara@test.com'), 'email', 'sara@test.com', now(), now(), now());
  INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at) VALUES (u, 60, 168, 26, 1.375, 200, now());

  u := gen_random_uuid();
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', u, 'authenticated', 'authenticated', 'javier@test.com', crypt('Test1234', gen_salt('bf')), now(), '{"name":"Javier Diaz"}', now(), now());
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), u, jsonb_build_object('sub', u::text, 'email', 'javier@test.com'), 'email', 'javier@test.com', now(), now(), now());
  INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at) VALUES (u, 78, 176, 32, 1.2, 100, now());

  u := gen_random_uuid();
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', u, 'authenticated', 'authenticated', 'elena@test.com', crypt('Test1234', gen_salt('bf')), now(), '{"name":"Elena Moreno"}', now(), now());
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), u, jsonb_build_object('sub', u::text, 'email', 'elena@test.com'), 'email', 'elena@test.com', now(), now(), now());
  INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at) VALUES (u, 65, 170, 27, 1.55, -150, now());

  u := gen_random_uuid();
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', u, 'authenticated', 'authenticated', 'pablo@test.com', crypt('Test1234', gen_salt('bf')), now(), '{"name":"Pablo Jimenez"}', now(), now());
  INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), u, jsonb_build_object('sub', u::text, 'email', 'pablo@test.com'), 'email', 'pablo@test.com', now(), now(), now());
  INSERT INTO public.settings (user_id, weight, height, age, activity, surplus, updated_at) VALUES (u, 85, 182, 33, 1.725, 250, now());

END $$;
