set serveroutput on
--spool &so_outfile 
BEGIN
dbms_mview.refresh('RISDash.UAH_MV_COGR_RESEARCH_DASHBOARD');
END;   
/
exit;