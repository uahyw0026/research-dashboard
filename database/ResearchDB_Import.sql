DROP PACKAGE RISDASH.UAH_K_RESEARCHDB_IMPORT;

CREATE OR REPLACE PACKAGE RISDASH.UAH_K_RESEARCHDB_IMPORT
AS
    PROCEDURE ImportProposal (v_filename     IN     VARCHAR2,
                              v_importUser   IN     VARCHAR2,
                              v_strOutput       OUT VARCHAR2,
                              v_strflag         OUT NUMBER);

    --    PROCEDURE ImportAward (v_filename     IN     VARCHAR2,
    --                           v_importUser   IN     CHAR,
    --                           v_strOutput       OUT VARCHAR2,
    --                           v_strflag         OUT CHAR);


    PROCEDURE Reset_Sequence (p_seq_name    IN     VARCHAR2,
                              p_val         IN     NUMBER DEFAULT 0,
                              v_strOutput      OUT VARCHAR2,
                              v_strflag        OUT NUMBER);

    PROCEDURE logImportErrorBeforeExit (
        v_error_description   IN VARCHAR2,
        v_error_code          IN VARCHAR2,
        v_lastImportID        IN RISDASH.IMPORTRECORD.UNIQUEKEY%TYPE);

    PROCEDURE HANDLEERROR (ERRORCODE NUMBER, MSG VARCHAR2);
END UAH_K_RESEARCHDB_IMPORT;
/

DROP PACKAGE BODY RISDASH.UAH_K_RESEARCHDB_IMPORT;

