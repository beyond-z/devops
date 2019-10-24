
All these queries are examples of what I did to restore user id = 1395 who we accidentally deleted:

-- RAN THIS IN A DB BACKUP to find the original preferences
SELECT "users".preferences FROM "users" WHERE "users"."id" = 1395;

UPDATE "users" SET "workflow_state" = 'registered', "deleted_at" = NULL, "preferences" = '---
:accepted_terms: 2017-09-05 17:29:58.958470268 Z
:custom_colors:
  course_29: "#629f56"
' WHERE "users"."id" = 1395;

UPDATE "communication_channels" SET "workflow_state" = 'active' WHERE "communication_channels"."user_id" = 1395;

UPDATE "pseudonyms" SET "workflow_state" = 'active', "deleted_at" = NULL WHERE "pseudonyms"."user_id" = 1395;

-- RAN THIS IN A DB BACKUP to find the account associations and copied all the values into the following insert statements
SELECT "user_account_associations".* FROM "user_account_associations" WHERE "user_account_associations"."user_id" IN (1395);

INSERT INTO user_account_associations (id, user_id, account_id, depth, created_at, updated_at) VALUES (3209,1395,3,0,'2017-09-11 21:25:40.966435','2017-09-11 21:25:40.966435');

INSERT INTO user_account_associations (id, user_id, account_id, depth, created_at, updated_at) VALUES (3014,1395,1,0,'2017-09-05 17:29:59.024996','2017-09-05 17:29:59.024996');

-- TODO: this person had no upcoming calendar events, but if they did we would have to restore those
SELECT "calendar_events".* FROM "calendar_events" WHERE "calendar_events"."context_code" = 'user_1395';

— The active enrollment was id = 3277 when running the following in a DB backup. Use that in the update below.
SELECT "enrollments".* FROM "enrollments" WHERE "enrollments"."user_id" = 1395;

UPDATE "enrollments" SET "workflow_state" = 'active' WHERE "enrollments"."type" IN ('StudentEnrollment', 'StudentViewEnrollment') AND "enrollments"."id" = 3277;
