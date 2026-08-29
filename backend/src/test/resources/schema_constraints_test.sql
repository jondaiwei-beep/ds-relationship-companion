\set ON_ERROR_STOP off
INSERT INTO users(id,email) VALUES ('11111111-1111-1111-1111-111111111111','a@x.com');
INSERT INTO users(id,email) VALUES ('22222222-2222-2222-2222-222222222222','b@x.com');
INSERT INTO dynamics(id,mode,desired_outcome,structure_level,state,reference_timezone)
 VALUES ('33333333-3333-3333-3333-333333333333','COUPLE','CLOSER','LIGHT','ACTIVE','America/New_York');
INSERT INTO relationship_events(id,actor_user_id,dynamic_id,event_type,object_ref)
 VALUES ('44444444-4444-4444-4444-444444444444','11111111-1111-1111-1111-111111111111','33333333-3333-3333-3333-333333333333','test','{"k":"v"}'::jsonb);
\echo 'T1 append-only UPDATE (expect ERROR):'
UPDATE relationship_events SET event_type='tampered' WHERE id='44444444-4444-4444-4444-444444444444';
\echo 'T2 append-only DELETE (expect ERROR):'
DELETE FROM relationship_events WHERE id='44444444-4444-4444-4444-444444444444';
\echo 'T3 duplicate active membership (expect ERROR on 2nd):'
INSERT INTO memberships(user_id,dynamic_id,role_context,access_state) VALUES ('11111111-1111-1111-1111-111111111111','33333333-3333-3333-3333-333333333333','DOMINANT','ACTIVE');
INSERT INTO memberships(user_id,dynamic_id,role_context,access_state) VALUES ('11111111-1111-1111-1111-111111111111','33333333-3333-3333-3333-333333333333','DOMINANT','ACTIVE');
\echo 'T4 duplicate pending invite (expect ERROR on 2nd):'
INSERT INTO invites(dynamic_id,inviter_user_id,intended_role_context,token_hash,expires_at,state) VALUES ('33333333-3333-3333-3333-333333333333','11111111-1111-1111-1111-111111111111','SUBMISSIVE',decode(repeat('aa',32),'hex'),now()+interval '7 days','PENDING');
INSERT INTO invites(dynamic_id,inviter_user_id,intended_role_context,token_hash,expires_at,state) VALUES ('33333333-3333-3333-3333-333333333333','11111111-1111-1111-1111-111111111111','SUBMISSIVE',decode(repeat('bb',32),'hex'),now()+interval '7 days','PENDING');
\echo 'T5 duplicate outbox dedupe_key (expect ERROR on 2nd):'
INSERT INTO outbox_records(aggregate_type,aggregate_id,event_type,payload,dedupe_key) VALUES ('occ','33333333-3333-3333-3333-333333333333','completed','{}'::jsonb,'dk-1');
INSERT INTO outbox_records(aggregate_type,aggregate_id,event_type,payload,dedupe_key) VALUES ('occ','33333333-3333-3333-3333-333333333333','completed','{}'::jsonb,'dk-1');

\echo 'T6 NEED_TO_DISCUSS must still block a duplicate occurrence (expect ERROR on 2nd):'
INSERT INTO expectation_definitions(id,dynamic_id,kind,title,creator_user_id,assignee_user_id,visibility)
 VALUES ('55555555-5555-5555-5555-555555555555','33333333-3333-3333-3333-333333333333','TASK','Prepare the evening space','11111111-1111-1111-1111-111111111111','22222222-2222-2222-2222-222222222222','SHARED');
INSERT INTO occurrences(definition_id,dynamic_id,state,relationship_day)
 VALUES ('55555555-5555-5555-5555-555555555555','33333333-3333-3333-3333-333333333333','NEED_TO_DISCUSS','2026-08-27');
INSERT INTO occurrences(definition_id,dynamic_id,state,relationship_day)
 VALUES ('55555555-5555-5555-5555-555555555555','33333333-3333-3333-3333-333333333333','SCHEDULED','2026-08-27');
