-- CANDIDATE ONLY. Not in forward-manifest and not authority accepted.
BEGIN;
ALTER TABLE public.official_news_stories ADD COLUMN public_slug text;
-- Stable identity backfill for historical publications, never derived from titles.
UPDATE public.official_news_stories SET public_slug='news-'||replace(id::text,'-','')
WHERE published_at IS NOT NULL OR publication_state IN ('PUBLISHED','WITHDRAWN','SUPERSEDED');
ALTER TABLE public.official_news_stories ADD CONSTRAINT official_news_public_slug_format_ck CHECK (public_slug IS NULL OR public_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$');
ALTER TABLE public.official_news_stories ADD CONSTRAINT official_news_published_slug_ck CHECK (publication_state <> 'PUBLISHED' OR public_slug IS NOT NULL);
CREATE UNIQUE INDEX official_news_public_slug_uq ON public.official_news_stories(public_slug) WHERE public_slug IS NOT NULL;
CREATE FUNCTION public.enforce_official_news_public_slug_immutable() RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $$
BEGIN
 IF (OLD.published_at IS NOT NULL OR OLD.publication_state IN ('PUBLISHED','WITHDRAWN','SUPERSEDED')) AND NEW.public_slug IS DISTINCT FROM OLD.public_slug THEN
 RAISE EXCEPTION 'published public slug is immutable' USING ERRCODE='23514'; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER official_news_public_slug_immutable BEFORE UPDATE OF public_slug ON public.official_news_stories FOR EACH ROW EXECUTE FUNCTION public.enforce_official_news_public_slug_immutable();
CREATE FUNCTION public.assign_official_news_public_slug(target_story uuid, requested_slug text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE story public.official_news_stories%ROWTYPE; actor uuid;
BEGIN
 actor:=public.current_app_user_id();
 SELECT * INTO story FROM public.official_news_stories WHERE id=target_story FOR UPDATE;
 IF actor IS NULL OR NOT FOUND OR story.publication_state<>'DRAFT'
 OR story.correction_state<>'CURRENT' OR story.published_at IS NOT NULL
 OR NOT (
   (public.current_app_has_role(ARRAY['EDITOR']::public.user_role[])
    AND story.created_by IS NOT DISTINCT FROM actor
    AND ((story.review_state='DRAFT')
      OR (story.public_slug IS NULL AND story.risk_classification='ROUTINE' AND story.review_state='VERIFIED_BY_EDITOR')
      OR (story.public_slug IS NULL AND story.risk_classification='HIGH_RISK' AND story.review_state IN ('READY_FOR_REVIEW','CHANGES_REQUESTED'))))
   OR (story.public_slug IS NULL AND story.risk_classification='HIGH_RISK' AND story.review_state='APPROVED' AND story.approved_by IS NOT NULL
       AND public.current_app_has_role(ARRAY['MODERATOR','SUPER_ADMIN']::public.user_role[]))
 ) THEN
 RAISE EXCEPTION 'slug assignment forbidden' USING ERRCODE='42501'; END IF;
 IF requested_slug IS NULL THEN RAISE EXCEPTION 'slug required' USING ERRCODE='23514'; END IF;
 UPDATE public.official_news_stories SET public_slug=requested_slug,updated_at=now() WHERE id=target_story;
 INSERT INTO public.official_news_events(story_id,event_type,actor_id,metadata)
 VALUES(target_story,'DRAFT_UPDATED',actor,jsonb_build_object('field','public_slug','operation','ASSIGNED','old_slug',story.public_slug,'new_slug',requested_slug));
END $$;
REVOKE ALL ON FUNCTION public.assign_official_news_public_slug(uuid,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.assign_official_news_public_slug(uuid,text) TO duta_app;

-- Canonical attribution must match both the story's registry source and canonical URL.
CREATE VIEW public.official_news_public_stories WITH (security_invoker=true) AS
SELECT s.id,s.public_slug,s.display_title,s.concise_summary,s.content_type,s.published_at,s.updated_at,
s.source_published_at,s.canonical_url,canonical.original_url,
canonical.source_published_at AS original_source_published_at,o.institution AS official_source_institution,
o.channel AS official_source_channel,refs.source_references
FROM public.official_news_stories s
JOIN public.official_sources o ON o.id=s.canonical_official_source_id AND o.active AND o.source_purpose='NEWS'
JOIN LATERAL (
 SELECT r.original_url,r.source_published_at FROM public.official_news_story_source_references r
 WHERE r.story_id=s.id AND r.official_source_id=s.canonical_official_source_id AND r.canonical_url=s.canonical_url
 ORDER BY r.created_at,r.id LIMIT 1
) canonical ON true
JOIN LATERAL (
 SELECT jsonb_agg(jsonb_build_object('institution',source.institution,'channel',source.channel,
 'original_url',r.original_url,'source_published_at',r.source_published_at) ORDER BY r.created_at,r.id) AS source_references
 FROM public.official_news_story_source_references r JOIN public.official_sources source ON source.id=r.official_source_id
 WHERE r.story_id=s.id AND source.active AND source.source_purpose='NEWS'
) refs ON true
WHERE s.publication_state='PUBLISHED' AND s.correction_state='CURRENT' AND s.public_slug IS NOT NULL
AND ((s.risk_classification='ROUTINE' AND s.review_state='VERIFIED_BY_EDITOR')
OR (s.risk_classification='HIGH_RISK' AND s.review_state='APPROVED' AND s.approved_by IS NOT NULL));
REVOKE ALL ON public.official_news_public_stories FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.official_news_public_stories TO duta_app;
COMMIT;


