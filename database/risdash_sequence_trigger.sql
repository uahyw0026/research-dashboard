CREATE SEQUENCE RISDASH.TEMPPROPOSAL_IMPORTLINENUMBER_SEQ
  START WITH 1
  MAXVALUE 999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
  NOKEEP
  NOSCALE
  GLOBAL;

CREATE OR REPLACE TRIGGER RISDASH.TEMPPROPOSAL_IMPORTLINENUMBE_1 BEFORE INSERT ON RISDASH.TEMPPROPOSAL
FOR EACH ROW
DECLARE 
v_newVal NUMBER(12) := 0;
v_incval NUMBER(12) := 0;
BEGIN
  IF INSERTING AND :new.ImportLineNumber IS NULL THEN
    SELECT  TempProposal_ImportLineNumber_seq.NEXTVAL INTO v_newVal FROM DUAL;
    -- If this is the first time this table have been inserted into (sequence == 1)
    IF v_newVal = 1 THEN 
      --get the max indentity value from the table
      SELECT NVL(max(ImportLineNumber),0) INTO v_newVal FROM TempProposal;
      v_newVal := v_newVal + 1;
      --set the sequence to that value
      LOOP
           EXIT WHEN v_incval>=v_newVal;
           SELECT TempProposal_ImportLineNumber_SEQ.nextval INTO v_incval FROM dual;
      END LOOP;
    END IF;
  
  :new.ImportLineNumber := v_newVal;
  END IF;
END;
/


CREATE SEQUENCE RISDASH.TEMPAWARD_IMPORTLINENUMBER_SEQ
  START WITH 1
  MAXVALUE 999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
  NOKEEP
  NOSCALE
  GLOBAL;

CREATE OR REPLACE TRIGGER RISDASH.TEMPAWARD_IMPORTLINENUMBE_1 BEFORE INSERT ON RISDASH.TEMPAWARD
FOR EACH ROW
DECLARE 
v_newVal NUMBER(12) := 0;
v_incval NUMBER(12) := 0;
BEGIN
  IF INSERTING AND :new.ImportLineNumber IS NULL THEN
    SELECT  TempAWARD_ImportLineNumber_seq.NEXTVAL INTO v_newVal FROM DUAL;
    -- If this is the first time this table have been inserted into (sequence == 1)
    IF v_newVal = 1 THEN 
      --get the max indentity value from the table
      SELECT NVL(max(ImportLineNumber),0) INTO v_newVal FROM TempAWARD;
      v_newVal := v_newVal + 1;
      --set the sequence to that value
      LOOP
           EXIT WHEN v_incval>=v_newVal;
           SELECT TempAWARD_ImportLineNumber_SEQ.nextval INTO v_incval FROM dual;
      END LOOP;
    END IF;
  
  :new.ImportLineNumber := v_newVal;
  END IF;
END;
/

CREATE SEQUENCE RISDASH.IMPORTRECORD_UNIQUEKEY_SEQ
  START WITH 1
  MAXVALUE 999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
  NOKEEP
  NOSCALE
  GLOBAL;

CREATE OR REPLACE TRIGGER RISDASH.IMPORTRECORD_UNIQUEKEY_TRG BEFORE INSERT ON RISDASH.IMPORTRECORD
FOR EACH ROW
DECLARE 
v_newVal NUMBER(12) := 0;
v_incval NUMBER(12) := 0;
BEGIN
  IF INSERTING AND :new.uniquekey IS NULL THEN
    SELECT  ImportRecord_uniquekey_SEQ.NEXTVAL INTO v_newVal FROM DUAL;
    -- If this is the first time this table have been inserted into (sequence == 1)
    IF v_newVal = 1 THEN 
      --get the max indentity value from the table
      SELECT NVL(max(uniquekey),0) INTO v_newVal FROM ImportRecord;
      v_newVal := v_newVal + 1;
      --set the sequence to that value
      LOOP
           EXIT WHEN v_incval>=v_newVal;
           SELECT ImportRecord_uniquekey_SEQ.nextval INTO v_incval FROM dual;
      END LOOP;
    END IF;

   :new.uniquekey := v_newVal;
  END IF;
END;
/