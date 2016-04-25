-- Below are some SQL scripts to do helpful things.  To run them,
-- connect to the database by running the following:
-- Production:
-- psql -h canvaslmsproduction.cgqkamtjzz6t.us-west-1.rds.amazonaws.com -p 5432 -U canvas -w -d canvas_production -f lms_postgres.sql
-- Staging:
-- psql -h canvaslmsstaging2.cgqkamtjzz6t.us-west-1.rds.amazonaws.com -p 5432 -U canvas -w -d canvas_production -f lms_postgres.sql

-- Accept all enrollments
update enrollments set workflow_state = 'active' where workflow_state = 'invited';
