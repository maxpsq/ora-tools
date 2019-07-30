-- Generato da Oracle SQL Developer Data Modeler 18.4.0.339.1532
--   in:        2019-07-30 22:27:36 CEST
--   sito:      Oracle Database 11g
--   tipo:      Oracle Database 11g



--  Spreadsheet ID on SPREADEASY_WRK table
CREATE SEQUENCE spreadeasy_wrk_seq START WITH 1 INCREMENT BY 1 MAXVALUE 9999999999;

CREATE TABLE spreadeasy_builders (
    style_id       NUMBER(3) NOT NULL, 
--  Building step number
    step           NUMBER(3) NOT NULL, 
--  Builder type
    builder_type   VARCHAR2(3 CHAR) NOT NULL, 
--  XML Document, usually a XSL
    xml_doc        XMLTYPE, 
--  File Content
    builder_doc    CLOB, 
--  Output path
    out_path       VARCHAR2(255 CHAR) NOT NULL
)
LOGGING XMLTYPE COLUMN xml_doc STORE AS BINARY XML (
    STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT )
    RETENTION
    ENABLE STORAGE IN ROW
    NOCACHE
);

COMMENT ON COLUMN spreadeasy_builders.step IS
    'Building step number';

COMMENT ON COLUMN spreadeasy_builders.builder_type IS
    'Builder type';

COMMENT ON COLUMN spreadeasy_builders.xml_doc IS
    'XML Document, usually a XSL';

COMMENT ON COLUMN spreadeasy_builders.builder_doc IS
    'File Content';

COMMENT ON COLUMN spreadeasy_builders.out_path IS
    'Output path';

ALTER TABLE spreadeasy_builders
    ADD CONSTRAINT spreadeasy_builders_ck_1 CHECK ( builder_type IN (
        'TXT',
        'XSL',
        'XML'
    ) );

ALTER TABLE spreadeasy_builders ADD CONSTRAINT spreadeasy_builders_pk PRIMARY KEY ( style_id,
                                                                                    step );

CREATE TABLE spreadeasy_locales ( 
--  Language ISO-639-1 code
    language          VARCHAR2(2 CHAR) NOT NULL,
    territory         VARCHAR2(5 CHAR) NOT NULL, 
--  Currency symbol
    currency_symbol   VARCHAR2(3 CHAR) NOT NULL, 
--  Writing mode
    writing_mode      VARCHAR2(10 CHAR) NOT NULL,
    date_format       VARCHAR2(16 CHAR) NOT NULL,
    time_format       VARCHAR2(10 CHAR) NOT NULL,
    page              VARCHAR2(20 CHAR) NOT NULL
)
LOGGING;

COMMENT ON COLUMN spreadeasy_locales.language IS
    'Language ISO-639-1 code';

COMMENT ON COLUMN spreadeasy_locales.page IS
    'Translation of the word "Page" ';

ALTER TABLE spreadeasy_locales ADD CONSTRAINT spreadeasy_locales_pk PRIMARY KEY ( language,
                                                                                  territory );

CREATE TABLE spreadeasy_styles ( 
--  XSLT ID 
    style_id      NUMBER(3) NOT NULL, 
--  XSLT description
    description   VARCHAR2(60 CHAR) NOT NULL
)
LOGGING;

COMMENT ON COLUMN spreadeasy_styles.style_id IS
    'XSLT ID ';

COMMENT ON COLUMN spreadeasy_styles.description IS
    'XSLT description';

ALTER TABLE spreadeasy_styles ADD CONSTRAINT spreadeasy_styles_pk PRIMARY KEY ( style_id );

--  Staging area to temporarily host the data to be used to create a spreadsheet
CREATE TABLE spreadeasy_wrk ( 
--  Unique ID of any spreadsheet creaded by Spreadeasy
    spreadsheet_id   NUMBER(10) NOT NULL, 
--  Worksheet number within the spreadsheet. Worksheets are numbered starting
--  from 1
    worksheet_id     NUMBER(4) NOT NULL, 
--  Query result as an XML document to be transformed to a Worksheet content
    document         XMLTYPE NOT NULL
)
LOGGING XMLTYPE COLUMN document STORE AS BINARY XML (
    STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT )
    RETENTION
    ENABLE STORAGE IN ROW
    NOCACHE
);

COMMENT ON TABLE spreadeasy_wrk IS
    'Staging area to temporarily host the data to be used to create a spreadsheet';

COMMENT ON COLUMN spreadeasy_wrk.spreadsheet_id IS
    'Unique ID of any spreadsheet creaded by Spreadeasy';

COMMENT ON COLUMN spreadeasy_wrk.worksheet_id IS
    'Worksheet number within the spreadsheet. Worksheets are numbered starting from 1';

COMMENT ON COLUMN spreadeasy_wrk.document IS
    'Query result as an XML document to be transformed to a Worksheet content';

ALTER TABLE spreadeasy_builders
    ADD CONSTRAINT spreadeasy$builders_styles_fk FOREIGN KEY ( style_id )
        REFERENCES spreadeasy_styles ( style_id )
    NOT DEFERRABLE;



-- Report sintetico di Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                             4
-- CREATE INDEX                             0
-- ALTER TABLE                              5
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
-- CREATE MATERIALIZED VIEW LOG             0
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
