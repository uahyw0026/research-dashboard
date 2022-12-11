  CREATE OR REPLACE PACKAGE "RISDASH"."UAH_K_COGR_RESEARCH_DASHBOARD" 
AS
    /******************************************************************************
       NAME:       RISDASH.uah_K_COGR_RESEARCH_DASHBOARD
       PURPOSE:    This package is used to retrieved grant and transaction details for
                    PI, CO-PI, Departmennt admin, Dean Users, and administrators.
       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        2/27/2020   yan wang       1. Created this package.
    ******************************************************************************/
    PROCEDURE uah_p_cogr_rdb_awards (v_pidm     IN     VARCHAR2,
                                     v_view     IN     VARCHAR2,
                                     v_org      IN     VARCHAR2,
                                     v_source   IN     VARCHAR2,
                                     p_awards      OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_awd_ends (v_pidm         IN     VARCHAR2,
                                       v_view         IN     VARCHAR2,
                                       v_org          IN     VARCHAR2,
                                       p_award_ends      OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_awd_details (
        v_pidm            IN     VARCHAR2,
        v_fundid          IN     VARCHAR2,
        v_source          IN     VARCHAR2,
        p_award_details      OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_acct_trans (
        v_pidm                   IN     VARCHAR2,
        v_fundid                 IN     VARCHAR2,
        v_acctid                 IN     VARCHAR2,
        v_trans_type             IN     VARCHAR2,
        v_source                 IN     VARCHAR2,
        p_account_transactions      OUT SYS_REFCURSOR);
    
    PROCEDURE uah_p_cogr_rdb_acct_payroll (
        v_fundid            IN     VARCHAR2,
        v_acctid            IN     VARCHAR2,
        v_doc               IN     VARCHAR2 DEFAULT '',
        v_trans_type        IN     VARCHAR2,
        v_source            IN     VARCHAR2,
        p_account_payroll      OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_user_auth (v_mybamaid    IN     VARCHAR2,
                                        p_user_data      OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_payroll (v_doc_code   IN     VARCHAR2,
                                      v_fundid     IN     VARCHAR2,
                                      v_acctid     IN     VARCHAR2,
                                      v_source     IN     VARCHAR2,
                                      p_payroll       OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_orgnization (v_pidm   IN     VARCHAR2,
                                          p_orgs      OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_getDeans (p_deans OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_dean_check (v_cwid        IN     VARCHAR2,
                                         p_user_data      OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_insert_deanOrg (v_pidm     IN     VARCHAR2,
                                             v_org      IN     VARCHAR2,
                                             p_result      OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_expire_deanOrg (v_pidm     IN     VARCHAR2,
                                             v_org      IN     VARCHAR2,
                                             p_result      OUT SYS_REFCURSOR);

    PROCEDURE uah_p_cogr_rdb_copy_deanOrg (
        v_source_pidm   IN     VARCHAR2,
        v_dest_pidm     IN     VARCHAR2,
        p_result           OUT SYS_REFCURSOR);

    -- PROCEDURE uah_p_cogr_rdb_note_policies
    -- (
    --  v_creator IN varchar2,
    --  p_note_policies OUT SYS_REFCURSOR
    -- );
    FUNCTION f_format_name (pidm NUMBER, name_type VARCHAR2)
        RETURN VARCHAR2;
    FUNCTION getfundorg (
        v_fundcode IN fimsmgr.ftvorgn.ftvorgn_fund_code_def%TYPE
    ) RETURN fimsmgr.ftvorgn.ftvorgn_orgn_code%TYPE;
END uah_k_cogr_research_dashboard;

/

CREATE OR REPLACE PACKAGE BODY "RISDASH"."UAH_K_COGR_RESEARCH_DASHBOARD" AS
/******************************************************************************
   NAME:       RISDASH.uah_K_COGR_RESEARCH_DASHBOARD
   PURPOSE:    This package is used to retrieved grant and transaction details for
                PI, CO-PI, Departmennt admin, Dean Users, and administrators.
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        1/15/2020   yan wang       1. Created this package.
******************************************************************************/


-- need implementation for Admin and Dept Admin
    PROCEDURE uah_p_cogr_rdb_awards (
        v_pidm    IN   VARCHAR2,
        v_view    IN   VARCHAR2,
        v_org     IN   VARCHAR2,
        v_source  IN   VARCHAR2,
        p_awards  OUT  SYS_REFCURSOR
    ) IS

        admin_count         NUMBER := 0;
        c_no_rdb_account    CHAR(2) := '5%';
        c_no_rdb_document   CHAR(2) := 'A%';
        c_rdb_document      CHAR(2) := 'J%';
        c_rdb_fund          CHAR(2) := '2%';
        c_pi_role           CHAR(3) := '001';
        c_copi_role         CHAR(3) := '002';
        c_admin_role        CHAR(3) := '003';
        c_dept_admin_role   CHAR(3) := '006';
        c_letter_a          CHAR(1) := 'A';
        c_letter_o          CHAR(1) := 'O';
        c_letter_e          CHAR(1) := 'E';
        c_number_one        CHAR(2) := '01';
        c_number_two        CHAR(2) := '02';
        c_number_six        CHAR(2) := '06';
        c_number_three      CHAR(2) := '03';
        c_name_format       VARCHAR(20) := 'LFIMI30';
        c_realtime_data     CHAR(1) := '1';
        c_materializedview  CHAR(1) := '2';
        c_schooldata        CHAR(1) := '2';
        c_active_date       DATE := TO_DATE('12/31/2099', 'MM/DD/YYYY');
    --c_like_sign char(1) := '%';
    BEGIN
        SELECT
            COUNT(*)
        INTO admin_count
        FROM
            risdash.rdborgnmap
        WHERE
                rdborgnmap_pidm = v_pidm
            AND rdborgnmap_orgn_code = 'RDBADM'
            AND rdborgnmap_nchg_date = TO_DATE('12/31/2099', 'mm/dd/yyyy');

        IF admin_count > 0 AND v_view = c_schooldata THEN  -- retrives all grants for admin for school view
            BEGIN
                OPEN p_awards FOR SELECT DISTINCT
                      rdb_funds.grant_code,
                      rdb_funds.grant_title,
                      rdb_funds.project_start_date,
                      rdb_funds.project_end_date,
                      rdb_funds.pi,
                      rdb_funds.fund,
                      rdb_funds.orgn,
                      rdb_funds.budget,
                      rdb_funds.expense,
                      rdb_funds.encumbrances,
                      rdb_funds.available,
                      rdb_funds.availbalpect,
                      rdb_funds.mthsrem,
                      rdb_funds.availtimepect
                  FROM
                      risdash.uah_mv_cogr_research_dashboard rdb_funds
                  ORDER BY
                      rdb_funds.orgn,
                      rdb_funds.fund;
            END;
        ELSE
            BEGIN
                IF v_source = c_materializedview THEN
        -- change matialized view to include project start date and project end date
        -- also add orgnization code for grant and funds
                    BEGIN
                        IF v_view = c_schooldata THEN
                            BEGIN
                               OPEN p_awards FOR SELECT DISTINCT
                                  rdb_funds.grant_code,
                                  rdb_funds.grant_title,
                                  rdb_funds.project_start_date,
                                  rdb_funds.project_end_date,
                                  rdb_funds.pi,
                                  rdb_funds.fund,
                                  rdb_funds.orgn,
                                  rdb_funds.budget,
                                  rdb_funds.expense,
                                  rdb_funds.encumbrances,
                                  rdb_funds.available,
                                  rdb_funds.availbalpect,
                                  rdb_funds.mthsrem,
                                  rdb_funds.availtimepect
                              FROM
                                       risdash.uah_mv_cogr_research_dashboard rdb_funds
                                  INNER JOIN (
                                      SELECT DISTINCT
                                          fimsmgr.frbgrnt.frbgrnt_code                    AS grantcode,
                                          fimsmgr.ftvfund.ftvfund_fund_code               AS fundcode,
                                          fund_org.ftvorgn_orgn_code,
                                          fimsmgr.frbgrnt.frbgrnt_pi_pidm,
                                          fimsmgr.frbgrnt.frbgrnt_title,
                                          fimsmgr.frbgrnt.frbgrnt_status_code,
                                          fimsmgr.frbgrnt.frbgrnt_project_start_date      AS projectstartdate,
                                          fimsmgr.frbgrnt.frbgrnt_project_end_date        AS projectenddate,
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
                                          INNER JOIN (
                                              SELECT DISTINCT
                                                  ftvorgn_coas_code,
                                                  ftvorgn_orgn_code,
                                                  ftvorgn_fund_code_def,
                                                  MAX(ftvorgn_eff_date) OVER(PARTITION BY ftvorgn_coas_code, ftvorgn_orgn_code, ftvorgn_fund_code_def)
                                                  AS "latest_eff_date"
                                              FROM
                                                  fimsmgr.ftvorgn
                                              WHERE
                                                  ftvorgn_nchg_date IS NOT NULL
                                                  AND ftvorgn_eff_date IS NOT NULL
                                                  AND ftvorgn_orgn_code IS NOT NULL
                                          ) fund_org ON fimsmgr.ftvfund.ftvfund_fund_code = fund_org.ftvorgn_fund_code_def
                                          INNER JOIN risdash.rdborgnmap ON substr(fund_org.ftvorgn_orgn_code, 1, length(rdborgnmap.rdborgnmap_orgn_code)) =
                                          rdborgnmap.rdborgnmap_orgn_code
                                      WHERE
                                              rdborgnmap.rdborgnmap_pidm = v_pidm --25096941 sample user
                                          AND rdborgnmap.rdborgnmap_nchg_date = TO_DATE('12/31/2099', 'mm/dd/yyyy')
                                          AND saturn.spriden.spriden_change_ind IS NULL
                                          AND fimsmgr.frbgrnt.frbgrnt_status_code in ('A', 'C', 'L', 'CP', 'O')
                                          AND fimsmgr.frbgrnt.frbgrnt_project_end_date >= sysdate - 120
                                          AND ftvfund.ftvfund_nchg_date = TO_DATE('12/31/2099', 'MM/DD/YYYY')
                                  ) grantinfo ON rdb_funds.grant_code = grantinfo.grantcode
                                                 AND rdb_funds.fund = grantinfo.fundcode
                              ORDER BY
                                  rdb_funds.orgn,
                                  rdb_funds.fund;
                            END;

                        ELSE
                            BEGIN
                                OPEN p_awards for SELECT DISTINCT
                                  rdb_funds.grant_code,
                                  rdb_funds.grant_title,
                                  rdb_funds.project_start_date,
                                  rdb_funds.project_end_date,
                                  rdb_funds.pi,
                                  rdb_funds.fund,
                                  rdb_funds.orgn,
                                  rdb_funds.budget,
                                  rdb_funds.expense,
                                  rdb_funds.encumbrances,
                                  rdb_funds.available,
                                  rdb_funds.availbalpect,
                                  rdb_funds.mthsrem,
                                  rdb_funds.availtimepect
                              FROM
                                       risdash.uah_mv_cogr_research_dashboard rdb_funds
                                  INNER JOIN (
                                      SELECT DISTINCT
                                          fimsmgr.frbgrnt.frbgrnt_code                    AS grantcode,
                                          fimsmgr.ftvfund.ftvfund_fund_code               AS fundcode,
                                          fimsmgr.frbgrnt.frbgrnt_project_start_date      AS projectstartdate,
                                          fimsmgr.frbgrnt.frbgrnt_project_end_date        AS projectenddate
                                      FROM
                                          fimsmgr.frbgrnt
                                          LEFT OUTER JOIN fimsmgr.frrgrpi ON fimsmgr.frbgrnt.frbgrnt_code = fimsmgr.frrgrpi.frrgrpi_grnt_code
                                          INNER JOIN fimsmgr.ftvfund ON ftvfund.ftvfund_grnt_code = fimsmgr.frbgrnt.frbgrnt_code
                                      WHERE
                                              fimsmgr.frrgrpi.frrgrpi_id_pidm = v_pidm
                                          AND fimsmgr.frrgrpi.frrgrpi_id_ind IN (
                                              c_pi_role,
                                              c_copi_role,
                                              c_dept_admin_role
                                          )
                                              AND fimsmgr.frbgrnt.frbgrnt_status_code in ('A', 'C', 'L', 'CP', 'O')
                                                  AND fimsmgr.frbgrnt.frbgrnt_project_end_date >= sysdate - 120
                                                      AND ftvfund.ftvfund_nchg_date = c_active_date --to_date(c_active_date, c_date_format)
                                  ) grantinfo ON rdb_funds.grant_code = grantinfo.grantcode
                                                 AND rdb_funds.fund = grantinfo.fundcode
                              ORDER BY
                                  rdb_funds.orgn,
                                  rdb_funds.fund;
                            END;
                        END IF;

                    END;

                ELSE
                    BEGIN
                        IF v_view = c_schooldata THEN
                            BEGIN
                                OPEN p_awards FOR WITH fund_org AS (
                                                      SELECT DISTINCT
                                                          ftvorgn_coas_code,
                                                          ftvorgn_orgn_code,
                                                          ftvorgn_fund_code_def,
                                                          MAX(ftvorgn_eff_date) OVER(PARTITION BY ftvorgn_coas_code, ftvorgn_orgn_code,
                                                          ftvorgn_fund_code_def) AS "latest_eff_date"
                                                      FROM
                                                               fimsmgr.ftvorgn
                                                          INNER JOIN risdash.rdborgnmap ON substr(ftvorgn_orgn_code, 1, length(rdborgnmap.
                                                          rdborgnmap_orgn_code)) = rdborgnmap.rdborgnmap_orgn_code
                                                      WHERE
                                                          TRIM(v_org) IS NULL  -- wildcard query for all orgs for a dean user
                                                          AND ftvorgn_nchg_date IS NOT NULL
                                                          AND ftvorgn_eff_date IS NOT NULL
                                                          AND ftvorgn_orgn_code IS NOT NULL
                                                          AND rdborgnmap.rdborgnmap_pidm = v_pidm
                                                          AND rdborgnmap.rdborgnmap_nchg_date = TO_DATE('12/31/2099', 'mm/dd/yyyy')
                                                  ), grantfund AS (
                                                      SELECT DISTINCT
                                                          fimsmgr.frbgrnt.frbgrnt_code,
                                                          fimsmgr.ftvfund.ftvfund_fund_code,
                                                          fund_org.ftvorgn_orgn_code,
                                                          fimsmgr.frbgrnt.frbgrnt_pi_pidm,
                                                          fimsmgr.frbgrnt.frbgrnt_title,
                                                          fimsmgr.frbgrnt.frbgrnt_status_code,
                                                          fimsmgr.frbgrnt.frbgrnt_project_start_date,
                                                          fimsmgr.frbgrnt.frbgrnt_project_end_date,
                                                          fimsmgr.ftvfund.ftvfund_nchg_date,
                                                          fimsmgr.ftvfund.ftvfund_coas_code,
                                                          nvl2(saturn.spriden.spriden_last_name, saturn.spriden.spriden_last_name
                                                                                                 || ', '
                                                                                                 || substr(saturn.spriden.spriden_first_name,
                                                                                                 1, 1), 'NA') AS pi
                                                      FROM
                                                          fimsmgr.frbgrnt
                                                          LEFT OUTER JOIN fimsmgr.frrgrpi ON fimsmgr.frbgrnt.frbgrnt_code = fimsmgr.
                                                          frrgrpi.frrgrpi_grnt_code
                                                          LEFT OUTER JOIN saturn.spriden ON frrgrpi.frrgrpi_id_pidm = saturn.spriden.
                                                          spriden_pidm
                                                          INNER JOIN fimsmgr.ftvfund ON ftvfund.ftvfund_grnt_code = fimsmgr.frbgrnt.
                                                          frbgrnt_code
                                                          INNER JOIN fund_org ON fimsmgr.ftvfund.ftvfund_fund_code = fund_org.ftvorgn_fund_code_def
                                                      WHERE
                                                          saturn.spriden.spriden_change_ind IS NULL
                                                          AND fimsmgr.frrgrpi.frrgrpi_id_ind = '001'
                                                          AND fimsmgr.frbgrnt.frbgrnt_status_code in ('A', 'C', 'L', 'CP', 'O')
                                                          AND fimsmgr.frbgrnt.frbgrnt_project_end_date >= sysdate - 120
                                                          AND ftvfund.ftvfund_nchg_date = TO_DATE('12/31/2099', 'MM/DD/YYYY')
                                                  ), transhistory AS (
                                                      SELECT
                                                          fgbtrnd_doc_code    AS document,
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
                                                          AND NOT fgbtrnd_acct_code LIKE '7810' --changed from 790%
                                                          AND ( fgbtrnd_fund_code BETWEEN '20000' AND '35499' )
                                                  )-- end of with
                                                  SELECT DISTINCT
                                                      grant_code,
                                                      grant_title,
                                                      project_start_date,
                                                      project_end_date,
                                                      pi,
                                                      fund,
                                                      orgn,
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
                                                      round(trunc(project_end_date - sysdate) / 30, 2) mthsrem,
                                                      (
                                                          CASE
                                                              WHEN trunc(project_end_date - project_start_date) = 0 THEN
                                                                  0
                                                              ELSE
                                                                  round(trunc(project_end_date - sysdate) / trunc(project_end_date -
                                                                  project_start_date), 2) * 100
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
                                                              fund_trans_history.orgn,
                                                              ( SUM(
                                                                  CASE
                                                                      WHEN ledger_ind = c_letter_o
                                                                           AND field_code IN(
                                                                          '01', '02'
                                                                      ) --was previously '06'
                                                                           AND document LIKE 'J%'--was previously NOT LIKE 'A%'
                                                                            THEN
                                                                          amount
                                                                      ELSE
                                                                          0
                                                                  END
                                                              ) ) budget,
                                                              ( SUM(
                                                                  CASE
                                                                      WHEN ledger_ind = c_letter_o
                                                                           AND field_code = c_number_three THEN
                                                                          amount
                                                                      ELSE
                                                                          0
                                                                  END
                                                              ) ) expense,
                                                              ( SUM(
                                                                  CASE
                                                                      WHEN ledger_ind = 'O' --changed to operating ledger w/encumbrance related field codes
                                                                           AND field_code IN(
                                                                          '04', '05'
                                                                      )
                                                                           AND rucl_code <> 'E090' --AND DOCUMENT NOT LIKE 'A%'
                                                                            THEN
                                                                          amount
                                                                      ELSE
                                                                          0
                                                                  END
                                                              ) ) encumbrances,
                                                              ( ( SUM(
                                                                  CASE
                                                                      WHEN ledger_ind = 'O'
                                                                           AND field_code IN(
                                                                          '01', '02'
                                                                      ) --changed from '06' 
                                                                           AND document LIKE 'J%'-- was previously NOT LIKE 'A%'
                                                                            THEN
                                                                          amount
                                                                      ELSE
                                                                          0
                                                                  END
                                                              ) ) - ( SUM(
                                                                  CASE
                                                                      WHEN ledger_ind = 'O'
                                                                           AND field_code = '03' --same
                                                                            THEN
                                                                          amount
                                                                      ELSE
                                                                          0
                                                                  END
                                                              ) ) - SUM(
                                                                  CASE
                                                                      WHEN ledger_ind = 'O' --changed to operating ledger  w/encumbrance related field codes
                                                                           AND field_code IN(
                                                                          '04', '05'
                                                                      )
                                                                           AND rucl_code <> 'E090' ---AND DOCUMENT NOT LIKE 'A%'
                                                                            THEN
                                                                          amount
                                                                      ELSE
                                                                          0
                                                                  END
                                                              ) ) available
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
                                                                      grantfund.pi                            AS pi,
                                                                      grantfund.ftvorgn_orgn_code             AS orgn
                                                                  FROM
                                                                      transhistory
                                                                      RIGHT OUTER JOIN grantfund -- left outer join is changed to right outer join
                                                                       ON transhistory.chart_of_accounts = grantfund.ftvfund_coas_code
                                                                                                    AND transhistory.fund = grantfund.
                                                                                                    ftvfund_fund_code
                                                                      LEFT OUTER JOIN fimsmgr.ftvacct ON transhistory.chart_of_accounts =
                                                                      ftvacct.ftvacct_coas_code
                                                                                                         AND transhistory.account =
                                                                                                         ftvacct.ftvacct_acct_code
                                                                  WHERE
                                                                      ftvacct.ftvacct_nchg_date = c_active_date
                                                              ) fund_trans_history
                                                          GROUP BY
                                                              grant_code,
                                                              grant_title,
                                                              project_start_date,
                                                              project_end_date,
                                                              pi,
                                                              fund,
                                                              orgn
                                                      ) rdbdata
                                                  ORDER BY
                                                      orgn;

                            END;

                        ELSE
                            BEGIN
                                OPEN p_awards FOR WITH grantfund AS (
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
                                                                                                 || substr(saturn.spriden.spriden_first_name,
                                                                                                 1, 1), 'NA') AS pi
                                                      FROM
                                                          fimsmgr.frbgrnt
                                                          LEFT OUTER JOIN fimsmgr.frrgrpi ON fimsmgr.frbgrnt.frbgrnt_code = fimsmgr.
                                                          frrgrpi.frrgrpi_grnt_code
                                                          LEFT OUTER JOIN saturn.spriden ON frrgrpi.frrgrpi_id_pidm = saturn.spriden.
                                                          spriden_pidm
                                                          INNER JOIN fimsmgr.ftvfund ON ftvfund.ftvfund_grnt_code = fimsmgr.frbgrnt.
                                                          frbgrnt_code
                                                      WHERE
                                                              fimsmgr.frrgrpi.frrgrpi_id_pidm = v_pidm
                                                          AND saturn.spriden.spriden_change_ind IS NULL
                                                          AND fimsmgr.frrgrpi.frrgrpi_id_ind = '001'
                                                          AND fimsmgr.frbgrnt.frbgrnt_status_code in ('A', 'C', 'L', 'CP', 'O')
                                                          AND fimsmgr.frbgrnt.frbgrnt_project_end_date >= sysdate - 120
                                                          AND ftvfund.ftvfund_nchg_date = c_active_date
                                                  ), transhistory AS (
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
                                                          AND NOT fgbtrnd_acct_code LIKE '7810' --changed from 790%
                                                          AND ( fgbtrnd_fund_code BETWEEN '20000' AND '35499' )
                                                  ) -- end of with
                                                  SELECT DISTINCT
                                                      grant_code,
                                                      grant_title,
                                                      project_start_date,
                                                      project_end_date,
                                                      pi,
                                                      fund,
                                                      getfundorg(fund)                                         AS orgn,
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
                                                      round(trunc(project_end_date - sysdate) / 30, 2)         mthsrem,
                                                      (
                                                          CASE
                                                              WHEN trunc(project_end_date - project_start_date) = 0 THEN
                                                                  0
                                                              ELSE
                                                                  round(trunc(project_end_date - sysdate) / trunc(project_end_date -
                                                                  project_start_date), 2) * 100
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
                                                                      WHEN ledger_ind = c_letter_o
                                                                           AND field_code IN(
                                                                          c_number_one, c_number_two
                                                                      )
                                                                           AND document LIKE 'J%' THEN
                                                                          amount
                                                                      ELSE
                                                                          0
                                                                  END
                                                              ) ) budget,
                                                              ( SUM(
                                                                  CASE
                                                                      WHEN ledger_ind = c_letter_o
                                                                           AND field_code = c_number_three THEN
                                                                          amount
                                                                      ELSE
                                                                          0
                                                                  END
                                                              ) ) expense,
                                                              ( SUM(
                                                                  CASE
                                                                      WHEN ledger_ind = c_letter_o
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
                                                                      WHEN ledger_ind = c_letter_o
                                                                           AND field_code IN(
                                                                          c_number_one, c_number_two
                                                                      )
                                                                           AND document LIKE 'J%' THEN
                                                                          amount
                                                                      ELSE
                                                                          0
                                                                  END
                                                              ) --budget,
                                                               - SUM(
                                                                  CASE
                                                                      WHEN ledger_ind = c_letter_o
                                                                           AND field_code = c_number_three THEN
                                                                          amount
                                                                      ELSE
                                                                          0
                                                                  END
                                                              ) --expense,
                                                               - SUM(
                                                                  CASE
                                                                      WHEN ledger_ind = c_letter_o
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
                                                                      transhistory
                                                                      RIGHT OUTER JOIN grantfund ON transhistory.chart_of_accounts =
                                                                      grantfund.ftvfund_coas_code
                                                                                                    AND transhistory.fund = grantfund.
                                                                                                    ftvfund_fund_code
                                                                      LEFT OUTER JOIN fimsmgr.ftvacct ON transhistory.chart_of_accounts =
                                                                      ftvacct.ftvacct_coas_code
                                                                                                         AND transhistory.account =
                                                                                                         ftvacct.ftvacct_acct_code
                                                                  WHERE
                                                                      ftvacct.ftvacct_nchg_date = c_active_date
                                                              ) fund_trans_history
                                                          GROUP BY
                                                              grant_code,
                                                              grant_title,
                                                              project_start_date,
                                                              project_end_date,
                                                              pi,
                                                              fund
                                                      ) rdb_data
                                                  ORDER BY
                                                      orgn;

                            END;
                        END IF;

                    END;
                END IF;

            END;
        END IF;

    END;
    PROCEDURE uah_p_cogr_rdb_awd_ends (
        v_pidm        IN   VARCHAR2,
        v_view        IN   VARCHAR2,
        v_org         IN   VARCHAR2,
        p_award_ends  OUT  SYS_REFCURSOR
    ) IS

        admin_count        NUMBER := 0;
        c_pi_role          CHAR(3) := '001';
        c_copi_role        CHAR(3) := '002';
        c_admin_role       CHAR(3) := '003';
        c_dept_admin_role  CHAR(3) := '006';
        c_letter_a         CHAR(1) := 'A';
        c_rdb_fund         CHAR(2) := '2%';
        c_schooldata       CHAR(1) := '2';
        c_active_date      DATE := TO_DATE('12/31/2099', 'MM/DD/YYYY');
    BEGIN
        SELECT
            COUNT(*)
        INTO admin_count
        FROM
            risdash.rdborgnmap
        WHERE
                rdborgnmap_pidm = v_pidm
            AND rdborgnmap_orgn_code = 'RDBADM'
            AND rdborgnmap_nchg_date = TO_DATE('12/31/2099', 'mm/dd/yyyy');

        IF
            admin_count > 0 AND v_view = c_schooldata
        THEN  -- retrives all grants for admin for school view
            BEGIN
                OPEN p_award_ends FOR SELECT DISTINCT
                                      rdb_funds.grant_code            AS grant_code,
                                      rdb_funds.fund                  AS fund_code,
                                      rdb_funds.orgn                  AS orgn,
                                      rdb_funds.grant_title           AS title,
                                      rdb_funds.project_start_date    AS start_date,
                                      rdb_funds.project_end_date      AS end_date,
                                      rdb_funds.pi                    AS pi
                                  FROM
                                      risdash.uah_mv_cogr_research_dashboard rdb_funds
                                  WHERE
                                          rdb_funds.project_end_date >= sysdate
                                      AND rdb_funds.project_end_date <= sysdate + 120
                                  ORDER BY
                                      rdb_funds.orgn,
                                      rdb_funds.fund;    
            END;

        ELSE
            BEGIN
                IF v_view = c_schooldata THEN
                    BEGIN
                        OPEN p_award_ends FOR WITH fund_org AS (
                                                  SELECT DISTINCT
                                                      ftvorgn_coas_code,
                                                      ftvorgn_orgn_code      AS orgn,
                                                      ftvorgn_fund_code_def  AS fund,
                                                      MAX(ftvorgn_eff_date) OVER(PARTITION BY ftvorgn_coas_code, ftvorgn_orgn_code, ftvorgn_fund_code_def)
                                                      AS "latest_eff_date"
                                                  FROM
                                                           fimsmgr.ftvorgn
                                                      INNER JOIN risdash.rdborgnmap ON substr(ftvorgn_orgn_code, 1, length(rdborgnmap.
                                                      rdborgnmap_orgn_code)) = rdborgnmap.rdborgnmap_orgn_code
                                                  WHERE
                                                      TRIM(v_org) IS NULL  -- wildcard query for all orgs for a dean user
                                                      AND ftvorgn_nchg_date IS NOT NULL
                                                      AND ftvorgn_eff_date IS NOT NULL
                                                      AND ftvorgn_orgn_code IS NOT NULL
                                                      AND rdborgnmap.rdborgnmap_pidm = v_pidm
                                                      AND rdborgnmap.rdborgnmap_nchg_date = TO_DATE('12/31/2099', 'mm/dd/yyyy')
                                              )
                                              SELECT DISTINCT
                                                  fimsmgr.frbgrnt.frbgrnt_code                    AS grant_code,
                                                  fimsmgr.ftvfund.ftvfund_fund_code               AS fund_code,
                                                  fund_org.orgn                                   AS orgn,
                                                  fimsmgr.frbgrnt.frbgrnt_title                   AS title,
                                                  fimsmgr.frbgrnt.frbgrnt_project_start_date      AS start_date,
                                                  fimsmgr.frbgrnt.frbgrnt_project_end_date        AS end_date,
                                                  nvl2(saturn.spriden.spriden_last_name, saturn.spriden.spriden_last_name
                                                                                         || ', '
                                                                                         || substr(saturn.spriden.spriden_first_name,
                                                                                         1, 1), 'NA') AS pi
                                              FROM
                                                       fimsmgr.frbgrnt
                                                  INNER JOIN fimsmgr.ftvfund ON ftvfund.ftvfund_grnt_code = fimsmgr.frbgrnt.frbgrnt_code
                                                  INNER JOIN fund_org ON fimsmgr.ftvfund.ftvfund_fund_code = fund_org.fund
                                                  LEFT OUTER JOIN fimsmgr.frrgrpi ON fimsmgr.frbgrnt.frbgrnt_code = fimsmgr.frrgrpi.frrgrpi_grnt_code
                                                  LEFT OUTER JOIN saturn.spriden ON frrgrpi.frrgrpi_id_pidm = saturn.spriden.spriden_pidm
                                              WHERE
                                                  saturn.spriden.spriden_change_ind IS NULL
                                                  AND fimsmgr.frbgrnt.frbgrnt_status_code in ('A', 'C', 'L', 'CP', 'O')
                                                  AND fimsmgr.frbgrnt.frbgrnt_project_end_date >= sysdate
                                                  AND fimsmgr.frbgrnt.frbgrnt_project_end_date <= sysdate + 120
                                                  AND fimsmgr.ftvfund.ftvfund_nchg_date = c_active_date
                                                  AND fimsmgr.frrgrpi.frrgrpi_id_ind = c_pi_role;

                    END;

                ELSE
                    BEGIN
                        OPEN p_award_ends FOR SELECT DISTINCT
                                                  fimsmgr.frbgrnt.frbgrnt_code                          AS grant_code,
                                                  fimsmgr.ftvfund.ftvfund_fund_code                     AS fund_code,
                                                  getfundorg(fimsmgr.ftvfund.ftvfund_fund_code)         AS orgn,
                                                  fimsmgr.frbgrnt.frbgrnt_title                         AS title,
                                                  fimsmgr.frbgrnt.frbgrnt_project_start_date            AS start_date,
                                                  fimsmgr.frbgrnt.frbgrnt_project_end_date              AS end_date,
                                                  nvl2(saturn.spriden.spriden_last_name, saturn.spriden.spriden_last_name
                                                                                         || ', '
                                                                                         || substr(saturn.spriden.spriden_first_name,
                                                                                         1, 1), 'NA') AS pi
                                              FROM
                                                       fimsmgr.frbgrnt
                                                  INNER JOIN fimsmgr.ftvfund ON fimsmgr.frbgrnt.frbgrnt_code = fimsmgr.ftvfund.ftvfund_grnt_code
                                                  LEFT OUTER JOIN fimsmgr.frrgrpi ON fimsmgr.frbgrnt.frbgrnt_code = fimsmgr.frrgrpi.frrgrpi_grnt_code
                                                  LEFT OUTER JOIN saturn.spriden ON frrgrpi.frrgrpi_id_pidm = saturn.spriden.spriden_pidm
                                              WHERE
                                                  saturn.spriden.spriden_change_ind IS NULL
                                                  AND ftvfund.ftvfund_nchg_date = c_active_date
                                                  AND fimsmgr.frbgrnt.frbgrnt_status_code in ('A', 'C', 'L', 'CP', 'O')
                                                  AND fimsmgr.frbgrnt.frbgrnt_project_end_date >= sysdate
                                                  AND fimsmgr.frbgrnt.frbgrnt_project_end_date <= sysdate + 120
                                                  AND fimsmgr.frrgrpi.frrgrpi_id_ind = c_pi_role
                                                  AND fimsmgr.frrgrpi.frrgrpi_id_pidm = v_pidm;

                    END;
                END IF;

            END;
        END IF;
    END;
    PROCEDURE uah_p_cogr_rdb_awd_details (
        v_pidm           IN   VARCHAR2,
        v_fundid         IN   VARCHAR2,
        v_source         IN   VARCHAR2,
        p_award_details  OUT  SYS_REFCURSOR
    ) IS

        c_no_rdb_doc             CHAR(2) := 'A%';
        c_letter_o               CHAR(1) := 'O';
        c_letter_e               CHAR(1) := 'E';
        c_letter_a               CHAR(1) := 'A';
        c_number_six             CHAR(2) := '06';
        c_number_three           CHAR(2) := '03';
        c_active_date            VARCHAR(20) := '12/31/2099';
        c_date_format            VARCHAR(20) := 'MM/DD/YYYY';
        c_no_rdb_account         CHAR(2) := '5%';
        rdb_mv_refresh_datetime  dba_mviews.last_refresh_date%TYPE;
        rdb_mv_refresh_status    dba_mviews.last_refresh_type%TYPE;
        c_realtime_data          CHAR(1) := '1';
        c_materializedview       CHAR(1) := '2';
        CURSOR c_mv_status IS
        SELECT
            last_refresh_date,
            last_refresh_type
        FROM
            dba_mviews
        WHERE
            mview_name = 'UAH_MV_COGR_RESEARCH_DASHBOARD';

    BEGIN
        OPEN c_mv_status;
        FETCH c_mv_status INTO
            rdb_mv_refresh_datetime,
            rdb_mv_refresh_status;
        CLOSE c_mv_status;
        OPEN p_award_details FOR SELECT
                                     fund_trans_history.grant_code,
                                     fund_trans_history.grant_title,
                                     fund_trans_history.coa,
                                     fund_trans_history.fund,
                                     fund_trans_history.orgn,
                                     fund_trans_history.acct_title,
                                     fund_trans_history.account,
                                     ( SUM(
                                         CASE
                                             WHEN ledger_ind = c_letter_o
                                                  AND field_code IN(
                                                 '01', '02'
                                             ) --was previously '06' 
                                                  AND document LIKE 'J%'--was previously NOT LIKE 'A%'
                                                   THEN
                                                 amount
                                             ELSE
                                                 0
                                         END
                                     ) ) budget,
                                     ( SUM(
                                         CASE
                                             WHEN ledger_ind = c_letter_o
                                                  AND field_code = c_number_three THEN
                                                 amount
                                             ELSE
                                                 0
                                         END
                                     ) ) expense,
                                     ( SUM(
                                         CASE
                                             WHEN ledger_ind = 'O' --changed to operating ledger w/encumbrance related field codes
                                                  AND field_code IN(
                                                 '04', '05'
                                             )
                                                  AND rucl_code <> 'E090' --AND DOCUMENT NOT LIKE 'A%'
                                                   THEN
                                                 amount
                                             ELSE
                                                 0
                                         END
                                     ) ) encumbrances,
                                     ( ( SUM(
                                         CASE
                                             WHEN ledger_ind = 'O'
                                                  AND field_code IN(
                                                 '01', '02'
                                             ) --changed from '06' 
                                                  AND document LIKE 'J%'-- was previously NOT LIKE 'A%'
                                                   THEN
                                                 amount
                                             ELSE
                                                 0
                                         END
                                     ) ) - ( SUM(
                                         CASE
                                             WHEN ledger_ind = 'O'
                                                  AND field_code = '03' --same
                                                   THEN
                                                 amount
                                             ELSE
                                                 0
                                         END
                                     ) ) - SUM(
                                         CASE
                                             WHEN ledger_ind = 'O' --changed to operating ledger  w/encumbrance related field codes
                                                  AND field_code IN(
                                                 '04', '05'
                                             )
                                                  AND rucl_code <> 'E090' ---AND DOCUMENT NOT LIKE 'A%'
                                                   THEN
                                                 amount
                                             ELSE
                                                 0
                                         END
                                     ) ) available
                                 FROM
                                     (
                                         SELECT
                                             transhistory.document,
                                             transhistory.ledger_ind                AS ledger_ind,
                                             transhistory.field_code                AS field_code,
                                             transhistory.fund                      AS fund,
                                             transhistory.account                   AS account,
                                             transhistory.rucl_code                 AS rucl_code,
                                             transhistory.transaction_amount        AS amount,
                                             transhistory.chart_of_accounts         AS coa,
                                             fimsmgr.ftvacct.ftvacct_title          AS acct_title,
                                             fimsmgr.ftvacct.ftvacct_atyp_code      AS acct_type,
                                             grantfund.frbgrnt_code                 AS grant_code,
                                             grantfund.frbgrnt_title                AS grant_title,
                                             grantfund.orgn                         AS orgn,
                                             grantfund.frbgrnt_pi_pidm              AS pidm,
                                             grantfund.frbgrnt_status_code          AS status,
                                             grantfund.frbgrnt_project_end_date     AS project_end_date
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
                                                         fgbtrnh_doc_seq_code = fgbtrnd_doc_seq_code (+)
                                                     AND fgbtrnh_doc_code = fgbtrnd_doc_code (+)
                                                     AND fgbtrnh_submission_number = fgbtrnd_submission_number (+)
                                                     AND fgbtrnh_item_num = fgbtrnd_item_num (+)
                                                     AND fgbtrnh_seq_num = fgbtrnd_seq_num (+)
                                                     AND fgbtrnh_serial_num = fgbtrnd_serial_num (+)
                                                     AND fgbtrnh_reversal_ind = fgbtrnd_reversal_ind (+)
                                                     AND fgbtrnh_coas_code = 'H' --added chart of accounts check
                                                     AND fgbtrnd_ledger_ind = 'O' --updated to only look at operating ledger
                                                     AND NOT fgbtrnd_acct_code LIKE '5%'
                                                     AND NOT fgbtrnd_acct_code LIKE '7810' --changed from 790%
                                                     AND ( fgbtrnd_fund_code BETWEEN '20000' AND '35499' )
                                                     AND fgbtrnd_fund_code = v_fundid
                                                     AND ( ( fgbtrnh_trans_date <= rdb_mv_refresh_datetime
                                                             AND v_source = c_materializedview ) --if realtime data is needed, get all data
                                                           OR v_source = c_realtime_data ) -- if materialized view data is needed, get data older then MV refreshment
                                             ) transhistory
                                             RIGHT OUTER JOIN  -- left outer join is changed to right outer join
                                              (
                                                 SELECT DISTINCT
                                                     fimsmgr.frbgrnt.frbgrnt_code,
                                                     fimsmgr.frbgrnt.frbgrnt_pi_pidm,
                                                     fimsmgr.frbgrnt.frbgrnt_title,
                                                     fimsmgr.ftvfund.ftvfund_fund_code,
                                                     risdash.uah_K_COGR_RESEARCH_DASHBOARD.getfundorg(fimsmgr.ftvfund.ftvfund_fund_code) as orgn,
                                                     fimsmgr.ftvfund.ftvfund_nchg_date,
                                                     fimsmgr.frbgrnt.frbgrnt_status_code,
                                                     fimsmgr.frbgrnt.frbgrnt_project_end_date,
                                                     fimsmgr.ftvfund.ftvfund_coas_code
                                                 FROM
                                                          fimsmgr.ftvfund
                                                     INNER JOIN fimsmgr.frbgrnt ON ftvfund.ftvfund_grnt_code = fimsmgr.frbgrnt.frbgrnt_code
                                                 WHERE
                                                         ftvfund.ftvfund_nchg_date = to_date(c_active_date, c_date_format)
                                                     AND ftvfund.ftvfund_fund_code = v_fundid
                                                     AND fimsmgr.frbgrnt.frbgrnt_status_code in ('A', 'C', 'L', 'CP', 'O')
                                                     AND fimsmgr.frbgrnt.frbgrnt_project_end_date >= sysdate - 120
                                             ) grantfund ON transhistory.chart_of_accounts = grantfund.ftvfund_coas_code
                                                            AND transhistory.fund = grantfund.ftvfund_fund_code   -- this condition is added for correctness
                                             LEFT OUTER JOIN fimsmgr.ftvacct ON transhistory.chart_of_accounts = ftvacct.ftvacct_coas_code
                                                                                AND transhistory.account = ftvacct.ftvacct_acct_code
                                         WHERE
                                             ftvacct.ftvacct_nchg_date = to_date(c_active_date, c_date_format)
                                         ORDER BY
                                             fund,
                                             account
                                     ) fund_trans_history
                                 GROUP BY
                                     grant_code,
                                     grant_title,
                                     coa,
                                     fund,
                                     orgn,
                                     account,
                                     acct_title
                                 ORDER BY
                                     grant_code,
                                     coa,
                                     fund,
                                     account;

    END;
    
    PROCEDURE uah_p_cogr_rdb_acct_trans (
        v_pidm                   IN VARCHAR2,
        v_fundid                 IN VARCHAR2,
        v_acctid                 IN VARCHAR2,
        v_trans_type             IN VARCHAR2,
        v_source                 IN VARCHAR2,
        p_account_transactions   OUT SYS_REFCURSOR
    ) IS

        c_no_rdb_doc              CHAR(2) := 'A%';
        c_letter_o                CHAR(1) := 'O';
        c_letter_e                CHAR(1) := 'E';
        c_letter_f                CHAR(1) := 'F';
        c_letter_a                CHAR(1) := 'A';
        c_number_six              CHAR(2) := '06';
        c_number_three            CHAR(2) := '03';
        c_active_date             VARCHAR(20) := '12/31/2099';
        c_date_format             VARCHAR(20) := 'MM/DD/YYYY';
        c_no_rdb_account          CHAR(2) := '5%';
        c_payroll_link1           CHAR(50) := '~/payrollDetails.aspx?fundID=';
        c_payroll_link2           CHAR(20) := '=';
        c_payroll_link3           CHAR(20) := '=';
        c_payroll_no_link         CHAR(1) := '';
        c_expense                 CHAR(7) := 'EXPENSE';
        c_encumbrance             CHAR(12) := 'ENCUMBRANCES';
        c_budget                  CHAR(6) := 'BUDGET';
        c_rdb_code                CHAR(20) := 'FTVACTL';
        c_rdb_account1            CHAR(3) := '601';
        c_rdb_account2            CHAR(3) := '602';
        c_rdb_account3            CHAR(3) := '603';
        c_rdb_account4            CHAR(3) := '604';
        c_rdb_account5            CHAR(3) := '605';
        rdb_mv_refresh_datetime   dba_mviews.last_refresh_date%TYPE;
        rdb_mv_refresh_status     dba_mviews.last_refresh_type%TYPE;
        c_realtime_data           CHAR(1) := '1';
        c_materializedview        CHAR(1) := '2';
        CURSOR c_mv_status IS SELECT
                                  last_refresh_date,
                                  last_refresh_type
                              FROM
                                  dba_mviews
                              WHERE
                                  mview_name = 'UAH_MV_COGR_RESEARCH_DASHBOARD';

    BEGIN
        OPEN c_mv_status;
        FETCH c_mv_status INTO
            rdb_mv_refresh_datetime,
            rdb_mv_refresh_status;
        CLOSE c_mv_status;
        OPEN p_account_transactions FOR WITH transhistory AS (
                                            SELECT
                                                t.*,
                                                ROW_NUMBER() OVER(
                                                    PARTITION BY t.document
                                                    ORDER BY
                                                        t.seq_num
                                                ) seq_group
                                            FROM
                                                (
                                                    SELECT
                                                        fgbtrnh_doc_code       AS document,
                                                        fgbtrnh_seq_num        AS seq_num,
                                                        fgbtrnh_doc_seq_code   AS document_type,
                                                        fgbtrnd_ledger_ind     AS ledger_ind,
                                                        fgbtrnd_field_code     AS field_code,
                                                        fgbtrnd_coas_code      AS chart_of_accounts,
                                                        fgbtrnd_fund_code      AS fund,
                                                        fgbtrnd_acct_code      AS account,
                                                        fgbtrnd_rucl_code      AS rucl_code,
                                                        fgbtrnd_trans_amt      AS transaction_amount,
                                                        fgbtrnh_trans_date     AS transaction_date,
                                                        fgbtrnh_trans_desc     AS transaction_desc,
                                                        fgbtrnd_prog_code      AS program,
                                                        fgbtrnd_orgn_code      AS organization_code
                                                    FROM
                                                        fimsmgr.fgbtrnh,
                                                        fimsmgr.fgbtrnd
                                                    WHERE
                                                        fgbtrnh_doc_seq_code = fgbtrnd_doc_seq_code (+)
                                                        AND fgbtrnh_doc_code = fgbtrnd_doc_code (+)
                                                        AND fgbtrnh_submission_number = fgbtrnd_submission_number (+)
                                                        AND fgbtrnh_item_num = fgbtrnd_item_num (+)
                                                        AND fgbtrnh_seq_num = fgbtrnd_seq_num (+)
                                                        AND fgbtrnh_serial_num = fgbtrnd_serial_num (+)
                                                        AND fgbtrnh_reversal_ind = fgbtrnd_reversal_ind (+)
                                                        AND fgbtrnh_coas_code = 'H'
                                                        AND fgbtrnd_ledger_ind = 'O'
                                                        AND NOT fgbtrnd_acct_code LIKE '5%'
                                                        AND NOT fgbtrnd_acct_code LIKE '7810' --changed from 790%
                                                        AND ( fgbtrnd_fund_code BETWEEN '20000' AND '35499' )
                                                        AND fgbtrnd_fund_code = v_fundid
                                                        AND fgbtrnd_acct_code = v_acctid
                                                        AND ( ( fgbtrnh_trans_date <= rdb_mv_refresh_datetime
                                                                AND v_source = c_materializedview ) --if realtime data is needed, get all data
                                                              OR v_source = c_realtime_data ) -- if materialized view data is needed, get data older then MV refreshment
                               --and FGBTRNH_TRANS_DATE <= rdb_mv_refresh_datetime -- added to match with data in Materialized View
                                                ) t
                                        )
            SELECT
                acct_trans_history.grant_code,
                acct_trans_history.grant_title,
                acct_trans_history.coa,
                acct_trans_history.fund,
                acct_trans_history.acct_title,
                acct_trans_history.account,
                acct_trans_history.org_code,
                acct_trans_history.trans_date,
                acct_trans_history.trans_desc,
                acct_trans_history.doc_type,
                acct_trans_history.program,
                acct_trans_history.field_code,
                acct_trans_history.document,
                acct_trans_history.seq_group,
                acct_trans_history.amount,
                acct_trans_history.doc_link,
                acct_trans_history.fcodedesc
            FROM
                (
                    SELECT
                        transhistory.document,
                        transhistory.seq_group,
                        transhistory.ledger_ind              AS ledger_ind,
                        transhistory.field_code              AS field_code,
                        transhistory.fund                    AS fund,
                        transhistory.account                 AS account,
                        transhistory.transaction_amount      AS amount,
                        transhistory.chart_of_accounts       AS coa,
                        transhistory.rucl_code               AS rucl_code,
                        fimsmgr.ftvacct.ftvacct_title        AS acct_title,
                        fimsmgr.ftvacct.ftvacct_atyp_code    AS acct_type,
                        grantfund.frbgrnt_code               AS grant_code,
                        grantfund.frbgrnt_title              AS grant_title,
                        grantfund.frbgrnt_pi_pidm            AS pidm,
                        grantfund.frbgrnt_status_code        AS status,
                        grantfund.frbgrnt_project_end_date   AS project_end_date,
                        transhistory.organization_code       AS org_code,
                        transhistory.transaction_date        AS trans_date,
                        transhistory.transaction_desc        AS trans_desc,
                        transhistory.document_type           AS doc_type,
                        transhistory.program,
                                                    (
                                                        CASE
                            WHEN substr(transhistory.account,1,3) IN (
                                c_rdb_account1,
                                c_rdb_account2,
                                c_rdb_account3,
                                c_rdb_account4,
                                c_rdb_account5
                            )
                                                                 AND substr(transhistory.document, 1, 1) = c_letter_f THEN
                                                                TRIM(c_payroll_link1)
                                                                || transhistory.fund
                                                                || TRIM(c_payroll_link2)
                                                                || transhistory.account
                                                                || TRIM(c_payroll_link3)
                                                                || transhistory.document
                                                            ELSE
                                                                TRIM(c_payroll_no_link)
                                                        END
                                                    ) doc_link,
                        fieldcodemap.fcodedesc
                    FROM
                        transhistory
                        LEFT OUTER JOIN (
                            SELECT DISTINCT
                                fimsmgr.ftvsdat.ftvsdat_sdat_code_opt_1   AS field_code,
                                fimsmgr.ftvsdat.ftvsdat_short_title       AS fcodedesc
                            FROM
                                fimsmgr.ftvsdat
                            WHERE
                                fimsmgr.ftvsdat.ftvsdat_coas_code = c_letter_a
                                AND fimsmgr.ftvsdat.ftvsdat_sdat_code_entity = c_rdb_code
                        ) fieldcodemap ON transhistory.field_code = fieldcodemap.field_code
                        RIGHT OUTER JOIN  -- left outer join is changed to right outer join
                         (
                            SELECT DISTINCT
                                fimsmgr.frbgrnt.frbgrnt_code,
                                fimsmgr.frbgrnt.frbgrnt_pi_pidm,
                                fimsmgr.frbgrnt.frbgrnt_title,
                                fimsmgr.ftvfund.ftvfund_fund_code,
                                fimsmgr.ftvfund.ftvfund_nchg_date,
                                fimsmgr.frbgrnt.frbgrnt_status_code,
                                fimsmgr.frbgrnt.frbgrnt_project_end_date,
                                fimsmgr.ftvfund.ftvfund_coas_code
                            FROM
                                fimsmgr.ftvfund
                                INNER JOIN fimsmgr.frbgrnt ON ftvfund.ftvfund_grnt_code = fimsmgr.frbgrnt
                                .frbgrnt_code
                            WHERE
                                ftvfund.ftvfund_nchg_date = TO_DATE(c_active_date,c_date_format)
                                AND ftvfund.ftvfund_fund_code = v_fundid
                                AND fimsmgr.frbgrnt.frbgrnt_status_code IN (
                                    'A',
                                    'C',
                                    'L',
                                    'CP',
                                    'O'
                                )
                                AND fimsmgr.frbgrnt.frbgrnt_project_end_date >= SYSDATE - 120
                        ) grantfund ON transhistory.chart_of_accounts = grantfund.ftvfund_coas_code
                                       AND transhistory.fund = grantfund.ftvfund_fund_code   -- this condition is added for correctness
                        LEFT OUTER JOIN fimsmgr.ftvacct ON transhistory.chart_of_accounts = ftvacct.ftvacct_coas_code
                                                           AND transhistory.account = ftvacct.ftvacct_acct_code
                    WHERE
                        ftvacct.ftvacct_nchg_date = TO_DATE(c_active_date,c_date_format)
                ) acct_trans_history
            WHERE
                ( ledger_ind = c_letter_o
                  AND field_code IN (
                    '01',
                    '02'
                )
                  AND document LIKE 'J%'
                  AND v_trans_type = c_budget )
                OR ( ledger_ind = c_letter_o
                     AND field_code = c_number_three
                     AND v_trans_type = c_expense )
                OR ( ledger_ind = c_letter_o
                     AND field_code IN (
                    '04',
                    '05'
                )
                     AND rucl_code <> 'E090'
                     AND v_trans_type = c_encumbrance )
            ORDER BY
                document desc,
                seq_group;

    END;     
    PROCEDURE uah_p_cogr_rdb_user_auth (
        v_mybamaid   IN   VARCHAR2, -- it is spriden_ID for UAH research Dashboard
        p_user_data  OUT  SYS_REFCURSOR
    ) IS

        c_pi_role          CHAR(3) := '001';
        c_copi_role        CHAR(3) := '002';
        c_admin_role       CHAR(3) := '003';
        c_dept_admin_role  CHAR(3) := '006';
        c_active_date      DATE := TO_DATE('12/31/2099', 'MM/DD/YYYY');
    BEGIN
        OPEN p_user_data FOR WITH userdata AS (
                                 SELECT
                                     spriden_pidm        AS pidm,
                                     spriden_id,
                                     spriden_last_name   AS lastname,
                                     spriden_first_name  AS firstname,
                                     spriden_mi          AS midname
                                 FROM
                                     saturn.spriden
                                 WHERE
                                     spriden_change_ind IS NULL
                                     AND spriden_id = v_mybamaid
                             )
                             SELECT DISTINCT
                                 fimsmgr.frrgrpi.frrgrpi_id_pidm      AS pidm,
                                 fimsmgr.frrgrpi.frrgrpi_id_ind       AS role,
                                 userdata.firstname,
                                 userdata.lastname,
                                 userdata.midname
                             FROM
                                 fimsmgr.frrgrpi
                                 RIGHT OUTER JOIN userdata ON fimsmgr.frrgrpi.frrgrpi_id_pidm = userdata.pidm
                             WHERE
                                 ( fimsmgr.frrgrpi.frrgrpi_id_ind = c_pi_role
                                   --OR fimsmgr.frrgrpi.frrgrpi_id_ind = c_copi_role
                                   --OR fimsmgr.frrgrpi.frrgrpi_id_ind = c_admin_role
                                   --OR fimsmgr.frrgrpi.frrgrpi_id_ind = c_dept_admin_role 
                                   )
                             UNION
                             SELECT DISTINCT
                                 risdash.rdborgnmap.rdborgnmap_pidm      AS pidm,
                                 (
                                    CASE rdborgnmap_orgn_code
                                        WHEN 'RDBADM' THEN
                                            'ADMIN'
                                        ELSE
                                            'SCHOOL'
                                    END
                                )AS role,
                                 userdata.firstname,
                                 userdata.lastname,
                                 userdata.midname
                             FROM
                                 risdash.rdborgnmap
                                 RIGHT OUTER JOIN userdata ON risdash.rdborgnmap.rdborgnmap_pidm = userdata.pidm
                             WHERE
                                 risdash.rdborgnmap.rdborgnmap_nchg_date = c_active_date;

    END;
     PROCEDURE uah_p_cogr_rdb_dean_check (
        v_cwid       IN   VARCHAR2,
        p_user_data  OUT  SYS_REFCURSOR
    ) IS
        c_nameformat   CHAR(7) := 'LFIMI30';
        c_active_date  DATE := TO_DATE('12/31/2099', 'MM/DD/YYYY');
    BEGIN
        OPEN p_user_data FOR SELECT DISTINCT
                                 saturn.spriden.spriden_pidm                                       AS pidm,
                                 saturn.spriden.spriden_id                                         AS cwid,
                                 f_format_name(saturn.spriden.spriden_pidm, c_nameformat)         AS username
                             FROM
                                 saturn.spriden
                             WHERE
                                     saturn.spriden.spriden_id = v_cwid
                                 AND saturn.spriden.spriden_change_ind IS NULL
                                 AND saturn.spriden.spriden_pidm NOT IN (
                                     SELECT
                                         risdash.rdborgnmap.rdborgnmap_pidm
                                     FROM
                                         risdash.rdborgnmap
                                     WHERE
                                         risdash.rdborgnmap.rdborgnmap_nchg_date = c_active_date
                                 );

    END;
      PROCEDURE uah_p_cogr_rdb_payroll (
        v_doc_code  IN   VARCHAR2,
        v_fundid    IN   VARCHAR2,
        v_acctid    IN   VARCHAR2,
        v_source    IN   VARCHAR2,
        p_payroll   OUT  SYS_REFCURSOR
    ) IS

        c_credit                 CHAR(1) := 'C';
        c_debit                  CHAR(1) := 'D';
        rdb_mv_refresh_datetime  dba_mviews.last_refresh_date%TYPE;
        rdb_mv_refresh_status    dba_mviews.last_refresh_type%TYPE;
        c_realtime_data          CHAR(1) := '1';
        c_materializedview       CHAR(1) := '2';
        CURSOR c_mv_status IS
        SELECT
            last_refresh_date,
            last_refresh_type
        FROM
            dba_mviews
        WHERE
            mview_name = 'UAH_MV_COGR_RESEARCH_DASHBOARD';

    BEGIN
        OPEN c_mv_status;
        FETCH c_mv_status INTO
            rdb_mv_refresh_datetime,
            rdb_mv_refresh_status;
        CLOSE c_mv_status;
        OPEN p_payroll FOR SELECT
                               f_format_name(posnctl.nhrdist.nhrdist_pidm, 'LFIMI30') AS username,
                               (
                                   CASE
                                       WHEN posnctl.nhrdist.nhrdist_dr_cr_ind = c_credit       THEN
                                           posnctl.nhrdist.nhrdist_amt * ( - 1 )
                                       WHEN posnctl.nhrdist.nhrdist_dr_cr_ind = c_debit        THEN
                                           posnctl.nhrdist.nhrdist_amt
                                       ELSE
                                           posnctl.nhrdist.nhrdist_amt
                                   END
                               ) AS amount
                           FROM
                               posnctl.nhrdist
                           WHERE
                                   nhrdist_doc_code = v_doc_code --'F0016726'
                               AND nhrdist_fund_code = v_fundid --'23175'
                               AND nhrdist_acct_code = v_acctid --'601340'
                               AND posnctl.nhrdist.nhrdist_dr_cr_ind IN (
                                   c_credit,
                                   c_debit
                               ) -- added per tammy request
            --and POSNCTL.NHRDIST.NHRDIST_TRANS_DATE <= rdb_mv_refresh_datetime; -- added to match with data in Materialized View
                               AND ( ( posnctl.nhrdist.nhrdist_trans_date <= rdb_mv_refresh_datetime
                                       AND v_source = c_materializedview ) --if realtime data is needed, get all data
                                     OR v_source = c_realtime_data ); -- if materialized view data is needed, get data older then MV refreshment

    END;
    
    PROCEDURE uah_p_cogr_rdb_acct_payroll (
        v_fundid            IN VARCHAR2,
        v_acctid            IN VARCHAR2,
        v_doc               IN VARCHAR2 DEFAULT '',
        v_trans_type        IN VARCHAR2,
        v_source            IN VARCHAR2,
        p_account_payroll   OUT SYS_REFCURSOR
    ) IS

        c_no_rdb_doc              CHAR(2) := 'A%';
        c_letter_o                CHAR(1) := 'O';
        c_letter_e                CHAR(1) := 'E';
        c_letter_f                CHAR(1) := 'F';
        c_letter_a                CHAR(1) := 'A';
        c_number_six              CHAR(2) := '06';
        c_number_three            CHAR(2) := '03';
        c_active_date             VARCHAR(20) := '12/31/2099';
        c_date_format             VARCHAR(20) := 'MM/DD/YYYY';
        c_no_rdb_account          CHAR(2) := '5%';
        c_payroll_link1           CHAR(50) := '~/payrollDetails.aspx?fundID=';
        c_payroll_link2           CHAR(20) := '=';
        c_payroll_link3           CHAR(20) := '=';
        c_payroll_no_link         CHAR(1) := '';
        c_expense                 CHAR(7) := 'EXPENSE';
        c_encumbrance             CHAR(12) := 'ENCUMBRANCES';
        c_budget                  CHAR(6) := 'BUDGET';
        c_rdb_code                CHAR(20) := 'FTVACTL';
        c_rdb_account1            CHAR(4) := '601%';
        c_rdb_account2            CHAR(4) := '602%';
        c_rdb_account3            CHAR(4) := '603%';
        c_rdb_account4            CHAR(4) := '604%';
        c_rdb_account5            CHAR(4) := '605%';
        c_credit                  CHAR(1) := 'C';
        c_debit                   CHAR(1) := 'D';
        c_valid_doc               CHAR(2) := 'F%';
        rdb_mv_refresh_datetime   dba_mviews.last_refresh_date%TYPE;
        rdb_mv_refresh_status     dba_mviews.last_refresh_type%TYPE;
        c_realtime_data           CHAR(1) := '1';
        c_materializedview        CHAR(1) := '2';
        CURSOR c_mv_status IS SELECT
                                  last_refresh_date,
                                  last_refresh_type
                              FROM
                                  dba_mviews
                              WHERE
                                  mview_name = 'UAH_MV_COGR_RESEARCH_DASHBOARD';

    BEGIN
        OPEN c_mv_status;
        FETCH c_mv_status INTO
            rdb_mv_refresh_datetime,
            rdb_mv_refresh_status;
        CLOSE c_mv_status;
        OPEN p_account_payroll FOR WITH transhistory AS (
                                       SELECT
                                           t.*,
                                           ROW_NUMBER() OVER(
                                               PARTITION BY t.document
                                               ORDER BY
                                                   t.seq_num
                                           ) seq_group
                                       FROM
                                           (
                                               SELECT
                                                   fgbtrnh_doc_code       AS document,
                                                   fgbtrnh_doc_seq_code   AS document_type,
                                                   fgbtrnd_ledger_ind     AS ledger_ind,
                                                   fgbtrnd_field_code     AS field_code,
                                                   fgbtrnd_coas_code      AS chart_of_accounts,
                                                   fgbtrnd_fund_code      AS fund,
                                                   fgbtrnd_acct_code      AS account,
                                                   nvl(fgbtrnd_trans_amt,0) AS transaction_amount,
                                                   fgbtrnh_trans_date     AS transaction_date,
                                                   fgbtrnh_trans_desc     AS transaction_desc,
                                                   fgbtrnd_prog_code      AS program,
                                                   fgbtrnd_orgn_code      AS organization_code,
                                                   fgbtrnh_doc_ref_num    AS stucwid,
                                                   fgbtrnh_seq_num        AS seq_num
                                               FROM
                                                   fimsmgr.fgbtrnh,
                                                   fimsmgr.fgbtrnd
                                               WHERE
                                                   fgbtrnh_doc_seq_code = fgbtrnd_doc_seq_code (+)
                                                   AND fgbtrnh_doc_code = fgbtrnd_doc_code (+)
                                                   AND fgbtrnh_submission_number = fgbtrnd_submission_number (+)
                                                   AND fgbtrnh_item_num = fgbtrnd_item_num (+)
                                                   AND fgbtrnh_seq_num = fgbtrnd_seq_num (+)
                                                   AND fgbtrnh_serial_num = fgbtrnd_serial_num (+)
                                                   AND fgbtrnh_reversal_ind = fgbtrnd_reversal_ind (+)
                                                   AND fgbtrnd_ledger_ind = c_letter_o
                                                   AND fgbtrnd_field_code = c_number_three
                                                   AND NOT ( fgbtrnd_acct_code LIKE c_no_rdb_account )
                                                   AND fgbtrnd_fund_code = v_fundid
                                                   AND fgbtrnd_acct_code = v_acctid
                                                   AND ( ( fgbtrnh_trans_date <= rdb_mv_refresh_datetime
                                                           AND v_source = c_materializedview ) --if materialized view data is needed, get data older then MV refreshment
                                                         OR v_source = c_realtime_data ) -- if realtime data is needed, get all data
                                           ) t
                                   ),payroll AS (
                                       SELECT
                                           posnctl.nhrdist.nhrdist_fund_code   AS fund_code,
                                           posnctl.nhrdist.nhrdist_acct_code   AS account,
                                           posnctl.nhrdist.nhrdist_doc_code    AS document,
                                           f_format_name(posnctl.nhrdist.nhrdist_pidm,'LFIMI30') AS username,
                                           ( CASE
                                               WHEN posnctl.nhrdist.nhrdist_dr_cr_ind = 'C' THEN posnctl.nhrdist.nhrdist_amt * (-1
                                               )
                                               WHEN posnctl.nhrdist.nhrdist_dr_cr_ind = 'D' THEN posnctl.nhrdist.nhrdist_amt
                                               ELSE posnctl.nhrdist.nhrdist_amt
                                           END ) AS amount,
                                           ( CASE nvl(posnctl.nhrdist.nhrdist_seq_no,0)
                                               WHEN 0   THEN 1
                                               ELSE posnctl.nhrdist.nhrdist_seq_no
                                           END ) AS seq_no
                                       FROM
                                           posnctl.nhrdist
                                       WHERE
                                           posnctl.nhrdist.nhrdist_fund_code = v_fundid
                                           AND posnctl.nhrdist.nhrdist_acct_code = v_acctid
                                           AND posnctl.nhrdist.nhrdist_dr_cr_ind IN (
                                               'C',
                                               'D'
                                           )
                                           AND posnctl.nhrdist.nhrdist_trans_date <= TO_DATE('12/31/2099','MM/DD/YYYY')
----                                       AND ( nhrdist_acct_code LIKE c_rdb_account1
----                                             OR nhrdist_acct_code LIKE c_rdb_account2
----                                             OR nhrdist_acct_code LIKE c_rdb_account3
----                                             OR nhrdist_acct_code LIKE c_rdb_account4
----                                             OR nhrdist_acct_code LIKE c_rdb_account5 )
                                           AND posnctl.nhrdist.nhrdist_doc_code LIKE c_valid_doc
                                   ),payroll_seq AS (
                                       SELECT
                                           t.*,
                                           ROW_NUMBER() OVER(
                                               PARTITION BY t.document
                                               ORDER BY
                                                   t.seq_no
                                           ) seq_group
                                       FROM
                                           (
                                               SELECT DISTINCT
                                                   seq_no,
                                                   document
                                               FROM
                                                   payroll
                                           ) t
                                   )
                                   SELECT
                                       transhistory_payroll.document,
                                       transhistory_payroll.seq_group,
                                       payroll.username,
                                       payroll.amount
                                   FROM
                                       (
                                           SELECT DISTINCT
                                               document,
                                               chart_of_accounts,
                                               account,
                                               fund,
                                               transaction_amount,
                                               seq_group
                                           FROM
                                               transhistory
                                       ) transhistory_payroll
                                       LEFT OUTER JOIN fimsmgr.ftvacct ON transhistory_payroll.chart_of_accounts = ftvacct.ftvacct_coas_code
                                                                          AND transhistory_payroll.account = ftvacct.ftvacct_acct_code
                                       INNER JOIN payroll_seq ON transhistory_payroll.document = payroll_seq.document
                                                                 AND transhistory_payroll.seq_group = payroll_seq.seq_group
                                       INNER JOIN payroll ON transhistory_payroll.fund = payroll.fund_code
                                                             AND transhistory_payroll.account = payroll.account
                                                             AND transhistory_payroll.document = payroll.document
                                                                 -- AND transhistory_payroll.seq_group = payroll.seq_no
                                                             AND payroll.seq_no = payroll_seq.seq_no
                                   WHERE
                                       ftvacct.ftvacct_nchg_date = TO_DATE(c_active_date,c_date_format)
                                       AND transhistory_payroll.document = nvl(v_doc,transhistory_payroll.document)
--                                   UNION ALL
--                                   SELECT
--                                       transhistory.document,
--                                       1,
--                                       f_format_name(saturn.spriden.spriden_pidm,'LFIMI30') AS username,
--                                       transhistory.transaction_amount   AS amount
--                                   FROM
--                                       transhistory
--                                       LEFT OUTER JOIN saturn.spriden ON transhistory.stucwid = saturn.spriden.spriden_id
--                                   WHERE
--                                       ( saturn.spriden.spriden_change_ind IS NULL )
--                                       AND ( transhistory.document LIKE 'SC%'
--                                             OR transhistory.document LIKE 'SR%'
--                                             OR transhistory.document LIKE 'HS%' )
                                   ORDER BY
                                       document,
                                       username;

    END;
    
    PROCEDURE uah_p_cogr_rdb_orgnization (
        v_pidm  IN   VARCHAR2,
        p_orgs  OUT  SYS_REFCURSOR
    ) IS

        c_letter_a     CHAR(1) := 'A';
        c_active_date  DATE := TO_DATE('12/31/2099', 'MM/DD/YYYY');
        c_seperator    CHAR(3) := ' - ';
    BEGIN
        OPEN p_orgs FOR SELECT DISTINCT
                            risdash.rdborgnmap.rdborgnmap_orgn_code                                                            AS orgcode,
                            risdash.rdborgnmap.rdborgnmap_orgn_code
                            || c_seperator
                            || fimsmgr.ftvorgn.ftvorgn_title            AS orgtitle,
                            fimsmgr.ftvorgn.ftvorgn_title                                                                      orgdesp
                        FROM
                                 risdash.rdborgnmap
                            INNER JOIN fimsmgr.ftvorgn ON risdash.rdborgnmap.rdborgnmap_orgn_code = fimsmgr.ftvorgn.ftvorgn_orgn_code
                        WHERE
                                risdash.rdborgnmap.rdborgnmap_pidm = v_pidm
                            AND risdash.rdborgnmap.rdborgnmap_nchg_date = c_active_date
                            AND fimsmgr.ftvorgn.ftvorgn_nchg_date = c_active_date
                            AND fimsmgr.ftvorgn.ftvorgn_coas_code = c_letter_a
                        ORDER BY
                            orgdesp;

    END;

    PROCEDURE uah_p_cogr_rdb_getdeans (
        p_deans OUT SYS_REFCURSOR
    ) IS

        c_active_date  DATE := TO_DATE('12/31/2099', 'MM/DD/YYYY');
        c_seperator    CHAR(3) := ' - ';
        c_nameformat   CHAR(7) := 'LFIMI30';
    BEGIN
        OPEN p_deans FOR SELECT DISTINCT
                             risdash.rdborgnmap.rdborgnmap_pidm                                                                                   AS pidm,
                             saturn.spriden.spriden_id
                             || ' - '
                             || f_format_name(risdash.rdborgnmap.rdborgnmap_pidm, c_nameformat)                 AS deanuser,
                             f_format_name(risdash.rdborgnmap.rdborgnmap_pidm, c_nameformat)                                                     AS username,
                             saturn.spriden.spriden_id                                                                                            AS cwid
                         FROM
                             risdash.rdborgnmap
                             LEFT OUTER JOIN saturn.spriden ON risdash.rdborgnmap.rdborgnmap_pidm = saturn.spriden.spriden_pidm
                         WHERE
                                 risdash.rdborgnmap.rdborgnmap_nchg_date = c_active_date
                             AND saturn.spriden.spriden_change_ind IS NULL
                         ORDER BY
                             username;

    END;

    PROCEDURE uah_p_cogr_rdb_insert_deanorg (
        v_pidm    IN   VARCHAR2,
        v_org     IN   VARCHAR2,
        p_result  OUT  SYS_REFCURSOR
    ) IS

        c_active_date  DATE := TO_DATE('12/31/2099', 'MM/DD/YYYY');
        user_count     INTEGER := 0;
        org_count      INTEGER := 0;
        c_letter_a     CHAR(1) := 'A';
    BEGIN
        SELECT
            COUNT(*)
        INTO user_count
        FROM
            risdash.rdborgnmap
        WHERE
                rdborgnmap_pidm = v_pidm
            AND rdborgnmap_orgn_code = v_org
            AND rdborgnmap_nchg_date = c_active_date;

        SELECT
            COUNT(*)
        INTO org_count
        FROM
            fimsmgr.ftvorgn
        WHERE
                fimsmgr.ftvorgn.ftvorgn_orgn_code = v_org
            AND fimsmgr.ftvorgn.ftvorgn_nchg_date = c_active_date
            AND fimsmgr.ftvorgn.ftvorgn_coas_code = c_letter_a;

        IF (
            user_count = 0 AND org_count > 0
        ) THEN
            BEGIN
                INSERT INTO risdash.rdborgnmap (
                    rdborgnmap_pidm,
                    rdborgnmap_orgn_code,
                    rdborgnmap_eff_date,
                    rdborgnmap_nchg_date
                ) VALUES (
                    v_pidm,
                    v_org,
                    sysdate,
                    c_active_date
                );

                OPEN p_result FOR SELECT
                                     'SUCCESS' AS result
                                 FROM
                                     dual;

            END;
        ELSE
            BEGIN
                IF user_count > 0 THEN
                    BEGIN
                        OPEN p_result FOR SELECT
                                              'ORG_EXIST' AS result
                                          FROM
                                              dual;

                    END;
                ELSIF org_count = 0 THEN
                    BEGIN
                        OPEN p_result FOR SELECT
                                              'ORG_ERROR' AS result
                                          FROM
                                              dual;

                    END;
                END IF;

            END;
        END IF;

    END;

    PROCEDURE uah_p_cogr_rdb_expire_deanorg (
        v_pidm    IN   VARCHAR2,
        v_org     IN   VARCHAR2,
        p_result  OUT  SYS_REFCURSOR
    ) IS
        c_active_date  DATE := TO_DATE('12/31/2099', 'MM/DD/YYYY');
        user_count     INTEGER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO user_count
        FROM
            risdash.rdborgnmap
        WHERE
                rdborgnmap_pidm = v_pidm
            AND rdborgnmap_orgn_code = v_org
            AND rdborgnmap_nchg_date = c_active_date;

        IF user_count > 0 THEN
            BEGIN
                UPDATE risdash.rdborgnmap
                SET
                    rdborgnmap_nchg_date = sysdate
                WHERE
                        rdborgnmap_pidm = v_pidm
                    AND rdborgnmap_orgn_code = v_org
                    AND rdborgnmap_nchg_date = c_active_date;

                OPEN p_result FOR SELECT
                                     'SUCCESS' AS result
                                 FROM
                                     dual;

            END;

        ELSE
            BEGIN
                OPEN p_result FOR SELECT
                                      'NON_EXIST' AS result
                                  FROM
                                      dual;

            END;
        END IF;

    END;

    PROCEDURE uah_p_cogr_rdb_copy_deanorg (
        v_source_pidm  IN   VARCHAR2,
        v_dest_pidm    IN   VARCHAR2,
        p_result       OUT  SYS_REFCURSOR
    ) IS
        c_active_date DATE := TO_DATE('12/31/2099', 'MM/DD/YYYY');
    BEGIN
        INSERT INTO risdash.rdborgnmap (
            rdborgnmap_pidm,
            rdborgnmap_orgn_code,
            rdborgnmap_eff_date,
            rdborgnmap_nchg_date
        )
            SELECT
                v_dest_pidm,
                rdborgnmap_orgn_code,
                sysdate,
                rdborgnmap_nchg_date
            FROM
                (
                    SELECT
                        rdborgnmap_orgn_code,
                        sysdate,
                        rdborgnmap_nchg_date
                    FROM
                        risdash.rdborgnmap
                    WHERE
                            risdash.rdborgnmap.rdborgnmap_pidm = v_source_pidm
                        AND risdash.rdborgnmap.rdborgnmap_nchg_date = c_active_date
                        AND NOT rdborgnmap_orgn_code IN (
                            SELECT
                                rdborgnmap_orgn_code
                            FROM
                                risdash.rdborgnmap
                            WHERE
                                    risdash.rdborgnmap.rdborgnmap_pidm = v_dest_pidm
                                AND risdash.rdborgnmap.rdborgnmap_nchg_date = c_active_date
                        )
                ) difforgs;

        OPEN p_result FOR SELECT
                             'SUCCESS' AS result
                         FROM
                             dual;

    END;
-- PROCEDURE uah_p_cogr_rdb_note_policies
-- (
--  v_creator IN varchar2,
--  p_note_policies OUT SYS_REFCURSOR
-- )
-- AS
-- BEGIN
--    OPEN p_note_policies FOR
--        select GENERAL.GURTKLR.GURTKLR_COMMENT as MESSAGE from GENERAL.GURTKLR
--        where
--            (GENERAL.GURTKLR.GURTKLR_CREATOR = REGEXP_SUBSTR(v_creator,'[^,]+')
--            or GENERAL.GURTKLR.GURTKLR_CREATOR = substr(v_creator, length(REGEXP_SUBSTR(v_creator,'[^,]+')) +2))
--            and GENERAL.GURTKLR.GURTKLR_SYSTEM_IND ='U'
--            and GENERAL.GURTKLR.GURTKLR_USER_ID = 'CR_PROD_FINANCE'
--            and GENERAL.GURTKLR.GURTKLR_TODO_DATE >= sysdate
--            and GENERAL.GURTKLR.GURTKLR_CONFID_IND = 'Y';
-- END;

    FUNCTION f_format_name (
        pidm       NUMBER,
        name_type  VARCHAR2
    ) RETURN VARCHAR2
--
-- FILE NAME..: sufname.sql
-- RELEASE....: 8.5.2
-- OBJECT NAME: f_format_name
-- PRODUCT....: GENERAL
-- USAGE......: This function return a formatted Legal Name.
-- COPYRIGHT..: Copyright Ellucian 2001 - 2012.
--
-- DESCRIPTION:
--
--  Ths function return a formatted Legal Name.
--
--  Functions:
--    F_FORMAT_NAME
--       Ths function return a formatted Legal Name.
--
--
-- DESCRIPTION END

/*                                                                */
/* This routine formats a spriden name into one of several types: */
/*                                                                */
/*	LF30 - Last name, first name for 30 characters                */
/*	L30 -  Last name for 30 characters                            */
/*  L60 -  Last name for 60 characters                            */
/*	FL30 - First name, last name for 30 characters                */
/*	FL   - First name last name                                   */
/*	FMIL - First name, middle initial, last name                  */
/*	FML  - First name, middle name, last name                     */
/*  LF   - Last name, first name                                  */
/*	LFMI - Last name, first name, middle initial                  */
/*	LFM  - Last name, first name, middle                          */
/*  LFIMI30 - Last name, first name initial, middle name initial  */
/*            for 30 characters                                   */
/*                                                                */ AS

        surname_prefix  spriden.spriden_surname_prefix%TYPE := NULL;
--last_name                 SPRIDEN.SPRIDEN_LAST_NAME%TYPE := null;
        last_name       VARCHAR2(121);
        first_name      spriden.spriden_first_name%TYPE := NULL;
        mi              spriden.spriden_mi%TYPE := NULL;
        hold_mi         spriden.spriden_mi%TYPE := NULL;
        entity_ind      VARCHAR2(1) := NULL;
        hold_name       VARCHAR2(246) := NULL;
        trunc_from_mi   NUMBER := 0;
        work_len_mi     NUMBER := 0;
        work_len_last   NUMBER := 0;
        work_length     NUMBER := 0;
        CURSOR get_spriden IS
        SELECT
            spriden_surname_prefix,
            spriden_last_name,
            spriden_first_name,
            spriden_mi,
            spriden_mi,
            spriden_entity_ind,
            nvl(length(spriden_last_name), 0),
            nvl(length(spriden_mi), 0)
        FROM
            spriden
        WHERE
            spriden_change_ind IS NULL
            AND spriden_pidm = pidm;
--

    BEGIN
        OPEN get_spriden;
        FETCH get_spriden INTO
            surname_prefix,
            last_name,
            first_name,
            mi,
            hold_mi,
            entity_ind,
            work_len_last,
            work_len_mi;

        IF get_spriden%notfound THEN
            hold_name := g$_nls.get('SUFNAME-0000', 'SQL', 'NAME NOT FOUND FOR PIDM: %01%', pidm);
            GOTO close_up;
        END IF;

        IF entity_ind = 'C' THEN
            GOTO corporate_format_routine;
        END IF;
        << person_format_routine >> IF name_type IS NULL THEN
            hold_name := g$_nls.get('SUFNAME-0001', 'SQL', '**** INVALID NAME TYPE ****');
            GOTO close_up;
        END IF;
--
--IF surname_prefix IS NOT NULL THEN
---- prepend surname prefix if required
--  IF GB_DISPLAYMASK.F_SSB_FORMAT_NAME() = 'Y' THEN
--    last_name     := surname_prefix || ' ' || last_name;
--    work_len_last := length(last_name);
---- prior to the surname prefix, the longest value returned was
---- 182 characters: first space middle space last (60+1+60+1+60).
---- If the entire name returned is greater than 182, then truncate the
---- needed number of characters from the middle name to fit into 182
---- characters.
--    hold_name := first_name || ' ' || mi || ' ' || last_name;
--    IF length(hold_name) > 182 THEN
--      trunc_from_mi := length(hold_name) - 182;
--      IF trunc_from_mi > 59 THEN
--        mi := NULL;
--        work_len_mi := 0;
--      ELSE
--        mi := SUBSTR(mi,1,60 - trunc_from_mi);
--      END IF;
--    END IF;
--  END IF;
--END IF;
--

        IF name_type = 'LFMI' THEN
            IF work_len_mi = 0 THEN
                hold_name := last_name
                             || ', '
                             || first_name;
            ELSE
                hold_name := last_name
                             || ', '
                             || first_name
                             || ' '
                             || substr(mi, 1, 1)
                             || '.';
            END IF;
        END IF;
--

        IF name_type = 'LF' THEN
            hold_name := last_name
                         || ', '
                         || first_name;
        END IF;
--

        IF name_type = 'LFM' THEN
            hold_name := last_name
                         || ', '
                         || first_name;
            IF hold_mi IS NOT NULL THEN
                hold_name := hold_name
                             || ' '
                             || hold_mi;
            END IF;

        END IF;
--

        IF name_type = 'FML' THEN
            IF work_len_mi = 0 THEN
                hold_name := first_name
                             || ' '
                             || last_name;
            ELSE
                hold_name := first_name
                             || ' '
                             || mi
                             || ' '
                             || last_name;
            END IF;
        END IF;

        IF name_type = 'FMIL' THEN
            IF work_len_mi = 0 THEN
                hold_name := first_name
                             || ' '
                             || last_name;
            ELSE
                hold_name := first_name
                             || ' '
                             || substr(mi, 1, 1)
                             || '. '
                             || last_name;
            END IF;
        END IF;

        IF name_type = 'FL' THEN
            hold_name := first_name
                         || ' '
                         || last_name;
        END IF;

        work_length := 30 - work_len_last;
        IF name_type = 'LF30' THEN
            IF work_length < 4 THEN
                hold_name := substr(last_name, 1, 27)
                             || ', '
                             || substr(first_name, 1, 1);

            ELSE
                hold_name := last_name
                             || ', '
                             || substr(first_name, 1,(work_length - 2));
            END IF;
        END IF;

        IF name_type = 'FL30' THEN
            IF work_length < 4 THEN
                hold_name := substr(first_name, 1, 2)
                             || ' '
                             || substr(last_name, 1, 27);

            ELSE
                hold_name := substr(first_name, 1,(work_length - 1))
                             || ' '
                             || last_name;
            END IF;
        END IF;

        IF name_type = 'L30' THEN
            hold_name := substr(last_name, 1, 30);
        END IF;

        IF name_type = 'L60' THEN
            hold_name := substr(last_name, 1, 60);
        END IF;
--

        work_length := 30;
        IF name_type = 'LFIMI30' THEN
            IF (
                work_len_mi > 0 AND first_name IS NOT NULL
            ) THEN
                hold_name := ', '
                             || substr(first_name, 1, 1)
                             || substr(mi, 1, 1);
            ELSIF (
                work_len_mi > 0 AND first_name IS NULL
            ) THEN
                hold_name := ', '
                             || substr(mi, 1, 1);
            ELSIF (
                work_len_mi = 0 AND first_name IS NOT NULL
            ) THEN
                hold_name := ', '
                             || substr(first_name, 1, 1);
            ELSE
                hold_name := NULL;
            END IF;

            work_length := 30 - length(hold_name);
            IF ( work_length >= work_len_last ) THEN
                hold_name := last_name || hold_name;
            ELSE
                hold_name := substr(last_name, 1, work_length)
                             || hold_name;
            END IF;

        END IF;
--

        GOTO close_up;
        << corporate_format_routine >> IF name_type = 'L30' THEN
            hold_name := substr(last_name, 1, 30);
        ELSIF name_type = 'L60' THEN
            hold_name := substr(last_name, 1, 60);
        ELSE
            hold_name := last_name;
        END IF;

        << close_up >> CLOSE get_spriden;
        RETURN hold_name;
    END;

    FUNCTION         getfundorg (
        v_fundcode IN fimsmgr.ftvorgn.ftvorgn_fund_code_def%TYPE
    ) RETURN fimsmgr.ftvorgn.ftvorgn_orgn_code%TYPE IS
        v_orgn fimsmgr.ftvorgn.ftvorgn_orgn_code%TYPE := '';
    BEGIN
        SELECT
            ftvorgn_orgn_code
        INTO v_orgn
        FROM
            (
                SELECT DISTINCT
                    ftvorgn_coas_code,
                    ftvorgn_orgn_code,
                    ftvorgn_fund_code_def,
                    MAX(ftvorgn_eff_date) OVER(PARTITION BY ftvorgn_coas_code, ftvorgn_orgn_code, ftvorgn_fund_code_def) AS "latest_eff_date"
                FROM
                    fimsmgr.ftvorgn
                WHERE
                    ftvorgn_nchg_date IS NOT NULL
                    AND ftvorgn_eff_date IS NOT NULL
                    AND ftvorgn_fund_code_def IS NOT NULL
                    AND ftvorgn_orgn_code IS NOT NULL
                    AND ftvorgn_fund_code_def = v_fundcode
            )
        WHERE ROWNUM=1;

        RETURN v_orgn;
    END;
END uah_k_cogr_research_dashboard;

/
