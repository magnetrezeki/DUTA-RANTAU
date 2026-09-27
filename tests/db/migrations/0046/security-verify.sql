-- 0046 security poststate: public access remains restricted to duta_app.
SELECT NOT has_table_privilege('anon','public.official_news_public_stories','SELECT') AS anon_projection_denied;
SELECT NOT has_table_privilege('authenticated','public.official_news_public_stories','SELECT') AS authenticated_projection_denied;
SELECT has_function_privilege('duta_app','public.assign_official_news_public_slug(uuid,text)','EXECUTE') AS duta_app_assignment_allowed;