CREATE OR REPLACE PACKAGE BODY RISDASH.UAH_K_RESEARCHDB_IMPORT
AS
    PROCEDURE ImportProposal (v_filename     IN     VARCHAR2,
                              v_importUser   IN     VARCHAR2,
                              v_strOutput       OUT VARCHAR2,
                              v_strflag         OUT NUMBER)
    IS
        v_PROPOSALID           NUMBER (18);
        v_PROPOSALNUM          CHAR (8 CHAR);
        v_PROPOSALTITLE        VARCHAR2 (500 CHAR);
        v_ANUM                 CHAR (9 CHAR);
        v_LASTNAME             VARCHAR2 (60 CHAR);
        v_FIRSTNAME            VARCHAR2 (60 CHAR);
        v_MIDDLENAME           VARCHAR2 (60 CHAR);
        v_HOMEUNIT             CHAR (6 CHAR);
        v_HOMEUNITNAME         VARCHAR2 (255 CHAR);
        v_HOMEUNITPARENT       CHAR (6 CHAR);
        v_HOMEUNITPARENTNAME   VARCHAR2 (255 CHAR);
        v_LEADUNIT             CHAR (6 CHAR);
        v_LEADUNITNAME         VARCHAR2 (255 CHAR);
        v_LEADUNITPARENT       CHAR (6 CHAR);
        v_LEADUNITPARENTNAME   VARCHAR2 (255 CHAR);
        v_SPONSORNAME          VARCHAR2 (500 CHAR);
        v_PROPOSALCOST         NUMBER (18, 2);
        v_PROPOSALSUBMITDATE   DATE;
        v_PROPOSALSTARTDATE    DATE;
        v_PROPOSALENDDATE      DATE;
        v_IMPORTLINENUMBER     NUMBER;
        v_sys_error            NUMBER := 0;

        v_error_description    VARCHAR2 (100);
        v_error_code           NUMBER (5) := 1;
        v_import_type          VARCHAR2 (20) := 'PROPOSAL';  --Proposal Import
        v_lastImportID         RISDASH.IMPORTRECORD.UNIQUEKEY%TYPE := 0;
        v_validate_msg         VARCHAR2 (100);
        v_validate_flag        CHAR := '0';
        v_totalrecords         NUMBER (20) := 0;

        CURSOR curProposal IS
            SELECT PROPOSALID,
                   PROPOSALNUM,
                   PROPOSALTITLE,
                   ANUM,
                   LASTNAME,
                   FIRSTNAME,
                   MIDDLENAME,
                   HOMEUNIT,
                   HOMEUNITNAME,
                   HOMEUNITPARENT,
                   HOMEUNITPARENTNAME,
                   LEADUNIT,
                   LEADUNITNAME,
                   LEADUNITPARENT,
                   LEADUNITPARENTNAME,
                   SPONSORNAME,
                   PROPOSALCOST,
                   PROPOSALSUBMITDATE,
                   PROPOSALSTARTDATE,
                   PROPOSALENDDATE,
                   IMPORTLINENUMBER
              FROM TempProposal;
    BEGIN
        BEGIN
            -- add validation rules later with traverse curProposal cursor

            INSERT INTO importrecord (importdate,
                                      importuser,
                                      filepath,
                                      status,
                                      filetype)
                 VALUES (SYSDATE,
                         v_importUser,
                         v_filename,
                         'STARTED',
                         v_import_type);

            EXECUTE IMMEDIATE 'commit';

            SELECT NVL (MAX (uniquekey), 0)
              INTO v_lastImportID
              FROM ImportRecord
             WHERE filetype = v_import_type AND importuser = v_importUser;
        EXCEPTION
            WHEN OTHERS
            THEN
                v_sys_error := SQLCODE;
        END;

        IF v_sys_error <> 0
        THEN
            BEGIN
                v_strOutput :=
                       'Proposal Import error with Error code '
                    || TO_CHAR (v_sys_error);
                v_strflag := 0;

                logImportErrorBeforeExit (v_strOutput,
                                          v_error_code,
                                          v_lastImportID);

                RETURN;
            END;
        END IF;

        -- insert or update rdborgn table with home unit, homeparent unit data for proposal import
        BEGIN
            MERGE INTO RDBorgn D
                 USING (SELECT DISTINCT homeunit, homeunitname
                          FROM tempproposal) S
                    ON (D.UNITNUMBER = S.homeunit)
            WHEN NOT MATCHED
            THEN
                INSERT     (UNITNUMBER, UNITNAME)
                    VALUES (S.homeunit, S.homeunitname);
        EXCEPTION
            WHEN OTHERS
            THEN
                v_strOutput :=
                       'Merge home unit records into table rdborgn is failed  due to SQL Error '
                    || SQLCODE;
                v_strflag := '0';
                logImportErrorBeforeExit (v_strOutput,
                                          v_error_code,
                                          v_lastImportID);
                RETURN;
        END;

        -- insert or update rdborgn table with homeparent unit data for proposal import
        BEGIN
            MERGE INTO RDBorgn D
                 USING (SELECT DISTINCT homeunitparent, homeunitparentname
                          FROM tempproposal) S
                    ON (D.UNITNUMBER = S.homeunitparent)
            WHEN NOT MATCHED
            THEN
                INSERT     (UNITNUMBER, UNITNAME)
                    VALUES (S.homeunitparent, S.homeunitparentname);
        EXCEPTION
            WHEN OTHERS
            THEN
                v_strOutput :=
                       'Merge home unit parent records into table rdborgn is failed  due to SQL Error '
                    || SQLCODE;
                v_strflag := '0';
                logImportErrorBeforeExit (v_strOutput,
                                          v_error_code,
                                          v_lastImportID);
                RETURN;
        END;

        -- insert or update rdborgn table with home unit, homeparent unit data for proposal import
        BEGIN
            MERGE INTO RDBorgn D
                 USING (SELECT DISTINCT leadunit, leadunitname
                          FROM tempproposal) S
                    ON (D.UNITNUMBER = S.leadunit)
            WHEN NOT MATCHED
            THEN
                INSERT     (UNITNUMBER, UNITNAME)
                    VALUES (S.leadunit, S.leadunitname);
        EXCEPTION
            WHEN OTHERS
            THEN
                v_strOutput :=
                       'Merge lead unit records into table rdborgn is failed  due to SQL Error '
                    || SQLCODE;
                v_strflag := '0';
                logImportErrorBeforeExit (v_strOutput,
                                          v_error_code,
                                          v_lastImportID);
                RETURN;
        END;

        -- insert or update rdborgn table with homeparent unit data for proposal import
        BEGIN
            MERGE INTO RDBorgn D
                 USING (SELECT DISTINCT leadunitparent, leadunitparentname
                          FROM tempproposal) S
                    ON (D.UNITNUMBER = S.leadunitparent)
            WHEN NOT MATCHED
            THEN
                INSERT     (UNITNUMBER, UNITNAME)
                    VALUES (S.leadunitparent, S.leadunitparentname);
        EXCEPTION
            WHEN OTHERS
            THEN
                v_strOutput :=
                       'Merge lead unit parent records into table rdborgn is failed  due to SQL Error '
                    || SQLCODE;
                v_strflag := '0';
                logImportErrorBeforeExit (v_strOutput,
                                          v_error_code,
                                          v_lastImportID);
                RETURN;
        END;

        -- insert or update tblemployee based PI import employee data for user
        BEGIN
            MERGE INTO Employee D
                 USING (SELECT DISTINCT ANUM,
                                        LASTNAME,
                                        FIRSTNAME,
                                        MIDDLENAME,
                                        HOMEUNIT,
                                        HOMEUNITPARENT
                          FROM tempproposal) S
                    ON (D.ANUM = S.ANUM)
            WHEN MATCHED
            THEN
                UPDATE SET
                    LastName =
                        (CASE
                             WHEN D.isfromImport = 'n' THEN S.lastName
                             WHEN D.isfromImport = 'y' THEN D.LastName
                         END),
                    FirstName =
                        (CASE
                             WHEN D.isfromImport = 'n' THEN S.firstName
                             WHEN D.isfromImport = 'y' THEN D.FirstName
                         END),
                    MiddleName =
                        (CASE
                             WHEN D.isfromImport = 'n' THEN S.middlename
                             WHEN D.isfromImport = 'y' THEN D.middlename
                         END),
                    unitCode = S.HOMEUNIT,
                    unitparentcode = S.HOMEUNITPARENT,
                    updateDate = SYSDATE
            WHEN NOT MATCHED
            THEN
                INSERT     (ANUM,
                            LastName,
                            FirstName,
                            MiddleName,
                            UNITCode,
                            unitparentcode,
                            updateDate,
                            IsfromImport)
                    VALUES (S.anum,
                            S.lastName,
                            S.firstName,
                            S.middlename,
                            S.homeunit,
                            S.homeunitparent,
                            SYSDATE,
                            'y');
        EXCEPTION
            WHEN OTHERS
            THEN
                v_strOutput :=
                       'Merge employee records into table employee is failed  due to SQL Error '
                    || SQLCODE;
                v_strflag := '0';
                logImportErrorBeforeExit (v_strOutput,
                                          v_error_code,
                                          v_lastImportID);
                RETURN;
        END;
        
        BEGIN
            MERGE INTO proposal D
                 USING (SELECT PROPOSALID,
                               PROPOSALNUM,
                               PROPOSALTITLE,
                               LEADUNIT,
                               LEADUNITPARENT,
                               SPONSORNAME,
                               PROPOSALCOST,
                               PROPOSALSUBMITDATE,
                               PROPOSALSTARTDATE,
                               PROPOSALENDDATE
                          FROM tempproposal) S
                    ON (D.PROPOSALID = S.PROPOSALID)
            WHEN NOT MATCHED
            THEN
                INSERT     (PROPOSALID,
                            PROPOSALNUM,
                            PROPOSALTITLE,
                            LEADUNIT,
                            LEADUNITPARENT,
                            SPONSORNAME,
                            PROPOSALCOST,
                            PROPOSALSUBMITDATE,
                            PROPOSALSTARTDATE,
                            PROPOSALENDDATE)
                    VALUES (S.PROPOSALID,
                            S.PROPOSALNUM,
                            S.PROPOSALTITLE,
                            S.LEADUNIT,
                            S.LEADUNITPARENT,
                            S.SPONSORNAME,
                            S.PROPOSALCOST,
                            S.PROPOSALSUBMITDATE,
                            S.PROPOSALSTARTDATE,
                            S.PROPOSALENDDATE);
        EXCEPTION
            WHEN OTHERS
            THEN
                v_strOutput :=
                       'Merge proposal records into table proposal is failed  due to SQL Error '
                    || SQLCODE;
                v_strflag := '0';
                logImportErrorBeforeExit (v_strOutput, v_error_code, v_lastImportID);
                RETURN;
        END;
        
        BEGIN
            MERGE INTO proposalpi D
                 USING (SELECT PROPOSALID, PROPOSALNUM, ANUM FROM tempproposal) S
                    ON (D.PROPOSALID = S.PROPOSALID)
            WHEN NOT MATCHED
            THEN
                INSERT     (PROPOSALID,
                            PROPOSALNUM,
                            ANUM,
                            CURRENTIND)
                    VALUES (S.PROPOSALID,
                            S.PROPOSALNUM,
                            S.ANUM,
                            'y');
        EXCEPTION
            WHEN OTHERS
            THEN
                v_strOutput :=
                       'Merge proposal PI records into table proposalPI is failed  due to SQL Error '
                    || SQLCODE;
                v_strflag := '0';
                logImportErrorBeforeExit (v_strOutput, v_error_code, v_lastImportID);
                RETURN;
        END;

        /*
              Proposal file is imported successfully
            */
        DECLARE
            v_recCount       NUMBER (18, 0) := 0;
            v_PROPOSALCOST   NUMBER (18, 2) := 0.0;
        BEGIN
            SELECT COUNT (*) INTO v_recCount FROM tempproposal;

            SELECT SUM (PROPOSALCOST) INTO v_PROPOSALCOST FROM tempproposal;

            --DELETE FROM TEMPPRoposal;

            UPDATE importrecord
               SET status = 'SUCCESS',
                   MESSAGE = 'Import proposal file is Successfil',
                   result = v_recCount,
                   TOTALIMPORTAMOUNT = v_PROPOSALCOST
             WHERE UNIQUEKEY = v_lastImportID;

            EXECUTE IMMEDIATE 'commit';
        -- backup to proposal backup table
        EXCEPTION
            WHEN OTHERS
            THEN
                v_sys_error := SQLCODE;
        END;

        IF v_sys_error <> 0
        THEN
            BEGIN
                v_strOutput :=
                       'Inserting a record into the table ImportRecord is failed  '
                    || ' due to SQL Error'
                    || v_sys_error;
                v_strflag := '0';
                logImportErrorBeforeExit (v_strOutput,
                                          v_error_code,
                                          v_lastImportID);
                RETURN;
            END;
        END IF;

        v_sys_error := 0;

        v_strOutput := 'Importing Proposal is successful';
        v_strflag := '1';
    EXCEPTION
        WHEN OTHERS
        THEN
            v_strOutput :=
                   'Proposal Import Error with SQL Code:'
                || TO_CHAR (SQLCODE)
                || ' and Error Message: '
                || SQLERRM;
            v_strflag := 0;
            logImportErrorBeforeExit (v_strOutput,
                                      v_error_code,
                                      v_lastImportID);
    END ImportProposal;

    PROCEDURE HANDLEERROR (ERRORCODE NUMBER, MSG VARCHAR2)
    IS
    BEGIN
        -- NOTE: Oracle raise_application_error will terminate normal code flow , which T-SQL raiserror does not.
        raise_application_error (-20002, ERRORCODE || ':' || MSG);
    --DBMS_OUTPUT.PUT_LINE(ERRORCODE||':'||MSG);
    END HANDLEERROR;

    PROCEDURE logImportErrorBeforeExit (
        v_error_description   IN VARCHAR2,
        v_error_code          IN VARCHAR2,
        v_lastImportID        IN RISDASH.IMPORTRECORD.UNIQUEKEY%TYPE)
    IS
    BEGIN
        INSERT INTO error (UNIQUEKEY, ERRORMESSAGE, ERRORCODE)
             VALUES (v_lastImportID, v_error_description, v_error_code);

        UPDATE importrecord
           SET status = 'FAIL', MESSAGE = v_error_description
         WHERE UNIQUEKEY = v_lastImportID;

        EXECUTE IMMEDIATE 'commit';
    EXCEPTION
        WHEN OTHERS
        THEN
            handleerror (SQLCODE, SQLERRM);
    END logImportErrorBeforeExit;

    PROCEDURE Reset_Sequence (p_seq_name    IN     VARCHAR2,
                              p_val         IN     NUMBER DEFAULT 0,
                              v_strOutput      OUT VARCHAR2,
                              v_strflag        OUT NUMBER)
    IS
        l_current      NUMBER := 0;
        l_difference   NUMBER := 0;
        l_minvalue     user_sequences.min_value%TYPE := 0;
        v_sys_error    NUMBER := 0;
    BEGIN
        SELECT min_value
          INTO l_minvalue
          FROM user_sequences
         WHERE sequence_name = p_seq_name;

        EXECUTE IMMEDIATE 'select ' || p_seq_name || '.nextval from dual'
            INTO l_current;

        IF p_Val < l_minvalue
        THEN
            l_difference := l_minvalue - l_current;
        ELSE
            l_difference := p_Val - l_current;
        END IF;

        IF l_difference = 0
        THEN
            v_strOutput := 'reset sequnce is successful';
            v_strflag := 1;
            RETURN;
        END IF;

        BEGIN
            EXECUTE IMMEDIATE   'alter sequence '
                             || p_seq_name
                             || ' increment by '
                             || l_difference
                             || ' minvalue '
                             || l_minvalue;

            EXECUTE IMMEDIATE 'select ' || p_seq_name || '.nextval from dual'
                INTO l_difference;

            EXECUTE IMMEDIATE   'alter sequence '
                             || p_seq_name
                             || ' increment by 1 minvalue '
                             || l_minvalue;
        EXCEPTION
            WHEN OTHERS
            THEN
                v_sys_error := SQLCODE;
        END;

        IF v_sys_error <> 0
        THEN
            BEGIN
                v_strOutput :=
                       'Proposal Import error with Error code '
                    || TO_CHAR (v_sys_error);
                v_strflag := 0;

                RETURN;
            END;
        ELSE
            BEGIN
                v_strOutput := 'reset sequnce is successful';
                v_strflag := 1;

                RETURN;
            END;
        END IF;
    END Reset_Sequence;
END UAH_K_RESEARCHDB_IMPORT;
/
