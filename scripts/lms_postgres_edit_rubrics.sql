-- Below are some SQL scripts to help edit rubrics (since you can't do it through the UI if they are used in multiple courses)

-- Staging: to connect to the dabatase run: 
-- ~/scripts/lms_connect_stagingdb.bat

-- Production: to connect to the dabatase run: 
-- ~/scripts/lms_connect_proddb.bat

-- Find the rubric ID by going to the list of rubrics for the course: https://portal.bebraven.org/courses/1/rubrics
-- and clicking on the one you desire. The ID in this example is 57: https://portal.bebraven.org/courses/1/rubrics/57

-- Output the rubric data to a .csv and then copy / pasted the text to replace into commands like these:
\copy (select id, title, points_possible, data from rubrics where id = 56 limit 2) TO '~/rubric_export_cc.csv' CSV HEADER

--update rubrics set data = replace(data, '', '')  where id = 56;

--update rubrics set data = replace(data, '3.5.  Fellow roots project plan in SMART milestones.', '3.5.  Fellow roots project plan in milestones.')  where id = 57;

--update rubrics set data = replace(data, 'Includes 3+ milestones AND milestones are SMART (specific, measurable,
      ambitious, realistic, and time-bound)', 'Includes 3+ milestones AND milestones are aligned to the parts of the
      problem that must be solved to result in a successful event.')  where id = 57;
