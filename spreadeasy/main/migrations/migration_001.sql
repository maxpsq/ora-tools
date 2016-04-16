
alter table SPREADEASY_STYLES drop column document;


CREATE TABLE SPREADEASY_BUILDERS
  (
    STYLE_ID       NUMBER (3) NOT NULL ,
    STEP           NUMBER (3) NOT NULL ,
    BUILDER_TYPE   VARCHAR2 (3 CHAR) NOT NULL,
    XML_DOC        XMLTYPE ,
    BUILDER_DOC    CLOB,
    OUT_PATH       VARCHAR2 (255 CHAR) NOT NULL 
  )
  XMLTYPE COLUMN XML_DOC STORE AS BINARY XML
  (
    STORAGE ( PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED FREELISTS 1 BUFFER_POOL DEFAULT ) RETENTION ENABLE STORAGE IN ROW NOCACHE
  ) ;
COMMENT ON COLUMN SPREADEASY_BUILDERS.STEP
IS
  'Building step number' ;
  COMMENT ON COLUMN SPREADEASY_BUILDERS.BUILDER_TYPE
IS
  'Builder type' ;
  COMMENT ON COLUMN SPREADEASY_BUILDERS.XML_DOC
IS
  'XML Document, usually a XSL' ;
  COMMENT ON COLUMN SPREADEASY_BUILDERS.BUILDER_DOC
IS
  'File Content' ;
  COMMENT ON COLUMN SPREADEASY_BUILDERS.OUT_PATH
IS
  'Output path' ;
ALTER TABLE SPREADEASY_BUILDERS ADD CONSTRAINT SPREADEASY_BUILDERS_CK_1 CHECK (BUILDER_TYPE IN ('TXT', 'XSL', 'XML')) ;
ALTER TABLE SPREADEASY_BUILDERS ADD CONSTRAINT SPREADEASY_BUILDERS_PK PRIMARY KEY ( STYLE_ID, STEP ) ;



ALTER TABLE SPREADEASY_BUILDERS ADD CONSTRAINT SPREADEASY$BUILDERS_STYLES_FK FOREIGN KEY ( STYLE_ID ) REFERENCES SPREADEASY_STYLES ( STYLE_ID ) ;
