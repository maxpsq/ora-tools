-- Generato da Oracle SQL Developer Data Modeler 4.1.1.888
--   in:        2016-02-21 20:00:54 CET
--   sito:      Oracle Database 11g
--   tipo:      Oracle Database 11g




CREATE SEQUENCE SPREADEASY_WRK_SEQ START WITH 1 INCREMENT BY 1 MAXVALUE 9999999999 ;

CREATE TABLE SPREADEASY_STYLES
  (
    STYLE_ID    NUMBER (3) NOT NULL ,
    DESCRIPTION VARCHAR2 (60 CHAR) NOT NULL ,
    DOCUMENT XMLTYPE
  )
  LOGGING XMLTYPE COLUMN DOCUMENT STORE AS BINARY XML
  (
    STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT ) RETENTION ENABLE STORAGE IN ROW NOCACHE
  ) ;
COMMENT ON COLUMN SPREADEASY_STYLES.STYLE_ID
IS
  'XSLT ID ' ;
  COMMENT ON COLUMN SPREADEASY_STYLES.DESCRIPTION
IS
  'XSLT description' ;
  COMMENT ON COLUMN SPREADEASY_STYLES.DOCUMENT
IS
  'XSLT Document' ;
ALTER TABLE SPREADEASY_STYLES ADD CONSTRAINT SPREADEASY_STYLES_PK PRIMARY KEY ( STYLE_ID ) ;


CREATE TABLE SPREADEASY_WRK
  (
    SPREADSHEET_ID NUMBER (10) NOT NULL ,
    WORKSHEET_ID   NUMBER (4) NOT NULL ,
    DOCUMENT XMLTYPE NOT NULL
  )
  LOGGING XMLTYPE COLUMN DOCUMENT STORE AS BINARY XML
  (
    STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT ) RETENTION ENABLE STORAGE IN ROW NOCACHE
  ) ;
COMMENT ON TABLE SPREADEASY_WRK
IS
  'Staging area to temporarily host the data to be used to create a spreadsheet' ;
  COMMENT ON COLUMN SPREADEASY_WRK.SPREADSHEET_ID
IS
  'Unique ID of any spreadsheet creaded by Spreadeasy' ;
  COMMENT ON COLUMN SPREADEASY_WRK.WORKSHEET_ID
IS
  'Worksheet number within the spreadsheet. Worksheets are numbered starting from 1' ;
  COMMENT ON COLUMN SPREADEASY_WRK.DOCUMENT
IS
  'Query result as an XML document to be transformed to a Worksheet content' ;



-- Report sintetico di Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                             2
-- CREATE INDEX                             0
-- ALTER TABLE                              1
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          1
-- CREATE MATERIALIZED VIEW                 0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
