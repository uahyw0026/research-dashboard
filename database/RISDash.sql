DROP TABLE RISDASH.AWARD CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.AWARD
(
  AWARDNUM          CHAR(12 CHAR)               NOT NULL,
  FUNDAGREEMENTNUM  VARCHAR2(100 CHAR),
  AWARDTITLE        VARCHAR2(300 CHAR),
  ORGCODE           CHAR(6 CHAR),
  FUNDID            CHAR(5 CHAR),
  LEADUNIT          CHAR(6 CHAR)                NOT NULL,
  LEADUNITPARENT    CHAR(6 CHAR)                NOT NULL,
  SPONSORNAME       VARCHAR2(500 CHAR),
  AWARDEDAMOUNT     NUMBER(18,2)                NOT NULL,
  FUNDEDAMOUNT      NUMBER(18,2)                NOT NULL,
  AWARDDATE         DATE,
  AWARDSTARTDATE    DATE,
  AWARDENDDATE      DATE
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


CREATE UNIQUE INDEX RISDASH.PK_AWARD ON RISDASH.AWARD
(AWARDNUM)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

DROP TABLE RISDASH.AWARDPI CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.AWARDPI
(
  AWARDNUM    CHAR(12 CHAR)                     NOT NULL,
  ANUM        CHAR(9 CHAR)                      NOT NULL,
  CURRENTIND  CHAR(1 CHAR)                      NOT NULL
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


CREATE UNIQUE INDEX RISDASH.PK_AWARDPI ON RISDASH.AWARDPI
(AWARDNUM)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

DROP TABLE RISDASH.EMPLOYEE CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.EMPLOYEE
(
  ANUM          CHAR(9 CHAR)                    NOT NULL,
  LASTNAME      VARCHAR2(60 CHAR)               NOT NULL,
  FIRSTNAME     VARCHAR2(60 CHAR)               NOT NULL,
  MIDDLENAME    VARCHAR2(60 CHAR),
  EMAILADDRESS  VARCHAR2(100 CHAR)              NOT NULL,
  UNITCODE      CHAR(6 CHAR)                    NOT NULL,
  UPDATEDATE    DATE,
  ISFROMIMPORT  CHAR(1 CHAR)                    DEFAULT 'n'
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


CREATE UNIQUE INDEX RISDASH.PK_TBLEMPLOYEE ON RISDASH.EMPLOYEE
(ANUM)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

DROP TABLE RISDASH.ERROR CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.ERROR
(
  LINENUMBER    NUMBER(10),
  ERRORMESSAGE  VARCHAR2(800 CHAR),
  ERRORDATA     VARCHAR2(800 CHAR),
  ERRORCODE     NUMBER(5),
  UNIQUEKEY     NUMBER(18)
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


DROP TABLE RISDASH.FISCALYEAR CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.FISCALYEAR
(
  YEAR        NUMBER(4)                         NOT NULL,
  BEGINDATE   DATE                              NOT NULL,
  ENDDATE     DATE                              NOT NULL,
  UPDATEDATE  DATE
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


CREATE UNIQUE INDEX RISDASH.PK_FISCALYEAR ON RISDASH.FISCALYEAR
(YEAR)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

DROP TABLE RISDASH.IMPORTRECORD CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.IMPORTRECORD
(
  IMPORTDATE         DATE,
  IMPORTUSER         CHAR(8 CHAR)               NOT NULL,
  RESULT             VARCHAR2(50 CHAR),
  UNIQUEKEY          NUMBER(18)                 NOT NULL,
  FILEPATH           VARCHAR2(500 CHAR)         NOT NULL,
  TOTALIMPORTAMOUNT  NUMBER(18,2),
  FILETYPE           VARCHAR2(500 CHAR),
  STATUS             VARCHAR2(50 CHAR),
  MESSAGE            VARCHAR2(255 CHAR)
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


CREATE UNIQUE INDEX RISDASH.PK_IMPORTRECORD ON RISDASH.IMPORTRECORD
(UNIQUEKEY)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

DROP TABLE RISDASH.PROPOSAL CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.PROPOSAL
(
  PROPOSALID          NUMBER(18)                NOT NULL,
  PROPOSALNUM         CHAR(8 CHAR)              NOT NULL,
  PROPOSALTITLE       VARCHAR2(500 CHAR)        NOT NULL,
  LEADUNIT            CHAR(6 CHAR)              NOT NULL,
  LEADUNITPARENT      CHAR(6 CHAR)              NOT NULL,
  SPONSORNAME         VARCHAR2(500 CHAR),
  PROPOSALCOST        NUMBER(18,2)              NOT NULL,
  PROPOSALSUBMITDATE  DATE,
  PROPOSALSTARTDATE   DATE,
  PROPOSALENDDATE     DATE
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


CREATE UNIQUE INDEX RISDASH.PK_PROPOSAL ON RISDASH.PROPOSAL
(PROPOSALID)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

DROP TABLE RISDASH.PROPOSALPI CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.PROPOSALPI
(
  PROPOSALID   NUMBER(18)                       NOT NULL,
  PROPOSALNUM  CHAR(8 CHAR)                     NOT NULL,
  ANUM         CHAR(9 CHAR)                     NOT NULL,
  CURRENTIND   CHAR(1 CHAR)                     NOT NULL
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


CREATE UNIQUE INDEX RISDASH.PK_PROPOSALPI ON RISDASH.PROPOSALPI
(PROPOSALID)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

DROP TABLE RISDASH.RDBORGN CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.RDBORGN
(
  UNITNUMBER  CHAR(6 BYTE)                      NOT NULL,
  UNITNAME    VARCHAR2(250 CHAR)                NOT NULL,
  ORGPREFIX   VARCHAR2(6 CHAR)
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


CREATE UNIQUE INDEX RISDASH.RDBORGN_PK ON RISDASH.RDBORGN
(UNITNUMBER)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

ALTER TABLE RISDASH.RDBORGN ADD (
  CONSTRAINT RDBORGN_PK
  PRIMARY KEY
  (UNITNUMBER)
  USING INDEX RISDASH.RDBORGN_PK
  ENABLE VALIDATE);


DROP TABLE RISDASH.RDBORGNMAP CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.RDBORGNMAP
(
  RDBORGNMAP_PIDM       NUMBER(8)               NOT NULL,
  RDBORGNMAP_ORGN_CODE  VARCHAR2(6 CHAR)        NOT NULL,
  RDBORGNMAP_EFF_DATE   DATE                    NOT NULL,
  RDBORGNMAP_NCHG_DATE  DATE                    NOT NULL,
  RDBORGNMAP_CREATOR    VARCHAR2(9 CHAR)
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


DROP TABLE RISDASH.TEMPAWARD CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.TEMPAWARD
(
  AWARDNUM            CHAR(12 CHAR)             NOT NULL,
  FUNDAGREEMENTNUM    VARCHAR2(100 CHAR),
  AWARDTITLE          VARCHAR2(300 CHAR),
  ORGCODE             CHAR(6 CHAR),
  FUNDID              CHAR(5 CHAR),
  ANUM                CHAR(9 CHAR)              NOT NULL,
  LASTNAME            VARCHAR2(60 CHAR)         NOT NULL,
  FIRSTNAME           VARCHAR2(60 CHAR)         NOT NULL,
  MIDDLENAME          VARCHAR2(60 CHAR),
  HOMEUNIT            CHAR(6 CHAR)              NOT NULL,
  HOMEUNITNAME        VARCHAR2(255 CHAR)        NOT NULL,
  HOMEUNITPARENT      CHAR(6 CHAR),
  HOMEUNITPARENTNAME  VARCHAR2(255 CHAR),
  LEADUNIT            CHAR(6 CHAR)              NOT NULL,
  LEADUNITNAME        VARCHAR2(255 CHAR)        NOT NULL,
  LEADUNITPARENT      CHAR(6 CHAR)              NOT NULL,
  LEADUNITPARENTNAME  VARCHAR2(255 CHAR)        NOT NULL,
  SPONSORNAME         VARCHAR2(500 CHAR),
  AWARDEDAMOUNT       NUMBER(18,2)              NOT NULL,
  FUNDEDAMOUNT        NUMBER(18,2)              NOT NULL,
  AWARDDATE           DATE,
  AWARDSTARTDATE      DATE,
  AWARDENDDATE        DATE,
  IMPORTLINENUMBER    NUMBER(18)                NOT NULL
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


CREATE UNIQUE INDEX RISDASH.PK_TEMPAWARD ON RISDASH.TEMPAWARD
(IMPORTLINENUMBER)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

DROP TABLE RISDASH.TEMPPROPOSAL CASCADE CONSTRAINTS;

CREATE TABLE RISDASH.TEMPPROPOSAL
(
  PROPOSALID          NUMBER(18)                NOT NULL,
  PROPOSALNUM         CHAR(8 CHAR)              NOT NULL,
  PROPOSALTITLE       VARCHAR2(500 CHAR)        NOT NULL,
  ANUM                CHAR(9 CHAR)              NOT NULL,
  LASTNAME            VARCHAR2(60 CHAR)         NOT NULL,
  FIRSTNAME           VARCHAR2(60 CHAR)         NOT NULL,
  MIDDLENAME          VARCHAR2(60 CHAR),
  HOMEUNIT            CHAR(6 CHAR)              NOT NULL,
  HOMEUNITNAME        VARCHAR2(255 CHAR)        NOT NULL,
  HOMEUNITPARENT      CHAR(6 CHAR),
  HOMEUNITPARENTNAME  VARCHAR2(255 CHAR),
  LEADUNIT            CHAR(6 CHAR)              NOT NULL,
  LEADUNITNAME        VARCHAR2(255 CHAR)        NOT NULL,
  LEADUNITPARENT      CHAR(6 CHAR)              NOT NULL,
  LEADUNITPARENTNAME  VARCHAR2(255 CHAR)        NOT NULL,
  SPONSORNAME         VARCHAR2(500 CHAR),
  PROPOSALCOST        NUMBER(18,2)              NOT NULL,
  PROPOSALSUBMITDATE  DATE,
  PROPOSALSTARTDATE   DATE,
  PROPOSALENDDATE     DATE,
  IMPORTLINENUMBER    NUMBER(18)                NOT NULL
)
TABLESPACE USERS
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


CREATE UNIQUE INDEX RISDASH.PK_TEMPPROPOSAL ON RISDASH.TEMPPROPOSAL
(IMPORTLINENUMBER)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

CREATE INDEX RISDASH.IX_EMPLOEE_ORGCODE ON RISDASH.EMPLOYEE
(UNITCODE, ANUM, LASTNAME, FIRSTNAME, MIDDLENAME)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

CREATE INDEX RISDASH.IX_EMPLOYEE_1 ON RISDASH.EMPLOYEE
(UNITCODE)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

CREATE INDEX RISDASH.RDBORGNMAP_HIER_INDEX ON RISDASH.RDBORGNMAP
(RDBORGNMAP_PIDM, RDBORGNMAP_ORGN_CODE, RDBORGNMAP_NCHG_DATE)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           );

DROP SEQUENCE RISDASH.IMPORTRECORD_UNIQUEKEY_SEQ;

CREATE SEQUENCE RISDASH.IMPORTRECORD_UNIQUEKEY_SEQ
  START WITH 21
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


DROP SEQUENCE RISDASH.TEMPAWARD_IMPORTLINENUMBER_SEQ;

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


DROP SEQUENCE RISDASH.TEMPPROPOSAL_IMPORTLINENUMBER_SEQ;

CREATE SEQUENCE RISDASH.TEMPPROPOSAL_IMPORTLINENUMBER_SEQ
  START WITH 29621
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
