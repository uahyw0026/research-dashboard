create or replace FUNCTION RISDASH.getfundorg (
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
    WHERE
        ROWNUM = 1;

    RETURN v_orgn;
END;