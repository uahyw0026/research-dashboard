
  CREATE MATERIALIZED VIEW "RISDASH"."UAH_MV_COGR_RESEARCH_DASHBOARD" ("GRANT_CODE", "GRANT_TITLE", "PROJECT_START_DATE", "PROJECT_END_DATE", "PI", "FUND", "ORGN", "BUDGET", "EXPENSE", "ENCUMBRANCES", "AVAILABLE", "AVAILBALPECT", "MTHSREM", "AVAILTIMEPECT")
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH FORCE ON DEMAND
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE QUERY REWRITE
  AS SELECT DISTINCT
        grant_code,
        grant_title,
        project_start_date,
        project_end_date,
        pi,
        fund,
        risdash.getfundorg(fund)         AS orgn,
        budget,
        expense,
        encumbrances,
        available,
        (
            CASE
                WHEN budget = 0 THEN
                    0
                ELSE
                    ( round(available / budget, 2) * 100 )
            END
        ) availbalpect,
        round(trunc(project_end_date - sysdate) / 30, 2)               mthsrem,
        (
            CASE
                WHEN trunc(project_end_date - project_start_date) = 0 THEN
                    0
                ELSE
                    round(trunc(project_end_date - sysdate) / trunc(project_end_date - project_start_date), 2) * 100
            END
        ) availtimepect
    FROM
        (
            SELECT
                fund_trans_history.grant_code,
                fund_trans_history.grant_title,
                fund_trans_history.project_start_date,
                fund_trans_history.project_end_date,
                pi AS pi,
                fund_trans_history.fund,
                ( SUM(
                    CASE
                        WHEN ledger_ind = 'O'
                             AND field_code IN(
                            '01', '02'
                        )
                             AND document LIKE 'J%' THEN
                            amount
                        ELSE
                            0
                    END
                ) ) budget,
                ( SUM(
                    CASE
                        WHEN ledger_ind = 'O'
                             AND field_code = '03' THEN
                            amount
                        ELSE
                            0
                    END
                ) ) expense,
                ( SUM(
                    CASE
                        WHEN ledger_ind = 'O'
                             AND field_code IN(
                            '04', '05'
                        )
                             AND rucl_code <> 'E090' THEN
                            amount
                        ELSE
                            0
                    END
                ) ) encumbrances,
                ( SUM(
                    CASE
                        WHEN ledger_ind = 'O'
                             AND field_code IN(
                            '01', '02'
                        )
                             AND document LIKE 'J%' THEN
                            amount
                        ELSE
                            0
                    END
                ) --budget,
                 - SUM(
                    CASE
                        WHEN ledger_ind = 'O'
                             AND field_code = '03' THEN
                            amount
                        ELSE
                            0
                    END
                ) --expense,
                 - SUM(
                    CASE
                        WHEN ledger_ind = 'O'
                             AND field_code IN(
                            '04', '05'
                        )
                             AND rucl_code <> 'E090' THEN
                            amount
                        ELSE
                            0
                    END
                ) --encumbrances
                 ) available
            FROM
                (
                    SELECT
                        transhistory.document,
                        transhistory.ledger_ind                 AS ledger_ind,
                        transhistory.field_code                 AS field_code,
                        transhistory.fund                       AS fund,
                        transhistory.account                    AS account,
                        transhistory.rucl_code                  AS rucl_code,
                        transhistory.transaction_amount         AS amount,
                        fimsmgr.ftvacct.ftvacct_title           AS acct_title,
                        grantfund.frbgrnt_code                  AS grant_code,
                        grantfund.frbgrnt_title                 AS grant_title,
                        grantfund.frbgrnt_pi_pidm               AS pidm,
                        grantfund.frbgrnt_status_code           AS status,
                        grantfund.frbgrnt_project_start_date    AS project_start_date,
                        grantfund.frbgrnt_project_end_date      AS project_end_date,
                        grantfund.pi                            AS pi
                    FROM
                        (
                            SELECT
                                fgbtrnh_doc_code    AS document,
                                fgbtrnd_ledger_ind  AS ledger_ind,
                                fgbtrnd_field_code  AS field_code,
                                fgbtrnd_coas_code   AS chart_of_accounts,
                                fgbtrnd_fund_code   AS fund,
                                fgbtrnd_acct_code   AS account,
                                fgbtrnd_rucl_code   AS rucl_code,
                                fgbtrnd_trans_amt   AS transaction_amount
                            FROM
                                fimsmgr.fgbtrnh,
                                fimsmgr.fgbtrnd
                            WHERE
                                    fgbtrnh_coas_code = 'H' --added chart of accounts check
                                AND fgbtrnh_doc_seq_code = fgbtrnd_doc_seq_code (+)
                                AND fgbtrnh_doc_code = fgbtrnd_doc_code (+)
                                AND fgbtrnh_submission_number = fgbtrnd_submission_number (+)
                                AND fgbtrnh_item_num = fgbtrnd_item_num (+)
                                AND fgbtrnh_seq_num = fgbtrnd_seq_num (+)
                                AND fgbtrnh_serial_num = fgbtrnd_serial_num (+)
                                AND fgbtrnh_reversal_ind = fgbtrnd_reversal_ind (+)
                                AND fgbtrnd_ledger_ind = 'O' --updated to only look at operating ledger
                                AND NOT fgbtrnd_acct_code LIKE '5%'
                                AND NOT fgbtrnd_acct_code LIKE '7810%' --changed from 790%
                                AND ( fgbtrnd_fund_code BETWEEN '20000' AND '35499' )
                        ) transhistory
                        RIGHT OUTER JOIN (
                            SELECT DISTINCT
                                fimsmgr.frbgrnt.frbgrnt_code,
                                fimsmgr.ftvfund.ftvfund_fund_code,
                                fimsmgr.frbgrnt.frbgrnt_pi_pidm,
                                fimsmgr.frbgrnt.frbgrnt_title,
                                fimsmgr.frbgrnt.frbgrnt_status_code,
                                fimsmgr.frbgrnt.frbgrnt_project_start_date,
                                fimsmgr.frbgrnt.frbgrnt_project_end_date,
                                fimsmgr.ftvfund.ftvfund_nchg_date,
                                fimsmgr.ftvfund.ftvfund_coas_code,
                                nvl2(saturn.spriden.spriden_last_name, saturn.spriden.spriden_last_name
                                                                       || ', '
                                                                       || substr(saturn.spriden.spriden_first_name, 1, 1), 'NA') AS
                                                                       pi
                            FROM
                                fimsmgr.frbgrnt
                                LEFT OUTER JOIN fimsmgr.frrgrpi ON fimsmgr.frbgrnt.frbgrnt_code = fimsmgr.frrgrpi.frrgrpi_grnt_code
                                LEFT OUTER JOIN saturn.spriden ON frrgrpi.frrgrpi_id_pidm = saturn.spriden.spriden_pidm
                                INNER JOIN fimsmgr.ftvfund ON ftvfund.ftvfund_grnt_code = fimsmgr.frbgrnt.frbgrnt_code
                            WHERE
        --fimsmgr.frrgrpi.frrgrpi_id_pidm = v_pidm AND 
                                saturn.spriden.spriden_change_ind IS NULL
                                AND fimsmgr.frrgrpi.frrgrpi_id_ind = '001'
                                AND fimsmgr.frbgrnt.frbgrnt_status_code in ('A', 'C', 'L', 'CP', 'O')
                                AND fimsmgr.frbgrnt.frbgrnt_project_end_date >= sysdate - 120
                                AND ftvfund.ftvfund_nchg_date = TO_DATE('12/31/2099', 'MM/DD/YYYY')
                        ) grantfund ON transhistory.chart_of_accounts = grantfund.ftvfund_coas_code
                                       AND transhistory.fund = grantfund.ftvfund_fund_code
                        LEFT OUTER JOIN fimsmgr.ftvacct ON transhistory.chart_of_accounts = ftvacct.ftvacct_coas_code
                                                           AND transhistory.account = ftvacct.ftvacct_acct_code
                    WHERE
                        ftvacct.ftvacct_nchg_date = TO_DATE('12/31/2099', 'MM/DD/YYYY')
                ) fund_trans_history
            GROUP BY
                grant_code,
                grant_title,
                project_start_date,
                project_end_date,
                pi,
                fund
        ) rdb_data
    ;

   COMMENT ON MATERIALIZED VIEW "RISDASH"."UAH_MV_COGR_RESEARCH_DASHBOARD"  IS 'snapshot table for snapshot RISDASH.UAH_MV_COGR_RESEARCH_DASHBOARD';
