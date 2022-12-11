------------------------------------------------------------------------------------------
-- job for refreshing materialized view RISDASH.UAH_MV_COGR_RESEARCH_DASHBOARD ----
------------------------------------------------------------------------------------------
--- Create Job
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'RISDASH_Job_MV_Refresh',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'RISDASH.uah_p_mv_refresh',
   auto_drop          =>   FALSE,
   comments           =>  'job for refreshing materialized view RISDASH.UAH_MV_COGR_RESEARCH_DASHBOARD four times daily');
END;
/

--- add job schedule
BEGIN
  DBMS_SCHEDULER.SET_ATTRIBUTE (
   name         =>  'RISDASH_Job_MV_Refresh',
   attribute    =>  'repeat_interval',
   value        =>  'FREQ=HOURLY; INTERVAL=6');
END;
/

--- add start date and end date for testing purpose.
--- this section can be skip for prod migration
BEGIN
  DBMS_SCHEDULER.SET_ATTRIBUTE (
   name         =>  'RISDASH_Job_MV_Refresh',
   attribute    =>  'start_date',
   value        =>  '18-NOV-20 06.00.00 AM America/Chicago');
END;
/

BEGIN
  DBMS_SCHEDULER.SET_ATTRIBUTE (
   name         =>  'RISDASH_Job_MV_Refresh',
   attribute    =>  'end_date',
   value        =>  '31-DEC-20 06.00.00 AM America/Chicago');
END;
/

--- start scheduled job
BEGIN
 DBMS_SCHEDULER.ENABLE ('RISDASH_Job_MV_Refresh');
END;
/

--- stop job manually

BEGIN
 DBMS_SCHEDULER.DISABLE ('RISDASH_Job_MV_Refresh');
END;
/

--- immediatly start job maunally
BEGIN
  DBMS_SCHEDULER.RUN_JOB(
    JOB_NAME            => 'RISDASH_Job_MV_Refresh',
    USE_CURRENT_SESSION => FALSE);
END;
/

commit;
