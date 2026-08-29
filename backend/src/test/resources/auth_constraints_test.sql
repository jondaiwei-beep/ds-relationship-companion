\set ON_ERROR_STOP off
INSERT INTO users(id,email) VALUES ('99999999-9999-9999-9999-999999999999','auth@x.com');
INSERT INTO magic_link_tokens(id,flow_id,normalized_email,token_hash,verifier_hash,state,expires_at)
 VALUES ('aaaaaaaa-0000-0000-0000-000000000001','bbbbbbbb-0000-0000-0000-000000000001','a@x.com',
         decode(repeat('11',32),'hex'),decode(repeat('22',32),'hex'),'PENDING',now()+interval '10 min');

\echo 'V2-T1 duplicate token_hash must be rejected:'
INSERT INTO magic_link_tokens(id,flow_id,normalized_email,token_hash,verifier_hash,state,expires_at)
 VALUES ('aaaaaaaa-0000-0000-0000-000000000002','bbbbbbbb-0000-0000-0000-000000000002','a@x.com',
         decode(repeat('11',32),'hex'),decode(repeat('33',32),'hex'),'PENDING',now()+interval '10 min');

\echo 'V2-T2 single-use: guarded consume succeeds once, second finds no row:'
UPDATE magic_link_tokens SET state='CONSUMED', consumed_at=now()
 WHERE id='aaaaaaaa-0000-0000-0000-000000000001' AND state='PENDING' AND expires_at > clock_timestamp();
UPDATE magic_link_tokens SET state='CONSUMED', consumed_at=now()
 WHERE id='aaaaaaaa-0000-0000-0000-000000000001' AND state='PENDING' AND expires_at > clock_timestamp();

\echo 'V2-T3 only one ACTIVE refresh token per session:'
INSERT INTO auth_sessions(id,user_id,client_type,csrf_token_hash,idle_expires_at,absolute_expires_at)
 VALUES ('cccccccc-0000-0000-0000-000000000001','99999999-9999-9999-9999-999999999999','WEB',
         decode(repeat('44',32),'hex'),now()+interval '7 days',now()+interval '30 days');
INSERT INTO refresh_tokens(id,session_id,token_hash,state,expires_at)
 VALUES ('dddddddd-0000-0000-0000-000000000001','cccccccc-0000-0000-0000-000000000001',decode(repeat('55',32),'hex'),'ACTIVE',now()+interval '7 days');
INSERT INTO refresh_tokens(id,session_id,token_hash,state,expires_at)
 VALUES ('dddddddd-0000-0000-0000-000000000002','cccccccc-0000-0000-0000-000000000001',decode(repeat('66',32),'hex'),'ACTIVE',now()+interval '7 days');
