create or replace PROCEDURE  RISDASH.uah_p_mv_refresh AS
BEGIN
    dbms_mview.refresh('RISDash.UAH_MV_COGR_RESEARCH_DASHBOARD');
END;